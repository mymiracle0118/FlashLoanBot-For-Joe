require('dotenv').config();
const pancakeMainnet = require('./pancake-mainnet.json');
const pancakeTestnet = require('./pancake-testnet.json');
const pantherMainnet = require('./panther-mainnet.json');
const bakeryMainnet = require('./bakery-mainnet.json');
const apeMainnet = require('./ape-mainnet.json');

const BNB_MAINNET = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
const BUSD_MAINNET = '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56';

module.exports = {
  mainnet: {
    pancake: pancakeMainnet,
    panther: pantherMainnet,
    bakery: bakeryMainnet,
    ape: apeMainnet,
  },
  testnet: {
    pancake: pancakeTestnet,
  },
  pairs: [
    {
      name: 'BNB to BUSD, pancake>panther',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: pancakeMainnet.router,
      targetRouter: pantherMainnet.router,
      sourceFactory: pancakeMainnet.factory,
    },
    {
      name: 'BNB to BUSD, panther>pancake',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: pantherMainnet.router,
      targetRouter: pancakeMainnet.router,
      sourceFactory: pantherMainnet.factory,
    },
    {
      name: 'BNB to BUSD, pancake>ape',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: pancakeMainnet.router,
      targetRouter: apeMainnet.router,
      sourceFactory: pancakeMainnet.factory,
    },
    {
      name: 'BNB to BUSD, ape>pancake',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: apeMainnet.router,
      targetRouter: pancakeMainnet.router,
      sourceFactory: apeMainnet.factory,
    },
    {
      name: 'BNB to BUSD, pancake>bakery',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: pancakeMainnet.router,
      targetRouter: bakeryMainnet.router,
      sourceFactory: pancakeMainnet.factory,
    },
    {
      name: 'BNB to BUSD, bakery>pancake',
      amountTokenPay: process.env.BNB_AMOUNT,
      tokenPay: BNB_MAINNET,
      tokenSwap: BUSD_MAINNET,
      sourceRouter: bakeryMainnet.router,
      targetRouter: pancakeMainnet.router,
      sourceFactory: bakeryMainnet.factory,
    }
  ]
};