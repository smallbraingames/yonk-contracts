// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { RegisteredAddress, RegisteredAddressTableId, Registration, RegistrationData } from "codegen/index.sol";

library LibRegister {
    function getAddressId(address accountAddress) internal view returns (uint64) {
        (bytes memory staticData, PackedCounter encodedLengths, bytes memory dynamicData) =
            RegisteredAddress.encode({ value: accountAddress });
        bytes32[] memory ids = getKeysWithValue({
            tableId: RegisteredAddressTableId,
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        return ids.length > 0 ? uint64(uint256(ids[0])) : 0;
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
