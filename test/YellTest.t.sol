// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { P256 } from "p256-verifier/P256.sol";
import { P256Verifier } from "p256-verifier/P256Verifier.sol";

import { IWorld } from "codegen/world/IWorld.sol";

contract YellTest is MudTest {
  IWorld public world;

  function setUp() public override {
    super.setUp();
    vm.etch(P256.VERIFIER, type(P256Verifier).runtimeCode);
    world = IWorld(worldAddress);
  }
}
