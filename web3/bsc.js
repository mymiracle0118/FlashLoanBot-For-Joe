require('dotenv').config();
const Web3 = require('web3');
const BigNumber = require('bignumber.js');
const { performance } = require('perf_hooks');

const Flashswap = require('../out/Flashbot.sol/Flashbot.json');
const BlockSubscriber = require('../utils/block_subscriber.js');
const TransactionSender = require('../utils/transaction_send.js');

const fs = require('fs');
const util = require('util');
const request = require('async-request');

var log_file = fs.createWriteStream(__dirname + '/log_bsc_arbitrage.txt', { flags: 'w' });
var log_stdout = process.stdout;
console.log = function (d) {
  log_file.write(util.format(d) + '\n');
  log_stdout.write(util.format(d) + '\n');
};

const web3 = new Web3(
  new Web3.providers.WebsocketProvider(process.env.BSC_WSS, {
    reconnect: {
      auto: true,
      delay: 5000,
      maxAttempts: 15,
      onTimeout: false
    }
  })
);

const { address: admin } = web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY);

const prices = {};
const flashswap = new web3.eth.Contract(
  Flashswap.abi,
  process.env.ADDRESS_BSC
);

const getPrices = async() => {
  const response = await request(process.env.COINGECKO_URL);
  const prices = {};

  try {
    const json = JSON.parse(response.body);
    prices[process.env.BNB_MAINNET.toLowerCase()] = json.binancecoin.usd;
    prices[process.env.BUSD_MAINNET.toLowerCase()] = json.busd.usd;
    prices[process.env.ARB_MAINNET.toLowerCase()] = json.arbitrum.usd;
    prices[process.env.ETH_MAINNET.toLowerCase()] = json.ethereum.usd;
    prices[process.env.BEP20_USDT_MAINNET.toLowerCase()] = json.tether.usd;
  } catch (e) {
    console.error(e);
    return {};
  }

  return prices;
}

const { pairs } = require('../addresses/bsc/index.js');

const init = async () => {
  console.log('starting: ');
  console.log(JSON.stringify(pairs.map(p => p.name)));

  const transactionSender = TransactionSender.factory(process.env.BSC_PROVIDERS.split(','));

  let nonce = await web3.eth.getTransactionCount(admin);
  let gasPrice = await web3.eth.getGasPrice();

  setInterval(async () => {
    nonce = await web3.eth.getTransactionCount(admin);
  }, 1000 * 19);

  setInterval(async () => {
    gasPrice = await web3.eth.getGasPrice();
  }, 1000 * 60 * 3);

  const owner = await flashswap.methods.owner().call();
  console.log(`started: wallet ${admin} - gasPrice ${gasPrice} - contract owner: ${owner}`);

  let handler = async () => {
    const myPrices = await getPrices();
    if (Object.keys(myPrices).length > 0) {
      for (const[key, value] of Object.entries(myPrices)) {
        prices[key.toLowerCase()] = value;
      }
    }
  };

  await handler();
  setInterval(handler, 1000 * 60 * 5);

  const onBlock = async (block, web3, provider) => {
    const start = performance.now();
    const calls = [];

    pairs.forEach((pair) => {
      calls.push(async () => {
        const check = await flashswap.methods.checkProfitable(pair.tokenPay, pair.tokenSwap, new BigNumber(pair.amountTokenPay * 1e18), pair.sourceRouter, pair.targetRouter).call();
        const profit = check[0];

        let s = pair.tokenPay.toLowerCase(0);
        const price = prices[s];
        if (!price) {
          console.log('invalid price', pair.tokenPay);
          return;
        }

        const profitUsd = profit / 1e18 * price;
        const percentage = (100 * (profit / 1e18)) / pair.amountTokenPay;
        console.log(`[${block.number}] [${new Date().toLocaleString()}]: [${provider}] [${pair.name}] Arbitrage checked! Expected profit: ${(profit / 1e18).toFixed(3)} $${profitUsd.toFixed(2)} - ${percentage.toFixed(2)}%`);

        if (profit > 0) {
          console.log(`[${block.number}] [${new Date().toLocaleString()}]: [${provider}] [${pair.name}] Arbitrage opportunity found! Expected profit: ${(profit / 1e18).toFixed(3)} $${profitUsd.toFixed(2)} - ${percentage.toFixed(2)}%`);

          const tx = flashswap.methods.executeArbitrage(
              block.number + process.env.BLOCKNUMBER,
              pair.tokenPay,
              pair.tokenSwap,
              new BigNumber(pair.amountTokenPay * 1e18),
              pair.sourceRouter,
              pair.targetRouter,
              pair.sourceFactory,
          );

          let estimateGas
          try {
              estimateGas = await tx.estimateGas({from: admin});
          } catch (e) {
              console.log(`[${block.number}] [${new Date().toLocaleString()}]: [${pair.name}]`, 'gasCost error', e.message);
              return;
          }

          const myGasPrice = new BigNumber(gasPrice).plus(gasPrice * 0.2212).toString();
          const txCostBNB = Web3.utils.toBN(estimateGas) * Web3.utils.toBN(myGasPrice);

          // calculate the estimated gas cost in USD
          let gasCostUsd = (txCostBNB / 1e18) * prices[process.env.BNB_MAINNET.toLowerCase()];
          const profitMinusFeeInUsd = profitUsd - gasCostUsd;

          if (profitMinusFeeInUsd < 0.6) {
            console.log(`[${block.number}] [${new Date().toLocaleString()}] [${provider}]: [${pair.name}] stopped: `, JSON.stringify({
              profit: "$" + profitMinusFeeInUsd.toFixed(2),
              profitWithoutGasCost: "$" + profitUsd.toFixed(2),
              gasCost: "$" + gasCostUsd.toFixed(2),
              duration: `${(performance.now() - start).toFixed(2)} ms`,
              provider: provider,
              myGasPrice: myGasPrice.toString(),
              txCostBNB: txCostBNB / 1e18,
              estimateGas: estimateGas,
            }));
          }

          if (profitMinusFeeInUsd > 0.6) {
            console.log(`[${block.number}] [${new Date().toLocaleString()}] [${provider}]: [${pair.name}] and go: `, JSON.stringify({
              profit: "$" + profitMinusFeeInUsd.toFixed(2),
              profitWithoutGasCost: "$" + profitUsd.toFixed(2),
              gasCost: "$" + gasCostUsd.toFixed(2),
              duration: `${(performance.now() - start).toFixed(2)} ms`,
              provider: provider,
            }));

            const data = tx.encodeABI();
            const txData = {
              from: admin,
              to: flashswap.options.address,
              data: data,
              gas: estimateGas,
              gasPrice: new BigNumber(myGasPrice),
              nonce: nonce
            };

            let number = performance.now() - start;
            if (number > 1500) {
              console.error('out of time window: ', number);
              return;
            }

            console.log(`[${block.number}] [${new Date().toLocaleString()}] [${provider}]: sending transactions...`, JSON.stringify(txData))

            try {
              await transactionSender.sendTransaction(txData);
            } catch (e) {
              console.error('transaction error', e);
            }
          }
        } else {
          console.log('no profit');
        }

      });
    });

    try {
      await Promise.all(calls.map(fn => fn()));
    } catch (e) {
      console.log('error', e)
    }

    let number = performance.now() - start;
    if (number > 1500) {
      console.error('warning to slow', number);
    }

    if (block.number % 40 === 0) {
      console.log(`[${block.number}] [${new Date().toLocaleString()}]: alive (${provider}) - took ${number.toFixed(2)} ms`);
    }
  };

  BlockSubscriber.subscribe(process.env.BSC_PROVIDERS.split(','), onBlock);

};

init();