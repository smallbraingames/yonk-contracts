// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest } from "../YellTest.t.sol";

contract DeployTest is YellTest {
    function test_WorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }
}
