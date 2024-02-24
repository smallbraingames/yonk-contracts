// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ERC20Address } from "codegen/index.sol";

contract SetERC20System is System {
    error AlreadySet();

    function setERC20Address(address erc20Address) public {
        if (ERC20Address.get() != address(0)) {
            revert AlreadySet();
        }
        ERC20Address.set({ value: erc20Address });
    }
}
