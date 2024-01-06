// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkSystem } from "../../src/systems/YonkSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";

import { Yonk, YonkData } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract YonkSystemTest is YonkTest {
    function test_CorrectlySetsYonk() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo =
            YonkInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(a, 100);
        vm.prank(a);
        uint64 yonkId = world.yonk{ value: 100 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

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

    function testFuzz_CorrectlySetsYonk(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp
    )
        public
    {
        assumeValidPayableAddress(from);
        assumeValidPayableAddress(to);
        vm.assume(from != to);
        vm.assume(uint256(endValue) <= startValue);

        vm.prank(from);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(to);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        uint64 yonkId =
            world.yonk{ value: startValue }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        YonkData memory yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.dataCommitment, dataCommitment);
        assertEq(yonkData.startValue, startValue);
        assertEq(yonkData.endValue, yonkInfo.endValue);
        assertEq(yonkData.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(yonkData.startTimestamp, startTimestamp);
        assertEq(yonkData.from, LibRegister.getAddressId({ accountAddress: from }));
        assertEq(yonkData.to, LibRegister.getAddressId({ accountAddress: to }));
        assertEq(yonkData.claimed, false);
        assertEq(address(worldAddress).balance, startValue);
    }

    function test_RevertsWhen_FromNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo =
            YonkInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk{ value: 100 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function testFuzz_RevertsWhen_FromNotRegistered(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp
    )
        public
    {
        assumeValidPayableAddress(from);
        assumeValidPayableAddress(to);
        vm.assume(from != to);
        vm.assume(uint256(endValue) <= startValue);

        vm.prank(to);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk{ value: startValue }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_ToNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo =
            YonkInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk{ value: 100 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function testFuzz_RevertsWhen_ToNotRegistered(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp
    )
        public
    {
        assumeValidPayableAddress(from);
        assumeValidPayableAddress(to);
        vm.assume(from != to);
        vm.assume(uint256(endValue) <= startValue);

        vm.prank(from);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk{ value: startValue }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_EndValueGreaterThanStart() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo =
            YonkInfo({ endValue: 101, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YonkSystem.EndValueGreaterThanStart.selector);
        world.yonk{ value: 100 }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function testFuzz_RevertsWhen_EndValueGreaterThanStart(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp
    )
        public
    {
        assumeValidPayableAddress(from);
        assumeValidPayableAddress(to);
        vm.assume(from != to);
        vm.assume(uint256(endValue) > startValue);

        vm.prank(from);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(to);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YonkSystem.EndValueGreaterThanStart.selector);
        world.yonk{ value: startValue }({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_EncodingOverflows() public {
        YonkInfo memory yonkInfo = YonkInfo({ endValue: 2 ** 253, lifeSeconds: 0, to: 0 });
        vm.expectRevert(YonkSystem.UnsafeCast.selector);
        world.encodeYonkInfo({ yonkInfo: yonkInfo });
    }
}
