// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { RegisteredAddressTableId } from "codegen/index.sol";

library LibRegister {
    function isRegistered(address accountAddress) internal view returns (bool) {
        bytes32[] memory ids = getKeysWithValue({
            tableId: RegisteredAddressTableId,
            staticData: abi.encodePacked(accountAddress),
            encodedLengths: PackedCounter.wrap(bytes32(0)),
            dynamicData: new bytes(0)
        });
        return ids.length > 0;
    }
}
