// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest } from "../YellTest.t.sol";

contract GetIdSystemTest is YellTest {
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
