// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// import "../../src/interfaces/IUniswapV2Router02.sol";
// import "../../src/interfaces/IERC20.sol";

contract MockUniswapV2Router02 {
    // Mock storage to simulate router behavior
    mapping(bytes32 => uint) public mockedAmountsOut;
    mapping(bytes32 => uint[]) public mockedAmountsOutMultiple;

    function setMockedAmountsOut(address tokenIn, address tokenOut, uint amountIn, uint mockedAmountOut) external {
        bytes32 key = keccak256(abi.encodePacked(tokenIn, tokenOut, amountIn));
        mockedAmountsOut[key] = mockedAmountOut;
    }

    function setMockedAmountsOutMultiple(address[] calldata path, uint[] calldata amounts) external {
        bytes32 key = keccak256(abi.encodePacked(path));
        mockedAmountsOutMultiple[key] = amounts;
    }

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts) {
        bytes32 key = keccak256(abi.encodePacked(path));
        require(mockedAmountsOutMultiple[key].length > 0, "Mock: amounts not set");
        return mockedAmountsOutMultiple[key];
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        // This function can be modified to simulate swap effects, such as token balance changes.
        return new uint[](path.length); // Simplification for example purposes.
    }

    // Implement other IUniswapV2Router02 functions as needed for your tests, potentially as no-op or simplified logic.

    // Omitted interface methods for brevity, implement them as necessary for your test setup.
}
