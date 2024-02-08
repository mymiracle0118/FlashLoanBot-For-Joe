// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import '../src/library/UniswapV2Library.sol';
import '../src/interfaces/IERC20.sol';
import '../src/interfaces/IUniswapV2Callee.sol';
import '../src/interfaces/IUniswapV2Pair.sol';
import '../src/interfaces/IUniswapV2Factory.sol';
import '../src/interfaces/IUniswapV2Router01.sol';
import '../src/interfaces/IUniswapV2Router02.sol';
import {Flashbot} from '../src/Flashbot.sol';

contract FlashbotTest is StdCheats, Test {

  address public owner;
  Flashbot flashbot;

  function setup() public {
    owner = msg.sender;
    flashbot = new Flashbot();
  }

  function test_executeArbitrage() public {
    address tokenPay = address(0x1);
    address tokenSwap = address(0x2);
    uint amountTokenPay = 100;
    address sourceRouter = address(0x3);
    address targetRouter = address(0x4);
    address sourceFactory = address(0x5);

    flashbot.executeArbitrage(100, tokenPay, tokenSwap, amountTokenPay, sourceRouter, targetRouter, sourceFactory);
  }

  function test_checkProfitable() public {
    address tokenPay = address(0x1);
    address tokenSwap = address(0x2);
    uint amountTokenPay = 100;
    address sourceRouter = address(0x3);
    address targetRouter = address(0x4);

    flashbot.checkProfitable(tokenPay, tokenSwap, amountTokenPay, sourceRouter, targetRouter);
  }
}
