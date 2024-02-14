// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Script.sol";
import {FlashbotFactory} from "src/FlashbotFactory.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";

import "src/Flashbot.sol";

contract FlashbotDeploy is Script {

    FlashbotFactory factory;

    function run() external {

        // Anything within the broadcast cheatcodes is executed on-chain
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        factory = new FlashbotFactory();
     
        bytes32 salt = keccak256(abi.encode("FlashBot", address(this)));

        bytes memory creationCode = abi.encodePacked(type(Flashbot).creationCode);

        address computedAddress = factory.computeAddress(salt, keccak256(creationCode));

        console.log("computed Flashbot Token Address");
        console.log(computedAddress);

        address deployedAddress = factory.deploy(0, salt , creationCode);

        console.log("deployed Flashbot Token Address");
        console.log(deployedAddress);

        vm.stopBroadcast();
    }

}