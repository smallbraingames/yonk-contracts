// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EphemeralOwnerAddress, InverseEphemeralOwnerAddress } from "codegen/index.sol";
import { LibId } from "libraries/LibId.sol";

library LibEphemeralOwner {
    function setEphemeralOwnerAddress(address ephemeralOwner) internal returns (uint64) {
        uint64 id = LibId.getId();
        EphemeralOwnerAddress.set({ id: id, value: ephemeralOwner });
        InverseEphemeralOwnerAddress.set({ value: ephemeralOwner, id: id });
        return id;
    }

    function isRegistered(address accountAddress) internal view returns (bool) {
        return InverseEphemeralOwnerAddress.get({ value: accountAddress }) != 0;
    }
}
