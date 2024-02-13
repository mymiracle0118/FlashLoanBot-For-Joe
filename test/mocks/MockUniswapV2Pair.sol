pragma solidity >=0.7.0 <0.9.0;

//import "../../src/interfaces/IUniswapV2Pair.sol";

contract MockUniswapV2Pair {
    address public token0;
    address public token1;
    uint112 private reserve0;
    uint112 private reserve1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = 0; // Mock, no need for actual timestamp
    }

    // Simplified swap function, doesn't perform actual token transfers
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external {
        require(amount0Out > 0 || amount1Out > 0, "MockPair: INSUFFICIENT_OUTPUT_AMOUNT");
        // Optionally update reserves to simulate the swap effect
    }

    // Mock function to manually set reserves for testing
    function setReserves(uint112 _reserve0, uint112 _reserve1) external {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
}
