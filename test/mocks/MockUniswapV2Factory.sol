pragma solidity >=0.7.0 <0.9.0;

contract MockUniswapV2Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "MockFactory: IDENTICAL_ADDRESSES");
        require(tokenA != address(0) && tokenB != address(0), "MockFactory: ZERO_ADDRESS");
        require(getPair[tokenA][tokenB] == address(0), "MockFactory: PAIR_EXISTS");

        // Instead of actual pair creation, we just simulate it by setting a mock pair address.
        // This address could be your MockUniswapV2Pair contract address or any other address for testing.
        pair = address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB, block.timestamp)))));
        
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair; // Optional: populate mapping in the reverse direction if needed
        allPairs.push(pair);

        // Emit an event for the creation. This is optional and can be removed if not needed for testing.
        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }

    // Mock event to keep interface compatibility
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}
