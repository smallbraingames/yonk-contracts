// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibId } from "./LibId.sol";
import { InverseRegisteredAddress, RegisteredAddress, Registration, RegistrationData } from "codegen/index.sol";

library LibRegister {
    function register(
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        address accountAddress
    )
        internal
        returns (uint64)
    {
        uint64 id = LibId.getId();
        Registration.set({ id: id, devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegisteredAddress.set({ id: id, value: accountAddress });
        InverseRegisteredAddress.set({ value: accountAddress, id: id });
        return id;
    }

    function getAddressId(address accountAddress) internal view returns (uint64) {
        return InverseRegisteredAddress.get({ value: accountAddress });
    }

    function isRegistered(address accountAddress) internal view returns (bool) {
        return getAddressId(accountAddress) != 0;
    }

    function hasId(uint64 id) internal view returns (bool) {
        RegistrationData memory registration = Registration.get({ id: id });
        return RegisteredAddress.get({ id: id }) != address(0) && registration.devicePublicKeyX != 0
            && registration.devicePublicKeyY != 0;
    }
}
