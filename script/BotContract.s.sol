// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";

contract BotContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
