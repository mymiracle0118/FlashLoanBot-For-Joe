// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import {FlashbotFactory} from "src/FlashbotFactory.sol";
import "src/Flashbot.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";

contract FlashbotFactoryTest is Test {
    FlashbotFactory internal factory;

    uint256 internal mainnetFork;
    string internal MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    uint256 internal optimsmFork;
    string internal OPTIMISM_RPC_URL = vm.envString("OPTIMISM_RPC_URL");

    uint256 internal sepoliaFork;
    string internal SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");

    address alice = address(1);

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        optimsmFork = vm.createFork(OPTIMISM_RPC_URL);
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
    }

    function testSepoliaDeploy() public {
        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("BOT_OWNER");

        factory = new FlashbotFactory();

        vm.deal(address(alice), 100 ether);
        vm.startPrank(address(alice));

        bytes32 salt = keccak256(abi.encode("Flashbot", address(this)));

        bytes memory creationCode = abi.encodePacked(
            type(Flashbot).creationCode,
            abi.encode(owner)
        );

        address computedAddress = factory.computeAddress(
            salt,
            keccak256(creationCode)
        );

        address deployedAddress = factory.deploy(0, salt, creationCode);

        vm.stopPrank();

        assertEq(computedAddress, deployedAddress);
    }
}
