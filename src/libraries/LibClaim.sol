// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { P256 } from "p256-verifier/P256.sol";

library LibClaim {
    function isAlive(uint256 startTimestamp, uint256 lifeSeconds) internal view returns (bool) {
        return block.timestamp < startTimestamp + lifeSeconds;
    }

    function isValidSignature(
        bytes32 messageHash,
        uint256 r,
        uint256 s,
        uint256 x,
        uint256 y
    )
        internal
        view
        returns (bool)
    {
        return P256.verifySignatureAllowMalleability({ message_hash: messageHash, r: r, s: s, x: x, y: y });
    }

    function getYellAmount(
        uint256 startValue,
        uint256 endValue,
        uint256 startTimestamp,
        uint256 lifeSeconds
    )
        internal
        view
        returns (uint256)
    {
        uint256 timePassed = block.timestamp - startTimestamp;
        uint256 valueLost = (startValue - endValue) * timePassed / lifeSeconds;
        uint256 valueLeft = startValue - valueLost;
        return valueLeft;
    }
}
