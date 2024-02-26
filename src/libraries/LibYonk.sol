// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkInfo } from "common/YonkInfo.sol";

library LibYonk {
    function encodeYonkInfo(YonkInfo memory yonkInfo) internal pure returns (uint176) {
        return uint176(
            bytes22(
                abi.encodePacked(
                    uint64(yonkInfo.to),
                    uint40(yonkInfo.startValue),
                    uint40(yonkInfo.endValue),
                    uint32(yonkInfo.lifeSeconds)
                )
            )
        );
    }

    function decodeYonkInfo(uint176 encodedYonkInfo) internal pure returns (YonkInfo memory) {
        uint64 to = uint64(encodedYonkInfo >> 112);
        uint256 startValue = uint256((encodedYonkInfo >> 72) & 0x000000000000000000000000FFFFFFFFFF);
        uint256 endValue = uint256((encodedYonkInfo >> 32) & 0x000000000000000000000000FFFFFFFFFF);
        uint256 lifeSeconds = uint256(encodedYonkInfo & 0x00000000000000000000000000FFFFFFFF);
        return YonkInfo({ startValue: startValue, endValue: endValue, lifeSeconds: lifeSeconds, to: to });
    }
}
