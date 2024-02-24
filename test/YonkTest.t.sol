// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { MessageHashUtils } from "@openzeppelin/utils/cryptography/MessageHashUtils.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import "forge-std/Test.sol";
import { P256 } from "p256-verifier/P256.sol";
import { P256Verifier } from "p256-verifier/P256Verifier.sol";

contract TestERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) { }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Exclude from forge coverage
    function test() public { }
}

contract YonkTest is MudTest {
    TestERC20 public token;
    IWorld public world;

    function setUp() public override {
        super.setUp();
        vm.etch(P256.VERIFIER, type(P256Verifier).runtimeCode);
        token = new TestERC20("Test", "TST");
        world = IWorld(worldAddress);
        world.setERC20Address(address(token));
    }

    function assumeValidPayableAddress(address addr) internal {
        vm.assume(
            addr != address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)
                && addr != address(0x4e59b44847b379578588920cA78FbF26c0B4956C)
                && addr != address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84)
                && addr != address(0x185a4dc360CE69bDCceE33b3784B0282f7961aea)
                && addr != address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D) && addr != worldAddress
                && addr > address(0x9)
        );
        assumePayable(addr);
    }

    function mintAndApproveToken(address from, uint256 amount) internal {
        token.mint(from, amount);
        vm.prank(from);
        token.approve(worldAddress, amount);
    }

    function createEphemeralOwnerSignature(
        uint256 ephemeralPrivateKey,
        address to
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes32 messageHash = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ephemeralPrivateKey, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        return signature;
    }
}
