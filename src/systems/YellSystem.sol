// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { YellInfo } from "common/YellInfo.sol";
import { LibYell } from "libraries/LibYell.sol";

contract YellSystem is System {
    error UnsafeCast();

    function encodeYellInfo(YellInfo memory yellInfo) public pure returns (uint136) {
        if (!(yellInfo.to < 1 << 64 && yellInfo.endValue < 1 << 40 && yellInfo.lifeSeconds < 1 << 32)) {
            revert UnsafeCast();
        }
        return LibYell.encodeYellInfo({ yellInfo: yellInfo });
    }
}
