// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ClaimSystem } from "systems/ClaimSystem.sol";
import { RegisterSystem } from "systems/RegisterSystem.sol";
import { YonkSystem } from "systems/YonkSystem.sol";

contract HelperSystem is System {
    function registerAndYonk(
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        bytes32 dataCommitment,
        uint176 encodedYonkInfo
    )
        public
        returns (uint64, uint64)
    {
        uint64 registeredId = abi.decode(
            SystemSwitch.call(abi.encodeCall(RegisterSystem.register, (devicePublicKeyX, devicePublicKeyY))), (uint64)
        );
        uint64 yonkId =
            abi.decode(SystemSwitch.call(abi.encodeCall(YonkSystem.yonk, (dataCommitment, encodedYonkInfo))), (uint64));
        return (registeredId, yonkId);
    }

    function registerAndYonkEphemeralOwner(
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        bytes32 dataCommitment,
        uint176 encodedYonkInfo,
        address ephemeralOwner
    )
        public
        returns (uint64, uint64)
    {
        uint64 registeredId = abi.decode(
            SystemSwitch.call(abi.encodeCall(RegisterSystem.register, (devicePublicKeyX, devicePublicKeyY))), (uint64)
        );
        uint64 yonkId = abi.decode(
            SystemSwitch.call(
                abi.encodeCall(YonkSystem.yonkEphemeralOwner, (dataCommitment, encodedYonkInfo, ephemeralOwner))
            ),
            (uint64)
        );
        return (registeredId, yonkId);
    }

    function registerAndClaimEphemeralOwner(
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        bytes32 dataCommitmentPreimage,
        uint256 signatureR,
        uint256 signatureS,
        uint64 yonkId,
        bytes memory ephemeralOwnerSignature
    )
        public
    {
        address to = _msgSender();
        abi.decode(
            SystemSwitch.call(abi.encodeCall(RegisterSystem.register, (devicePublicKeyX, devicePublicKeyY))), (uint64)
        );
        SystemSwitch.call(
            abi.encodeCall(
                ClaimSystem.claimEphemeralOwner,
                (dataCommitmentPreimage, signatureR, signatureS, to, yonkId, ephemeralOwnerSignature)
            )
        );
    }

    function reclaimBatch(uint64[] memory yonkIds) public {
        for (uint256 i = 0; i < yonkIds.length; i++) {
            SystemSwitch.call(abi.encodeCall(ClaimSystem.reclaim, (yonkIds[i])));
        }
    }
}
