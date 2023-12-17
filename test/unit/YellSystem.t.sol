// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellSystem } from "../../src/systems/YellSystem.sol";
import { YellTest } from "../YellTest.t.sol";
import { YellInfo } from "common/YellInfo.sol";

contract YellSystemTest is YellTest {
    function test_RevertsWhen_EncodingOverflows() public {
        YellInfo memory yellInfo = YellInfo({ endValue: 2 ** 253, lifeSeconds: 0, to: 0 });
        vm.expectRevert(YellSystem.UnsafeCast.selector);
        world.encodeYellInfo({ yellInfo: yellInfo });
    }
}
