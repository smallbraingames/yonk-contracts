// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Create2 } from "@latticexyz/world/src/Create2.sol";

import { IModule } from "@latticexyz/world/src/IModule.sol";
import { World } from "@latticexyz/world/src/World.sol";
import { WorldFactory } from "@latticexyz/world/src/WorldFactory.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";
import { Script } from "forge-std/Script.sol";

import { VmSafe } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

contract DeployWorld is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IModule initModule = IModule(address(0xC19519644C381AbE163caB1c4AB66c3c91E508A5));
        WorldFactory factory = new WorldFactory(initModule);
        address worldAddress = factory.deployWorld("0xface");
        console.log("DeployWorld: World deployed at address", worldAddress);

        // Deploy a new World and increase the WorldCount
        // IModule initModule = IModule(address(0xC19519644C381AbE163caB1c4AB66c3c91E508A5));
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // console.log("My public key", vm.addr(deployerPrivateKey));
        // console.log("contract address", address(this));
        // vm.startBroadcast(deployerPrivateKey);
        // World world = new World();
        // IBaseWorld baseWorld = IBaseWorld(address(world));
        // console.log("DeployWorld: World deployed at address", address(world));
        // console.log("world creator", world.creator());
        // world.initialize(initModule);
        // baseWorld.transferOwnership(ROOT_NAMESPACE_ID, msg.sender);
        // console.log("DeployWorld: World deployed at address", address(world));
        // vm.stopBroadcast();
    }
}
