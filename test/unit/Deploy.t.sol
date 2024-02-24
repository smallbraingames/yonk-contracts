// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkTest } from "../YonkTest.t.sol";

contract DeployTest is YonkTest {
    function test_WorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }
}
