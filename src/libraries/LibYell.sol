// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellInfo } from "common/YellInfo.sol";

library LibYell {
    function encodeYellInfo(YellInfo memory yellInfo) internal pure returns (uint136) {
        return uint136(
            bytes17(abi.encodePacked(uint64(yellInfo.to), uint40(yellInfo.endValue), uint32(yellInfo.lifeSeconds)))
        );
    }

    function decodeYellInfo(uint136 encodedYellInfo) internal pure returns (YellInfo memory) {
        uint64 to = uint64(encodedYellInfo >> 72);
        uint256 endValue = uint256((encodedYellInfo >> 32) & 0x000000000000000000000000FFFFFFFFFF);
        uint256 lifeSeconds = uint256(encodedYellInfo & 0x00000000000000000000000000FFFFFFFF);
        return YellInfo({ endValue: endValue, lifeSeconds: lifeSeconds, to: to });
    }
}
