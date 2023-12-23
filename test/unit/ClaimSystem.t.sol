// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ClaimSystem } from "../../src/systems/ClaimSystem.sol";
import { YellTest, console } from "../YellTest.t.sol";

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

        vm.deal(sender, 200);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        console.logBytes(abi.encodePacked(bytes32(bytes6(0xdeadbeef0000))));
        console.logBytes(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes32(bytes6(0xdeadbeef0000))));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 200 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });

        assertEq(address(receiver).balance, 100);
        assertEq(address(sender).balance, 100);
        assertTrue(Yell.getClaimed({ id: yellId }));
    }
  
    function test_RevertsWhen_DuplicateClaim() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x31a80482dadf89de6302b1988c82c29544c9c07bb910596158f6062517eb089a));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0x2f54c9a0f348752950094d3228d3b940258c75fe2a413cb70baa21dc2e352fc5));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        vm.deal(sender, 500);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 500 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });

        vm.expectRevert(ClaimSystem.AlreadyClaimed.selector);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });
    }

    function test_RevertsWhen_ClaimerNotRegistered() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x31a80482dadf89de6302b1988c82c29544c9c07bb910596158f6062517eb089a));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0x2f54c9a0f348752950094d3228d3b940258c75fe2a413cb70baa21dc2e352fc5));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        vm.deal(sender, 500);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 500 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.warp(block.timestamp + 100);
        vm.prank(address(0xdead));
        vm.expectRevert(ClaimSystem.ClaimerNotRegistered.selector);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });
    }

    function test_RevertsWhen_IncorrectData() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x31a80482dadf89de6302b1988c82c29544c9c07bb910596158f6062517eb089a));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0x2f54c9a0f348752950094d3228d3b940258c75fe2a413cb70baa21dc2e352fc5));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        vm.deal(sender, 500);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitment = keccak256(abi.encodePacked(sha256(abi.encodePacked(bytes6(0xdeadbeef0001)))));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 500 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        vm.expectRevert(ClaimSystem.IncorrectData.selector);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });
    }

    function test_RevertsWhen_YellExpired() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x31a80482dadf89de6302b1988c82c29544c9c07bb910596158f6062517eb089a));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0x2f54c9a0f348752950094d3228d3b940258c75fe2a413cb70baa21dc2e352fc5));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        vm.deal(sender, 500);
        YellInfo memory yellInfo = YellInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        bytes32 dataCommitmentPreimage = sha256(abi.encodePacked(bytes6(0xdeadbeef0000)));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.prank(sender);
        uint64 yellId = world.yell{ value: 500 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        uint256 r = uint256(bytes32(0xe22466e928fdccef0de49e3503d2657d00494a00e764fd437bdafa05f5922b1f));
        uint256 s = uint256(bytes32(0xbbb77c6817ccf50748419477e843d5bac67e6a70e97dde5a57e0c983b777e1ad));

        vm.warp(block.timestamp + 201);
        vm.prank(receiver);
        vm.expectRevert(ClaimSystem.YellExpired.selector);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yellId: yellId });
    }
}
