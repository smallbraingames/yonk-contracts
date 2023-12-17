// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest, console } from "../YellTest.t.sol";
import { YellInfo } from "common/YellInfo.sol";
import { LibYell } from "libraries/LibYell.sol";

contract LibYellTest is YellTest {
    function test_EncodeAndDecode() public {
        YellInfo memory yellInfo = YellInfo({ endValue: 2332, lifeSeconds: 10_576, to: 9938 });
        uint136 encoded = LibYell.encodeYell({ yellInfo: yellInfo });
        YellInfo memory decoded = LibYell.decodeYell({ encodedYellInfo: encoded });
        assertEq(decoded.to, yellInfo.to);
        assertEq(decoded.lifeSeconds, yellInfo.lifeSeconds);
        assertEq(decoded.endValue, yellInfo.endValue);
    }

    /// forge-config: default.fuzz.runs = 4096
    function testFuzz_EncodeAndDecode(uint64 to, uint40 endValue, uint32 lifeSeconds) public {
        YellInfo memory yellInfo = YellInfo({ endValue: endValue, lifeSeconds: lifeSeconds, to: to });
        uint136 encoded = LibYell.encodeYell({ yellInfo: yellInfo });
        YellInfo memory decoded = LibYell.decodeYell({ encodedYellInfo: encoded });
        assertEq(decoded.to, yellInfo.to);
        assertEq(decoded.lifeSeconds, yellInfo.lifeSeconds);
        assertEq(decoded.endValue, yellInfo.endValue);
    }
}
