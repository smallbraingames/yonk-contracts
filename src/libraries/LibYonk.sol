// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkInfo } from "common/YonkInfo.sol";

library LibYonk {
    function encodeYonkInfo(YonkInfo memory yonkInfo) internal pure returns (uint136) {
        return uint136(
            bytes17(abi.encodePacked(uint64(yonkInfo.to), uint40(yonkInfo.endValue), uint32(yonkInfo.lifeSeconds)))
        );
    }

    function decodeYonkInfo(uint136 encodedYonkInfo) internal pure returns (YonkInfo memory) {
        uint64 to = uint64(encodedYonkInfo >> 72);
        uint256 endValue = uint256((encodedYonkInfo >> 32) & 0x000000000000000000000000FFFFFFFFFF);
        uint256 lifeSeconds = uint256(encodedYonkInfo & 0x00000000000000000000000000FFFFFFFF);
        return YonkInfo({ endValue: endValue, lifeSeconds: lifeSeconds, to: to });
    }
}
