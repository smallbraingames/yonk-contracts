// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { Id } from "codegen/index.sol";

contract GetIdSystem is System {
    function getId() public returns (uint64) {
        uint64 id = Id.get() + 1;
        Id.set({ value: id });
        return id;
    }
}
