// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { IWorld } from "codegen/world/IWorld.sol";

library LibId {
    function getId(IWorld world) internal returns (uint64) {
        return uint64(uint256(bytes32(SystemSwitch.call(abi.encodeCall(world.getId, ())))));
    }
}
