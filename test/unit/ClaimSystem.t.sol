// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ClaimSystem } from "../../src/systems/ClaimSystem.sol";
import { YellTest } from "../YellTest.t.sol";

import { Yell } from "codegen/index.sol";
import { YellInfo } from "common/YellInfo.sol";

contract ClaimSystemTest is YellTest {
    function test_Claim() public {
        address sender = address(0xface);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xcafe);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x31a80482dadf89de6302b1988c82c29544c9c07bb910596158f6062517eb089a));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0x2f54c9a0f348752950094d3228d3b940258c75fe2a413cb70baa21dc2e352fc5));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        vm.deal(sender, 100);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 100, to: receiverId });

        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 100 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });

        assertEq(address(receiver).balance, 100);
        assertTrue(Yell.getClaimed({ id: yellId }));
    }
}
