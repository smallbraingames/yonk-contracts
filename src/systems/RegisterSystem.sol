// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RegisteredAddress, Registration } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract RegisterSystem is System {
    error AlreadyRegistered();

    function register(uint256 devicePublicKeyX, uint256 devicePublicKeyY) public {
        uint64 id = uint64(uint256(bytes32(SystemSwitch.call(abi.encodeCall(IWorld(_world()).getId, ())))));
        address accountAddress = _msgSender();
        if (LibRegister.isRegistered({ accountAddress: accountAddress })) {
            revert AlreadyRegistered();
        }
        Registration.set({ id: id, devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegisteredAddress.set({ id: id, value: accountAddress });
    }
}
