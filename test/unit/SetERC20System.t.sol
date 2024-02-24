// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SetERC20System } from "../../src/systems/SetERC20System.sol";
import { YonkTest } from "../YonkTest.t.sol";

contract SetERC20SystemTest is YonkTest {
    function test_RevertsWhen_SetTwice() public {
        vm.expectRevert(SetERC20System.AlreadySet.selector);
        world.setERC20Address(address(0xface));
    }

    function testFuzz_RevertsWhen_SetTwice(address setter, address token) public {
        vm.expectRevert(SetERC20System.AlreadySet.selector);
        vm.prank(setter);
        world.setERC20Address(token);
    }
}
