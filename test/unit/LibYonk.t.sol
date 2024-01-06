// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkTest, console } from "../YonkTest.t.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibYonk } from "libraries/LibYonk.sol";

contract LibYonkTest is YonkTest {
    function test_EncodeAndDecode() public {
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 2332, lifeSeconds: 10_576, to: 9938 });
        uint136 encoded = LibYonk.encodeYonkInfo({ yonkInfo: yonkInfo });
        YonkInfo memory decoded = LibYonk.decodeYonkInfo({ encodedYonkInfo: encoded });
        assertEq(decoded.to, yonkInfo.to);
        assertEq(decoded.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(decoded.endValue, yonkInfo.endValue);
    }

    /// forge-config: default.fuzz.runs = 4096
    function testFuzz_EncodeAndDecode(uint64 to, uint40 endValue, uint32 lifeSeconds) public {
        YonkInfo memory yonkInfo = YonkInfo({ endValue: endValue, lifeSeconds: lifeSeconds, to: to });
        uint136 encoded = LibYonk.encodeYonkInfo({ yonkInfo: yonkInfo });
        YonkInfo memory decoded = LibYonk.decodeYonkInfo({ encodedYonkInfo: encoded });
        assertEq(decoded.to, yonkInfo.to);
        assertEq(decoded.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(decoded.endValue, yonkInfo.endValue);
    }
}
