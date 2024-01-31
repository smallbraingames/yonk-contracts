// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { ClaimEvent, RegisteredAddress, Registration, RegistrationData, Yonk, YonkData } from "codegen/index.sol";

import { LibClaim } from "libraries/LibClaim.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error ClaimerNotRegistered();
    error IncorrectData();
    error InvalidSignature();
    error NotYourYonk();
    error YonkExpired();

    function claim(bytes32 dataCommitmentPreimage, uint256 signatureR, uint256 signatureS, uint64 yonkId) public {
        YonkData memory yonkData = Yonk.get({ id: yonkId });

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
        payable(toAddress).transfer(yonkAmount);
        if (returnAmount > 0) {
            payable(fromAddress).transfer(returnAmount);
        }
        ClaimEvent.set({id: yonkId, claimedValue: yonkAmount, returnedValue: returnAmount, timestamp: block.timestamp});
    }
}
