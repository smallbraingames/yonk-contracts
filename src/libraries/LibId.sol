// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { GetIdSystem } from "systems/GetIdSystem.sol";

library LibId {
    function getId() internal returns (uint64) {
        return uint64(uint256(bytes32(SystemSwitch.call(abi.encodeCall(GetIdSystem.getId, ())))));
    }
}
