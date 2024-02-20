require('dotenv').config();
const pancakeMainnet = require('./pancake-mainnet.json');
const apeMainnet = require('./ape-mainnet.json');

const ARB_MAINNET = '0x912ce59144191c1204e64559fe8253a0e49e6548';
const USDT_MAINNET = '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9';

module.exports = {
  mainnet: {
    pancake: pancakeMainnet,
    ape: apeMainnet,
  },
  pairs: [
    {
      name: 'ARB to USDT, pancake>ape',
      amountTokenPay: process.env.ARB_AMOUNT,
      tokenPay: ARB_MAINNET,
      tokenSwap: USDT_MAINNET,
      sourceRouter: pancakeMainnet.router,
      targetRouter: apeMainnet.router,
      sourceFactory: pancakeMainnet.factory,
    },
    {
      name: 'ARB to USDT, ape>pancake',
      amountTokenPay: process.env.ARB_AMOUNT,
      tokenPay: ARB_MAINNET,
      tokenSwap: USDT_MAINNET,
      sourceRouter: apeMainnet.router,
      targetRouter: pancakeMainnet.router,
      sourceFactory: apeMainnet.factory,
    }
  ]
};