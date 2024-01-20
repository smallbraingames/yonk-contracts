// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

import { System } from "@latticexyz/world/src/System.sol";
import { RegisterSystem } from "systems/RegisterSystem.sol";
import { YonkSystem } from "systems/YonkSystem.sol";

contract HelperSystem is System {
    function registerAndYonk(
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        bytes32 dataCommitment,
        uint136 encodedYonkInfo
    )
        public
        payable
        returns (uint64, uint64)
    {
        uint64 registeredId = abi.decode(
            SystemSwitch.call(abi.encodeCall(RegisterSystem.registerPayable, (devicePublicKeyX, devicePublicKeyY))),
            (uint64)
        );
        uint64 yonkId =
            abi.decode(SystemSwitch.call(abi.encodeCall(YonkSystem.yonk, (dataCommitment, encodedYonkInfo))), (uint64));
        return (registeredId, yonkId);
    }
}
