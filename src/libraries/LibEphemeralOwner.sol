// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { EphemeralOwnerAddress, EphemeralOwnerAddressTableId } from "codegen/index.sol";
import { LibId } from "libraries/LibId.sol";

library LibEphemeralOwner {
    function setEphemeralOwnerAddress(address ephemeralOwner) internal returns (uint64) {
        uint64 id = LibId.getId();
        EphemeralOwnerAddress.set({ id: id, value: ephemeralOwner });
        return id;
    }

    function isRegistered(address accountAddress) internal view returns (bool) {
        (bytes memory staticData, PackedCounter encodedLengths, bytes memory dynamicData) =
            EphemeralOwnerAddress.encode({ value: accountAddress });
        bytes32[] memory ids = getKeysWithValue({
            tableId: EphemeralOwnerAddressTableId,
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        return ids.length > 0;
    }
}
