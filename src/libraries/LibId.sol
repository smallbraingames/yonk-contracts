// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Id } from "codegen/index.sol";

library LibId {
    function getId() internal returns (uint64) {
        uint64 id = Id.get() + 1;
        Id.set({ value: id });
        return id;
    }
}
