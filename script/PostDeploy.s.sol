// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ERC20Address } from "codegen/index.sol";

import { IWorld } from "codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        IWorld world = IWorld(worldAddress);
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        uint256 chainId = block.chainid;
        if (chainId == 8453) {
            world.setERC20Address(address(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913));
        } else if (chainId == 84_532) {
            world.setERC20Address(address(0x036CbD53842c5426634e7929541eC2318f3dCF7e));
        } else if (chainId == 11_155_111) {
            world.setERC20Address(address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238));
        } else {
            console.log("PostDeploy: unknown chain and no token specified");
        }

        vm.stopBroadcast();
    }
}
