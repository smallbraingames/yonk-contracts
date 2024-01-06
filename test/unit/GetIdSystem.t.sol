// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkTest } from "../YonkTest.t.sol";
import { Id } from "codegen/index.sol";

contract GetIdSystemTest is YonkTest {
    function test_IncrementsId() public {
        assertEq(Id.get(), 0);
        world.register({ devicePublicKeyX: 0, devicePublicKeyY: 0 });
        assertEq(Id.get(), 1);
        vm.prank(address(0xcafe));
        world.register({ devicePublicKeyX: 0, devicePublicKeyY: 0 });
        assertEq(Id.get(), 2);
    }

    function test_RevertsWhen_GetIdNotCalledFromAllowedSystems() public {
        vm.expectRevert();
        vm.prank(address(0xcafe));
        world.getId();
    }

    function testFuzz_RevertsWhen_GetIdNotCalledFromAllowedSystems(address caller) public {
        vm.expectRevert();
        vm.prank(caller);
        world.getId();
    }
}
