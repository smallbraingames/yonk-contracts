// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { RegisteredAddress, Registration } from "codegen/index.sol";

import { LibId } from "libraries/LibId.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract RegisterSystem is System {
    error AlreadyRegistered();

    function register(uint256 devicePublicKeyX, uint256 devicePublicKeyY) public returns (uint64) {
        uint64 id = LibId.getId();
        address accountAddress = _msgSender();
        if (LibRegister.isRegistered({ accountAddress: accountAddress })) {
            revert AlreadyRegistered();
        }
        Registration.set({ id: id, devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegisteredAddress.set({ id: id, value: accountAddress });
        return id;
    }
}
