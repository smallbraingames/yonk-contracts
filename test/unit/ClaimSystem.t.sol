// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ClaimSystem } from "../../src/systems/ClaimSystem.sol";
import { YonkTest, console } from "../YonkTest.t.sol";

import { Yonk } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";

import { ECDSA } from "@openzeppelin/utils/cryptography/ECDSA.sol";

import { VmSafe } from "forge-std/Vm.sol";

import {console} from "forge-std/console.sol";

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

        vm.deal(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk{ value: 200 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);
        world.claim({ dataCommitmentPreimage: dataCommitmentPreimage, signatureR: r, signatureS: s, yonkId: yonkId });

        assertEq(address(receiver).balance, 100);
        assertEq(address(sender).balance, 100);
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

        vm.deal(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk{ value: 500 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

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

        vm.deal(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk{ value: 500 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

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

        vm.deal(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        string memory incorrectData = "deadbeef0001";
        bytes32 incorrectDataCommitmentPreimage = keccak256(abi.encodePacked(incorrectData));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk{ value: 500 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

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

        vm.deal(sender, 500);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: receiverId });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonk{ value: 500 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

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

        vm.deal(sender, 200);
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 200, to: 0 });

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        VmSafe.Wallet memory ephemeralWallet = vm.createWallet(uint256(keccak256(bytes("1"))));

        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(sender);
        uint64 yonkId = world.yonkEphemeralOwner{ value: 200 }({
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

        assertEq(address(receiver).balance, 100);
        assertEq(address(sender).balance, 100);
        assertTrue(Yonk.getClaimed({ id: yonkId }));
        assertEq(Yonk.getTo({ id: yonkId }), receiverId);
    }

    function test_ClaimRegisterAndEphemeralOwner() public {
        address sender = address(0x8DC5b6593e6B081839403f3648260efC62Ae17Bf);
        uint256 senderDevicePublicKeyX = 12;
        uint256 senderDevicePublicKeyY = 321;

        vm.deal(sender, 1 ether);

        vm.prank(sender);
        (, uint64 yonkId) = world.registerAndYonkEphemeralOwner{value: 7185456635769203}({ devicePublicKeyX: senderDevicePublicKeyX, devicePublicKeyY: senderDevicePublicKeyY, dataCommitment: 0x09a8ddd7b98ebd3780b538cd546b8376a886eea80807eba7a1c1ff8c899cf632, encodedYonkInfo: 4722366482869645236616, ephemeralOwner: 0x21Dd4e148515a9E844b9AdA947c9d725dE6C5C6D});

        address receiver = address(0xAE59e2E7aF4e52b854fF5A1cE216d159079D14EA);

        vm.warp(block.timestamp + 100);
        vm.prank(receiver);

        world.registerAndClaimEphemeralOwner({
            devicePublicKeyX: 0x4b9094408f9109a9b4213646bb957f278893047a79aa7b4513104f6fb765da63,
            devicePublicKeyY: 0x7b9977c8af4a650563d04c0c8b15abe93ece5b27062a9d2123fc1b5e108f260e,
            dataCommitmentPreimage: 0x1330778bd706c7da94b124aeb5cba6944814ac455b1cd428c83e10628e48b2f7,
            signatureR: 0x26728d02613b21bd55a84c657b81d629047f1f7732fc8dcc23157eda33081296,
            signatureS: 0x4af8a9d5d6f392b4daa4f03db7fcf714c02f07a89bb1a51f4362d01ad6127c83,
            yonkId: yonkId,
            ephemeralOwnerSignature: hex"127bbc0ba1e78e21f32d5f0e7b67ae38868eb731f792674095c8ba0d423e3809612aaa2463b3c918bf40a7753e432a55164af2bb11682a34ac686265580bbc2e1c"
        });

        assertTrue(Yonk.getClaimed({ id: yonkId }));
    }
}
