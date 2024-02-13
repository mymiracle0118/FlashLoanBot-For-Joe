// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {console2} from "forge-std/console2.sol";
import "./mocks/MockUniswapV2Router02.sol";
import "./mocks/MockUniswapV2Factory.sol";
//import "./mocks/MockUniswapV2Pair.sol";
// import {StdCheats} from "forge-std/StdCheats.sol";
import '../src/library/UniswapV2Library.sol';
import '../src/interfaces/IERC20.sol';
import '../src/interfaces/IUniswapV2Callee.sol';
import '../src/interfaces/IUniswapV2Pair.sol';
import '../src/interfaces/IUniswapV2Factory.sol';
// import '../src/interfaces/IUniswapV2Router01.sol';
import {Flashbot} from '../src/Flashbot.sol';

contract FlashbotTest is Test {
    Flashbot flashbot;
    MockUniswapV2Router02 mockSourceRouter;
    MockUniswapV2Router02 mockTargetRouter;
    MockUniswapV2Factory mockFactory;

    address tokenPay;
    address tokenSwap;
    uint256 amountTokenPay;
    uint256 mockedAmountOut;

    address alice = address(100);

    uint256 internal mainnetFork;
    string internal MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    uint256 internal optimsmFork;
    string internal OPTIMISM_RPC_URL = vm.envString("OPTIMISM_RPC_URL");

    uint256 internal sepoliaFork;
    string internal SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
    // Mock other components as necessary

    // function setUp() public {
    //     // Deploy Mocks
    //     mockSourceRouter = new MockUniswapV2Router02();
    //     mockTargetRouter = new MockUniswapV2Router02();
    //     mockFactory = new MockUniswapV2Factory();
    //     // Initialize other mocks

    //     // Deploy Flashbot contract
    //     flashbot = new Flashbot();
    // }

function setUp() public {

    mainnetFork = vm.createFork(MAINNET_RPC_URL);
    optimsmFork = vm.createFork(OPTIMISM_RPC_URL);
    sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
    // Deploy simplified mock contracts
    mockFactory = new MockUniswapV2Factory();
    mockSourceRouter = new MockUniswapV2Router02();
    mockTargetRouter = new MockUniswapV2Router02();
    flashbot = new Flashbot();
    // Setup mock return values
    address[] memory path = new address[](2);
    path[0] = address(tokenPay);
    path[1] = address(tokenSwap);
    uint[] memory amountsOut = new uint[](2);
    amountsOut[0] = amountTokenPay;
    amountsOut[1] = mockedAmountOut; // The amount you expect to receive after the swap
    mockSourceRouter.setMockedAmountsOutMultiple(path, amountsOut);
    // Similar setup for mockTargetRouter if needed
}


    function testExecuteArbitrage() public {

        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);

        vm.deal(address(alice), 100 ether);

        console.log("balance of alice");
        console.log(address(alice).balance);

        assertEq(address(alice).balance, 100 ether);

        // Mock data for testing
        address tokenPay = address(1); // Use mock token addresses
        address tokenSwap = address(2);
        uint amountTokenPay = 1e18; // 1 token for simplicity, adjust as necessary
        address sourceRouter = address(mockSourceRouter);
        address targetRouter = address(mockTargetRouter);
        address sourceFactory = address(mockFactory);

        // Setup mocks here (e.g., mock token balances, expected return values)
        console.log("test");
        console2.log("test");
        // Execute arbitrage function
        vm.startPrank(address(flashbot));
        flashbot.executeArbitrage(
            block.number + 100, 
            tokenPay, 
            tokenSwap, 
            amountTokenPay, 
            sourceRouter, 
            targetRouter, 
            sourceFactory
        );
        vm.stopPrank();

        // Assertions to verify expected outcomes
        // Example: assertEq(mockToken.balanceOf(address(flashbot)), expectedBalance, "Flashbot did not receive expected token amount");
    }

    function testCheckProfitable() public {
        // Mock data for testing
        address tokenPay = address(1);
        address tokenSwap = address(2);
        uint amountTokenPay = 1e18; // Adjust as necessary
        address sourceRouter = address(mockSourceRouter);
        address targetRouter = address(mockTargetRouter);

        // Execute checkProfitable function
        (int profit, uint tokenBorrowAmount) = flashbot.checkProfitable(
            tokenPay, 
            tokenSwap, 
            amountTokenPay, 
            sourceRouter, 
            targetRouter
        );

        // Assertions to verify expected outcomes
        // Example: assertTrue(profit > 0, "Arbitrage is not profitable");
    }

    // Include more test cases as necessary
}
