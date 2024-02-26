// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ECDSA } from "@openzeppelin/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/utils/cryptography/MessageHashUtils.sol";
import {
    ClaimEvent,
    EphemeralOwnerAddress,
    ReclaimEvent,
    RegisteredAddress,
    Registration,
    RegistrationData,
    Yonk,
    YonkData
} from "codegen/index.sol";

import { LibClaim } from "libraries/LibClaim.sol";

import { LibERC20 } from "libraries/LibERC20.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error AlreadyReclaimed();
    error Ephemeral();
    error ClaimerNotRegistered();
    error IncorrectData();
    error InvalidSignature();
    error InvalidEphemeralSignature();
    error NotEphemeral();
    error NotYourYonk();
    error YonkExpired();
    error YonkNotExpired();

    function reclaim(uint64 yonkId) public {
        YonkData memory yonkData = Yonk.get({ id: yonkId });

        address senderAddress = _msgSender();
        uint64 fromId = LibRegister.getAddressId({ accountAddress: senderAddress });

        if (yonkData.from != fromId) {
            revert NotYourYonk();
        }

        if (yonkData.claimed) {
            revert AlreadyClaimed();
        }

        if (LibClaim.isAlive({ startTimestamp: yonkData.startTimestamp, lifeSeconds: yonkData.lifeSeconds })) {
            revert YonkNotExpired();
        }

        if (yonkData.reclaimed) {
            revert AlreadyReclaimed();
        }

        Yonk.setReclaimed({ id: yonkId, reclaimed: true });
        LibERC20.transferTo({ to: senderAddress, value: yonkData.startValue });
        ReclaimEvent.set({ id: yonkId, returnedValue: yonkData.startValue, timestamp: block.timestamp });
    }

    function claimEphemeralOwner(
        bytes32 dataCommitmentPreimage,
        uint256 signatureR,
        uint256 signatureS,
        address to,
        uint64 yonkId,
        bytes memory ephemeralOwnerSignature
    )
        public
    {
        bool isToEphemeralOwner = Yonk.getIsToEphemeralOwner({ id: yonkId });
        uint64 ephemeralOwnerId = Yonk.getTo({ id: yonkId });

        if (!isToEphemeralOwner) {
            revert NotEphemeral();
        }

        bytes32 message = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to)));

        address signer = ECDSA.recover(message, ephemeralOwnerSignature);
        address ephemeralOwner = EphemeralOwnerAddress.get({ id: ephemeralOwnerId });

        if (signer != ephemeralOwner) {
            revert InvalidEphemeralSignature();
        }

        uint64 toId = LibRegister.getAddressId({ accountAddress: to });
        Yonk.setTo({ id: yonkId, to: toId });
        Yonk.setIsToEphemeralOwner({ id: yonkId, isToEphemeralOwner: false });

        claim(dataCommitmentPreimage, signatureR, signatureS, yonkId);
    }

    function claim(bytes32 dataCommitmentPreimage, uint256 signatureR, uint256 signatureS, uint64 yonkId) public {
        YonkData memory yonkData = Yonk.get({ id: yonkId });

        if (yonkData.isToEphemeralOwner) {
            revert Ephemeral();
        }

        if (yonkData.claimed) {
            revert AlreadyClaimed();
        }

        address toAddress = _msgSender();
        if (!LibRegister.isRegistered({ accountAddress: toAddress })) {
            revert ClaimerNotRegistered();
        }

        uint64 toId = LibRegister.getAddressId({ accountAddress: toAddress });
        if (yonkData.to != toId) {
            revert NotYourYonk();
        }

        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));
        if (yonkData.dataCommitment != dataCommitment) {
            revert IncorrectData();
        }

        if (!LibClaim.isAlive({ startTimestamp: yonkData.startTimestamp, lifeSeconds: yonkData.lifeSeconds })) {
            revert YonkExpired();
        }

        RegistrationData memory registrationData = Registration.get({ id: toId });
        if (
            !LibClaim.isValidSignature({
                messageHash: sha256(abi.encodePacked(dataCommitmentPreimage)),
                r: signatureR,
                s: signatureS,
                x: registrationData.devicePublicKeyX,
                y: registrationData.devicePublicKeyY
            })
        ) {
            revert InvalidSignature();
        }

        Yonk.setClaimed({ id: yonkId, claimed: true });

        uint256 yonkAmount = LibClaim.getYonkAmount({
            startValue: yonkData.startValue,
            endValue: yonkData.endValue,
            startTimestamp: yonkData.startTimestamp,
            lifeSeconds: yonkData.lifeSeconds
        });

        uint256 returnAmount = yonkData.startValue - yonkAmount;
        address fromAddress = RegisteredAddress.get({ id: yonkData.from });

        LibERC20.transferTo({ to: toAddress, value: yonkAmount });
        if (returnAmount > 0) {
            LibERC20.transferTo({ to: fromAddress, value: returnAmount });
        }

        ClaimEvent.set({ id: yonkId, claimedValue: yonkAmount, returnedValue: returnAmount, timestamp: block.timestamp });
    }
}
