// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Yonk } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";

import { LibERC20 } from "libraries/LibERC20.sol";

import { LibEphemeralOwner } from "libraries/LibEphemeralOwner.sol";
import { LibId } from "libraries/LibId.sol";
import { LibRegister } from "libraries/LibRegister.sol";
import { LibYonk } from "libraries/LibYonk.sol";

contract YonkSystem is System {
    error EndValueGreaterThanStart();
    error EphemeralOwnerAlreadyExists();
    error EphemeralYonkNonzeroTo();
    error NotRegistered();
    error UnsafeCast();
    error NoSelfYonk();
    error ZeroLifeSeconds();
    error ZeroValue();

    function checkYonkInfo(YonkInfo memory yonkInfo) internal pure {
        if (yonkInfo.startValue <= 0) {
            revert ZeroValue();
        }
        if (yonkInfo.endValue > yonkInfo.startValue) {
            revert EndValueGreaterThanStart();
        }
        if (yonkInfo.lifeSeconds <= 0) {
            revert ZeroLifeSeconds();
        }
    }

    function yonk(bytes32 dataCommitment, uint176 encodedYonkInfo) public returns (uint64) {
        YonkInfo memory yonkInfo = LibYonk.decodeYonkInfo({ encodedYonkInfo: encodedYonkInfo });

        address fromAddress = _msgSender();
        uint64 from = LibRegister.getAddressId({ accountAddress: fromAddress });

        checkYonkInfo(yonkInfo);

        if (!LibRegister.hasId({ id: from }) || !LibRegister.hasId({ id: yonkInfo.to })) {
            revert NotRegistered();
        }
        if (from == yonkInfo.to) {
            revert NoSelfYonk();
        }

        uint64 id = LibId.getId();

        LibERC20.collect({ from: fromAddress, value: yonkInfo.startValue });

        Yonk.set({
            id: id,
            dataCommitment: dataCommitment,
            startValue: yonkInfo.startValue,
            endValue: yonkInfo.endValue,
            lifeSeconds: yonkInfo.lifeSeconds,
            startTimestamp: block.timestamp,
            from: from,
            to: yonkInfo.to,
            claimed: false,
            reclaimed: false,
            isToEphemeralOwner: false
        });
        return id;
    }

    function yonkEphemeralOwner(
        bytes32 dataCommitment,
        uint176 encodedYonkInfo,
        address ephemeralOwner
    )
        public
        returns (uint64)
    {
        YonkInfo memory yonkInfo = LibYonk.decodeYonkInfo({ encodedYonkInfo: encodedYonkInfo });
        address fromAddress = _msgSender();

        if (fromAddress == ephemeralOwner) {
            revert NoSelfYonk();
        }
        if (yonkInfo.to != 0) {
            revert EphemeralYonkNonzeroTo();
        }
        if (LibEphemeralOwner.isRegistered({ accountAddress: ephemeralOwner })) {
            revert EphemeralOwnerAlreadyExists();
        }

        checkYonkInfo(yonkInfo);

        uint64 from = LibRegister.getAddressId({ accountAddress: fromAddress });

        uint64 to = LibEphemeralOwner.setEphemeralOwnerAddress({ ephemeralOwner: ephemeralOwner });

        if (!LibRegister.hasId({ id: from })) {
            revert NotRegistered();
        }

        uint64 id = LibId.getId();

        LibERC20.collect({ from: fromAddress, value: yonkInfo.startValue });

        Yonk.set({
            id: id,
            dataCommitment: dataCommitment,
            startValue: yonkInfo.startValue,
            endValue: yonkInfo.endValue,
            lifeSeconds: yonkInfo.lifeSeconds,
            startTimestamp: block.timestamp,
            from: from,
            to: to,
            claimed: false,
            reclaimed: false,
            isToEphemeralOwner: true
        });

        return id;
    }

    function encodeYonkInfo(YonkInfo memory yonkInfo) public pure returns (uint176) {
        if (
            !(
                (yonkInfo.to < (1 << 64)) && (yonkInfo.startValue < (1 << 40)) && (yonkInfo.endValue < (1 << 40))
                    && (yonkInfo.lifeSeconds < (1 << 32))
            )
        ) {
            revert UnsafeCast();
        }
        return LibYonk.encodeYonkInfo({ yonkInfo: yonkInfo });
    }
}
