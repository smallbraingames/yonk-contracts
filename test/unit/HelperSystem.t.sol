// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkSystem } from "../../src/systems/YonkSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";
import { RegisteredAddress, Registration, RegistrationData, Yonk, YonkData } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibRegister } from "libraries/LibRegister.sol";

import { VmSafe } from "forge-std/Vm.sol";

contract HelperSystemTest is YonkTest {
    function test_CorrectlyRegistersAndYonks() public {
        address a = address(0xface);
        address b = address(0xcafe);

        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo =
            YonkInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });

        vm.deal(a, 200);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        vm.prank(a);
        world.yonk{ value: 100 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        vm.prank(a);
        (, uint64 yonkId) = world.registerAndYonk{ value: 100 }({
            devicePublicKeyX: 234,
            devicePublicKeyY: 345,
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedYonkInfo
        });

        YonkData memory yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.dataCommitment, dataCommitment);
        assertEq(yonkData.startValue, 100);
        assertEq(yonkData.endValue, yonkInfo.endValue);
        assertEq(yonkData.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(yonkData.startTimestamp, block.timestamp);
        assertEq(yonkData.from, LibRegister.getAddressId({ accountAddress: a }));
        assertEq(yonkData.to, LibRegister.getAddressId({ accountAddress: b }));
        assertEq(yonkData.claimed, false);
        assertEq(address(worldAddress).balance, 100);
    }

    function test_CorrectlyRegistersAndClaimsEphemeralOwner() public {
        address a = address(0xface);

        string memory data = "deadbeef0000";
        bytes32 dataCommitmentPreimage = keccak256(abi.encodePacked(data));
        bytes32 dataCommitment = keccak256(abi.encodePacked(dataCommitmentPreimage));

        YonkInfo memory yonkInfo = YonkInfo({ endValue: 0, lifeSeconds: 100, to: 0 });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });

        VmSafe.Wallet memory ephemeralWallet = vm.createWallet(uint256(keccak256(bytes("1"))));

        vm.deal(a, 200);
        vm.prank(a);
        (, uint64 yonkId) = world.registerAndYonkEphemeralOwner{ value: 100 }({
            devicePublicKeyX: 234,
            devicePublicKeyY: 345,
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedYonkInfo,
            ephemeralOwner: ephemeralWallet.addr
        });

        YonkData memory yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.dataCommitment, dataCommitment);
        assertEq(yonkData.startValue, 100);
        assertEq(yonkData.endValue, yonkInfo.endValue);
        assertEq(yonkData.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(yonkData.startTimestamp, block.timestamp);
        assertEq(yonkData.isToEphemeralOwner, true);

        address b = address(0xcafe);
        uint256 bDevicePublicKeyX = uint256(bytes32(0x36be09afa9b7e115dbae9d3ec52617c88b5f7c8ad33fccf6967f075a428318f5));
        uint256 bDevicePublicKeyY = uint256(bytes32(0xfd143e7dd2c4f532c1bdd545d65cccef10541b3703a72ada559ef5690afc5728));
        uint256 r = uint256(bytes32(0x5e78453b05f2776f817ff1f0b108c096e79d073a90de23f176c8378ed6366049));
        uint256 s = uint256(bytes32(0x336d9099a139f73c8298aeb0d6fa1d1248889e1bc1de34c0b551be43902d81a3));

        bytes memory signature =
            createEphemeralOwnerSignature({ ephemeralPrivateKey: ephemeralWallet.privateKey, to: b });

        vm.prank(b);
        world.registerAndClaimEphemeralOwner({
            devicePublicKeyX: bDevicePublicKeyX,
            devicePublicKeyY: bDevicePublicKeyY,
            dataCommitmentPreimage: dataCommitmentPreimage,
            signatureR: r,
            signatureS: s,
            yonkId: yonkId,
            ephemeralOwnerSignature: signature
        });

        yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.to, LibRegister.getAddressId({ accountAddress: b }));
        assertEq(yonkData.isToEphemeralOwner, false);
        assertEq(yonkData.claimed, true);

        assertEq(address(a).balance, 100);
        assertEq(address(b).balance, 100);
    }
}
