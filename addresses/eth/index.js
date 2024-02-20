require('dotenv').config();
const pancakeMainnet = require('./pancake-mainnet.json');
const apeMainnet = require('./ape-mainnet.json');


const WETH_MAINNET = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2';
const USDT_MAINNET = '0xdac17f958d2ee523a2206206994597c13d831ec7';

module.exports = {
  mainnet: {
    pancake: pancakeMainnet,
    ape: apeMainnet,
  },
  pairs: [
    {
      name: 'WETH to USDT, pancake>ape',
      amountTokenPay: process.env.WETH_AMOUNT,
      tokenPay: WETH_MAINNET,
      tokenSwap: USDT_MAINNET,
      sourceRouter: pancakeMainnet.router,
      targetRouter: apeMainnet.router,
      sourceFactory: pancakeMainnet.factory,
    },
    {
      name: 'WETH to USDT, ape>pancake',
      amountTokenPay: process.env.WETH_AMOUNT,
      tokenPay: WETH_MAINNET,
      tokenSwap: USDT_MAINNET,
      sourceRouter: apeMainnet.router,
      targetRouter: pancakeMainnet.router,
      sourceFactory: apeMainnet.factory,
    }
  ]
};