// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { RegisteredAddress, Registration } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { LibId } from "libraries/LibId.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract RegisterSystem is System {
    error AlreadyRegistered();

    function register(uint256 devicePublicKeyX, uint256 devicePublicKeyY) public {
        uint64 id = LibId.getId({ world: IWorld(_world()) });
        address accountAddress = _msgSender();
        if (LibRegister.isRegistered({ accountAddress: accountAddress })) {
            revert AlreadyRegistered();
        }
        Registration.set({ id: id, devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegisteredAddress.set({ id: id, value: accountAddress });
    }
}
