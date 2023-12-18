// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { Yell } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { YellInfo } from "common/YellInfo.sol";
import { LibId } from "libraries/LibId.sol";
import { LibRegister } from "libraries/LibRegister.sol";
import { LibYell } from "libraries/LibYell.sol";

contract YellSystem is System {
    error EndValueGreaterThanStart();
    error NotRegistered();
    error UnsafeCast();
    error NoSelfYell();

    function yell(bytes32 dataCommitment, uint136 encodedYellInfo) public payable returns (uint64) {
        YellInfo memory yellInfo = LibYell.decodeYellInfo({ encodedYellInfo: encodedYellInfo });

        uint64 from = LibRegister.getAddressId({ accountAddress: _msgSender() });
        uint256 startValue = _msgValue();

        if (from == yellInfo.to) {
            revert NoSelfYell();
        }

        if (!LibRegister.hasId({ id: from }) || !LibRegister.hasId({ id: yellInfo.to })) {
            revert NotRegistered();
        }
        if (yellInfo.endValue > startValue) {
            revert EndValueGreaterThanStart();
        }

        uint64 id = LibId.getId({ world: IWorld(_world()) });
        Yell.set({
            id: id,
            dataCommitment: dataCommitment,
            startValue: startValue,
            endValue: yellInfo.endValue,
            lifeSeconds: yellInfo.lifeSeconds,
            startTimestamp: block.timestamp,
            from: from,
            to: yellInfo.to,
            claimed: false
        });

        return id;
    }

    function encodeYellInfo(YellInfo memory yellInfo) public pure returns (uint136) {
        if (!(yellInfo.to < 1 << 64 && yellInfo.endValue < 1 << 40 && yellInfo.lifeSeconds < 1 << 32)) {
            revert UnsafeCast();
        }
        return LibYell.encodeYellInfo({ yellInfo: yellInfo });
    }
}
