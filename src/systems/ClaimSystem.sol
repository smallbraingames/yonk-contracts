// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { RegisteredAddress, Registration, RegistrationData, Yell, YellData } from "codegen/index.sol";

import { LibClaim } from "libraries/LibClaim.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error ClaimerNotRegistered();
    error IncorrectData();
    error InvalidSignature();
    error NotYourYell();
    error YellExpired();

    function claim(uint256 dataCommitmentPreimage, uint256 signatureR, uint256 signatureS, uint64 yellId) public {
        YellData memory yellData = Yell.get({ id: yellId });

        if (yellData.claimed) {
            revert AlreadyClaimed();
        }

        address toAddress = _msgSender();
        if (!LibRegister.isRegistered({ accountAddress: toAddress })) {
            revert ClaimerNotRegistered();
        }

        uint64 toId = LibRegister.getAddressId({ accountAddress: toAddress });
        if (yellData.to != toId) {
            revert NotYourYell();
        }

        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));
        if (yellData.dataCommitment != dataCommitment) {
            revert IncorrectData();
        }

        if (!LibClaim.isAlive({ startTimestamp: yellData.startTimestamp, lifeSeconds: yellData.lifeSeconds })) {
            revert YellExpired();
        }

        RegistrationData memory registrationData = Registration.get({ id: toId });
        if (
            !LibClaim.isValidSignature({
                dataCommitment: dataCommitment,
                r: signatureR,
                s: signatureS,
                x: registrationData.devicePublicKeyX,
                y: registrationData.devicePublicKeyY
            })
        ) {
            revert InvalidSignature();
        }

        Yell.setClaimed({ id: yellId, claimed: true });

        uint256 yellAmount = LibClaim.getYellAmount({
            startValue: yellData.startValue,
            endValue: yellData.endValue,
            startTimestamp: yellData.startTimestamp,
            lifeSeconds: yellData.lifeSeconds
        });

        uint256 returnAmount = yellData.startValue - yellAmount;
        address fromAddress = RegisteredAddress.get({ id: yellData.from });
        payable(toAddress).transfer(yellAmount);
        if (returnAmount > 0) {
            payable(fromAddress).transfer(returnAmount);
        }
    }
}
