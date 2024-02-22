// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Bytes } from "@latticexyz/store/src/Bytes.sol";

import { IWorldErrors } from "@latticexyz/world/src/IWorldErrors.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { FunctionSelectors } from "@latticexyz/world/src/codegen/tables/FunctionSelectors.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

/**
 * @title SystemSwitch
 * @dev The SystemSwitch library provides functions for interacting with systems from other systems.
 */
library LibSystemSwitch {
    using WorldResourceIdInstance for ResourceId;

    function call(ResourceId systemId, bytes memory callData) internal returns (bytes memory returnData) {
        bool success;
        (success, returnData) = SystemCall.call({
            caller: WorldContextConsumerLib._msgSender(),
            value: WorldContextConsumerLib._msgValue(),
            systemId: systemId,
            callData: callData
        });

        if (!success) revertWithBytes(returnData);
        return returnData;
    }

    /**
     * @notice Calls a system via the function selector registered for it in the World contract.
     * @dev Reverts if the system is not found, or if the system call reverts.
     * If the call is executed from the root context, the system is called directly via delegatecall.
     * Otherwise, the call is executed via an external call to the World contract.
     * @param callData The world function selector, and call data to be forwarded to the system.
     * @return returnData The return data from the system call.
     */
    function call(bytes memory callData) internal returns (bytes memory returnData) {
        // Get the systemAddress and systemFunctionSelector from the worldFunctionSelector encoded in the calldata
        (ResourceId systemId, bytes4 systemFunctionSelector) = FunctionSelectors.get(bytes4(callData));

        // Revert if the function selector is not found
        if (ResourceId.unwrap(systemId) == 0) revert IWorldErrors.World_FunctionSelectorNotFound(msg.sig);

        // Replace function selector in the calldata with the system function selector, and call the system
        return call({ systemId: systemId, callData: Bytes.setBytes4(callData, 0, systemFunctionSelector) });
    }
}
