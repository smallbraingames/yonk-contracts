// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract RegisterSystem is System {
    error AlreadyRegistered();

    function register(uint256 devicePublicKeyX, uint256 devicePublicKeyY) public returns (uint64) {
        address accountAddress = _msgSender();
        if (LibRegister.isRegistered({ accountAddress: accountAddress })) {
            revert AlreadyRegistered();
        }
        uint64 id = LibRegister.register({
            devicePublicKeyX: devicePublicKeyX,
            devicePublicKeyY: devicePublicKeyY,
            accountAddress: accountAddress
        });
        return id;
    }
}
