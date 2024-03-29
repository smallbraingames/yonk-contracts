// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ClaimSystem } from "../../src/systems/ClaimSystem.sol";
import { YonkTest, console } from "../YonkTest.t.sol";

import { Yonk } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";

import { ECDSA } from "@openzeppelin/utils/cryptography/ECDSA.sol";

import { VmSafe } from "forge-std/Vm.sol";

import { console } from "forge-std/console.sol";

contract ClaimSystemTest is YonkTest {
    function test_Claim() public {
        address sender = address(0xface);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xcafe);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));

        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 200, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });

        assertEq(token.balanceOf(address(receiver)), 100);
        assertEq(token.balanceOf(address(sender)), 100);
        assertTrue(Yonk.getClaimed({ id: yonkId }));
    }

    function test_RevertsWhen_DuplicateClaim() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 500, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });

        vm.expectRevert(ClaimSystem.AlreadyClaimed.selector);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });
    }

    function test_RevertsWhen_ClaimerNotRegistered() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 500, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 100);
        vm.prank(address(0xdead));
        vm.expectRevert(ClaimSystem.ClaimerNotRegistered.selector);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });
    }

    function test_RevertsWhen_IncorrectData() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 500, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        string memory incorrectData = "deadbeef0001";
        bytes32 incorrectDataCommitmentPreimage = keccak256(abi.encodePacked(incorrectData));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        vm.expectRevert(ClaimSystem.IncorrectData.selector);
        world.claim({
            dataCommitmentPreimage: incorrectDataCommitmentPreimage,
            signatureR: r,
            signatureS: s,
            yonkId: yonkId
        });
    }

    function test_RevertsWhen_YonkExpired() public {
        address sender = address(0xbeef);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xabcd);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 500, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 201);
        vm.prank(receiver);
        vm.expectRevert(ClaimSystem.YonkExpired.selector);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });
    }

    function test_ClaimEphemeralOwner() public {
        address sender = address(0xface);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;

        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        mintAndApproveToken(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 200, endValue: 0, lifeSeconds: 200, to: 0 });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        VmSafe.Wallet memory ephemeralWallet = vm.createWallet(uint256(keccak256(bytes("1"))));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonkEphemeralOwner({
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedYonkInfo,
            ephemeralOwner: ephemeralWallet.addr
        });

        address receiver = address(0xcafe);

        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        bytes memory signature =
            createEphemeralOwnerSignature({ ephemeralPrivateKey: ephemeralWallet.privateKey, to: receiver });

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claimEphemeralOwner({
            dataCommitmentPreimage: dataCommitmentPreimage,
            signatureR: r,
            signatureS: s,
            to: receiver,
            yonkId: yonkId,
            ephemeralOwnerSignature: signature
        });

        assertEq(token.balanceOf(address(receiver)), 100);
        assertEq(token.balanceOf(address(sender)), 100);
        assertTrue(Yonk.getClaimed({ id: yonkId }));
        assertEq(Yonk.getTo({ id: yonkId }), receiverId);
    }

    function test_Reclaim() public {
        address sender = address(0xface);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;
        address receiver = address(0xcafe);
        uint256 receiverDevicePublicKeyX =
            uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 receiverDevicePublicKeyY =
            uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));

        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        vm.prank(receiver);
        uint64 receiverId =
            world.register({ devicePublicKeyX: receiverDevicePublicKeyX, devicePublicKeyY: receiverDevicePublicKeyY });

        mintAndApproveToken(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 200, endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        vm.warp(block.timestamp + 200);

        vm.prank(sender);
        world.reclaim(yonkId);

        assertEq(token.balanceOf(address(sender)), 200);

        vm.expectRevert(ClaimSystem.AlreadyReclaimed.selector);
        vm.prank(sender);
        world.reclaim(yonkId);
    }

    function test_ReclaimEphemeralOwner() public {
        address sender = address(0xface);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;

        vm.prank(sender);
        world.register({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY });

        mintAndApproveToken(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 200, endValue: 0, lifeSeconds: 200, to: 0 });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        VmSafe.Wallet memory ephemeralWallet = vm.createWallet(uint256(keccak256(bytes("1"))));

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonkEphemeralOwner({
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedYonkInfo,
            ephemeralOwner: ephemeralWallet.addr
        });

        vm.expectRevert(ClaimSystem.YonkNotExpired.selector);
        vm.prank(sender);
        world.reclaim(yonkId);

        vm.warp(block.timestamp + 200);

        vm.expectRevert(ClaimSystem.NotYourYonk.selector);
        world.reclaim(yonkId);

        assertEq(token.balanceOf(address(sender)), 0);

        vm.prank(sender);
        world.reclaim(yonkId);

        assertEq(token.balanceOf(address(sender)), 200);
    }
}
