// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IModule } from "@latticexyz/world/src/IModule.sol";
import { WorldFactory } from "@latticexyz/world/src/WorldFactory.sol";
import { Script } from "forge-std/Script.sol";

import { console } from "forge-std/console.sol";

contract DeployWorld is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        console.log("[DeployWorld] Deploying World, make sure to run this script with verification settings");
        IModule initModule = IModule(address(0xC19519644C381AbE163caB1c4AB66c3c91E508A5));
        WorldFactory factory = new WorldFactory(initModule);
        address worldAddress = factory.deployWorld("0xdeaf");
        console.log("[DeployWorld] World deployed at address", worldAddress);
    }
}
