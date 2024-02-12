// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { Yonk } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibId } from "libraries/LibId.sol";
import { LibRegister } from "libraries/LibRegister.sol";
import { LibYonk } from "libraries/LibYonk.sol";

contract YonkSystem is System {
    error EndValueGreaterThanStart();
    error NotRegistered();
    error UnsafeCast();
    error NoSelfYonk();

    function yonk(bytes32 dataCommitment, uint136 encodedYonkInfo) public payable returns (uint64) {
        YonkInfo memory yonkInfo = LibYonk.decodeYonkInfo({ encodedYonkInfo: encodedYonkInfo });

        uint64 from = LibRegister.getAddressId({ accountAddress: _msgSender() });
        uint256 startValue = _msgValue();

        if (from == yonkInfo.to) {
            revert NoSelfYonk();
        }
        if (!LibRegister.hasId({ id: from }) || !LibRegister.hasId({ id: yonkInfo.to })) {
            revert NotRegistered();
        }
        if (yonkInfo.endValue > startValue) {
            revert EndValueGreaterThanStart();
        }

        uint64 id = LibId.getId();
        Yonk.set({
            id: id,
            dataCommitment: dataCommitment,
            startValue: startValue,
            endValue: yonkInfo.endValue,
            lifeSeconds: yonkInfo.lifeSeconds,
            startTimestamp: block.timestamp,
            from: from,
            to: yonkInfo.to,
            claimed: false,
            isToEphemeralOwner: false
        });

        return id;
    }

    function yonkEphemeralOwner(
        bytes32 dataCommitment,
        uint136 encodedYonkInfo,
        address ephemeralOwner
    )
        public
        payable
        returns (uint64)
    {
        YonkInfo memory yonkInfo = LibYonk.decodeYonkInfo({ encodedYonkInfo: encodedYonkInfo });

        uint64 from = LibRegister.getAddressId({ accountAddress: _msgSender() });
        uint256 startValue = _msgValue();
        uint64 to = LibYonk.setEphemeralOwnerAddress({ ephemeralOwner: ephemeralOwner });

        if (from == to) {
            revert NoSelfYonk();
        }
        if (!LibRegister.hasId({ id: from })) {
            revert NotRegistered();
        }
        if (yonkInfo.endValue > startValue) {
            revert EndValueGreaterThanStart();
        }

        uint64 id = LibId.getId();
        Yonk.set({
            id: id,
            dataCommitment: dataCommitment,
            startValue: startValue,
            endValue: yonkInfo.endValue,
            lifeSeconds: yonkInfo.lifeSeconds,
            startTimestamp: block.timestamp,
            from: from,
            to: to,
            claimed: false,
            isToEphemeralOwner: true
        });

        return id;
    }

    function encodeYonkInfo(YonkInfo memory yonkInfo) public pure returns (uint136) {
        if (!(yonkInfo.to < 1 << 64 && yonkInfo.endValue < 1 << 40 && yonkInfo.lifeSeconds < 1 << 32)) {
            revert UnsafeCast();
        }
        return LibYonk.encodeYonkInfo({ yonkInfo: yonkInfo });
    }
}
