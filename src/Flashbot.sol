// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import './library/UniswapV2Library.sol';
import './interfaces/IERC20.sol';
//import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Router02.sol';

/**
  @author Iwaki Hiroto
 */

contract Flashbot {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function executeArbitrage(
    uint _maxBlockNumber,
    address _tokenPay, // Source token
    address _tokenSwap, // Destination token that we get by swap from source token
    uint _amountTokenPay, // Gwei value of source token amount
    address _sourceRouter,
    address _targetRouter,
    address _sourceFactory
  ) external {
    require(block.number <= _maxBlockNumber, "Out of block"); // be careful to use block.number here, especially if deploying across multiple chains

    // Recheck profitable
    (int profit, uint _tokenBorrowAmount) = checkProfitable(_tokenPay, _tokenSwap, _amountTokenPay, _sourceRouter, _targetRouter);

    // Revert if no profit
    require(profit > 0, 'No profit');

    // Get pair address
    address pairAddress = IUniswapV2Factory(_sourceFactory).getPair(_tokenPay, _tokenSwap);

    // Revert if invalid pair address
    require(pairAddress != address(0), 'Invalid pair address');

    address token0 = IUniswapV2Pair(pairAddress).token0();
    address token1 = IUniswapV2Pair(pairAddress).token1();
    
    // Revert invalid token
    require(token0 != address(0) && token1 != address(0), 'Invalid pair token');

    IUniswapV2Pair(pairAddress).swap(
      _tokenSwap == token0 ? _tokenBorrowAmount : 0,
      _tokenSwap == token1 ? _tokenBorrowAmount : 0,
      address(this),
      abi.encode(_sourceRouter, _targetRouter)
    );
  }

  function checkProfitable(
    address _tokenPay, // Source token
    address _tokenSwap, // Destination token that we get by swap from source token
    uint _amountTokenPay, // Gwei value of source token amount
    address _sourceRouter,
    address _targetRouter
  ) public view returns (int, uint) {
    address[] memory path1 = new address[](2);
    address[] memory path2 = new address[](2);

    // path1 is the forwarding exchange from source token to swapped token
    path1[0] = path2[1] = _tokenPay;
    // path2 is the backward exchange from swapeed token to source token
    path1[1] = path2[0] = _tokenSwap;

    uint amountOut = IUniswapV2Router02(_sourceRouter).getAmountsOut(_amountTokenPay, path1)[1];
    uint amountRepay = IUniswapV2Router02(_targetRouter).getAmountsOut(amountOut, path2)[1];

    return (
      int(amountRepay - _amountTokenPay),
      amountOut
    );
  }
  
  function _execute(
    address _sender,
    uint _amount0,
    uint _amount1,
    bytes calldata _data
  ) internal {

    require(_sender == owner, 'Invalid Sender');
    // Get an amount of token that you have exchanged
    uint amountToken = _amount0 == 0 ? _amount1 : _amount0;

    IUniswapV2Pair iUniswapV2Pair = IUniswapV2Pair(msg.sender);
    address token0 = iUniswapV2Pair.token0();
    address token1 = iUniswapV2Pair.token1();

    address[] memory path1 = new address[](2);
    address[] memory path2 = new address[](2);

    address sellToken = _amount0 == 0 ? token1 : token0;
    address buyToken = _amount0 == 0 ? token0 : token1;

    // path1 is the forwarding exchange from source token to swapped token
    // path2 is the backward exchange from swapped token to source token
    path1[0] = path2[1] = sellToken;
    path1[1] = path2[0] = buyToken;

    (address sourceRouter, address targetRouter) = abi.decode(_data, (address, address));
    require(sourceRouter != address(0) && targetRouter != address(0), 'Empty Source/Target Router');

    // ERC20 token that we will sell for other token
    IERC20 token = IERC20(sellToken);
    token.approve(targetRouter, amountToken);

    // Get the amount of needed input token
    uint amountRequired = IUniswapV2Router02(sourceRouter).getAmountsIn(amountToken, path2)[0];


    // Swap token and get equivalent otherToken amountRequired as a result
    uint amountReceived = IUniswapV2Router02(targetRouter).swapExactTokensForTokens(
      amountToken,
      amountRequired,
      path1,
      address(this),
      block.timestamp + 60
    )[1];

    // Revert if the receiced amount is less than required amount
    require(amountReceived > amountRequired, 'Not enough received amount');

    IERC20 otherToken = IERC20(buyToken);

    // callback should send the funds to the pair address back
    otherToken.transfer(msg.sender, amountRequired);
    // transfer the profit to the owner
    otherToken.transfer(owner, amountReceived - amountRequired); 
  }

  function pancakeCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  function waultSwapCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  function uniswapV2Call(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  // mdex
  function swapV2Call(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  // pantherswap
  function pantherCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  // jetswap
  function jetswapCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  // cafeswap
  function cafeCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  function BiswapCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  function wardenCall(uint256 _amount0, uint256 _amount1, bytes calldata _data) external {
    address sender = msg.sender;
    _execute(sender, _amount0, _amount1, _data);
  }

  receive() external payable {}

}