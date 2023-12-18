// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellSystem } from "../../src/systems/YellSystem.sol";
import { YellTest } from "../YellTest.t.sol";

import { Yell, YellData } from "codegen/index.sol";
import { YellInfo } from "common/YellInfo.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract YellSystemTest is YellTest {
    function test_CorrectlySetsYell() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        uint256 dataCommitment = 123;
        YellInfo memory yellInfo =
            YellInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(a, 100);
        vm.prank(a);
        uint64 yellId = world.yell{ value: 100 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        YellData memory yellData = Yell.get({ id: yellId });
        assertEq(yellData.dataCommitment, dataCommitment);
        assertEq(yellData.startValue, 100);
        assertEq(yellData.endValue, yellInfo.endValue);
        assertEq(yellData.lifeSeconds, yellInfo.lifeSeconds);
        assertEq(yellData.startTimestamp, block.timestamp);
        assertEq(yellData.from, LibRegister.getAddressId({ accountAddress: a }));
        assertEq(yellData.to, LibRegister.getAddressId({ accountAddress: b }));
        assertEq(yellData.claimed, false);
        assertEq(address(worldAddress).balance, 100);
    }

    function testFuzz_CorrectlySetsYell(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        uint256 dataCommitment,
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

        YellInfo memory yellInfo = YellInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        uint64 yellId =
            world.yell{ value: startValue }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });

        YellData memory yellData = Yell.get({ id: yellId });
        assertEq(yellData.dataCommitment, dataCommitment);
        assertEq(yellData.startValue, startValue);
        assertEq(yellData.endValue, yellInfo.endValue);
        assertEq(yellData.lifeSeconds, yellInfo.lifeSeconds);
        assertEq(yellData.startTimestamp, startTimestamp);
        assertEq(yellData.from, LibRegister.getAddressId({ accountAddress: from }));
        assertEq(yellData.to, LibRegister.getAddressId({ accountAddress: to }));
        assertEq(yellData.claimed, false);
        assertEq(address(worldAddress).balance, startValue);
    }

    function test_RevertsWhen_FromNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        uint256 dataCommitment = 123;
        YellInfo memory yellInfo =
            YellInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YellSystem.NotRegistered.selector);
        world.yell{ value: 100 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function testFuzz_RevertsWhen_FromNotRegistered(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        uint256 dataCommitment,
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

        YellInfo memory yellInfo = YellInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YellSystem.NotRegistered.selector);
        world.yell{ value: startValue }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function test_RevertsWhen_ToNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        uint256 dataCommitment = 123;
        YellInfo memory yellInfo =
            YellInfo({ endValue: 0, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YellSystem.NotRegistered.selector);
        world.yell{ value: 100 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function testFuzz_RevertsWhen_ToNotRegistered(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        uint256 dataCommitment,
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

        YellInfo memory yellInfo = YellInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YellSystem.NotRegistered.selector);
        world.yell{ value: startValue }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function test_RevertsWhen_EndValueGreaterThanStart() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        uint256 dataCommitment = 123;
        YellInfo memory yellInfo =
            YellInfo({ endValue: 101, lifeSeconds: 100, to: LibRegister.getAddressId({ accountAddress: b }) });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(a, 100);
        vm.prank(a);
        vm.expectRevert(YellSystem.EndValueGreaterThanStart.selector);
        world.yell{ value: 100 }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function testFuzz_RevertsWhen_EndValueGreaterThanStart(
        address from,
        address to,
        uint256 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        uint256 dataCommitment,
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

        YellInfo memory yellInfo = YellInfo({
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint136 encodedYellInfo = world.encodeYellInfo({ yellInfo: yellInfo });
        vm.deal(from, startValue);
        vm.warp(startTimestamp);
        vm.prank(from);
        vm.expectRevert(YellSystem.EndValueGreaterThanStart.selector);
        world.yell{ value: startValue }({ dataCommitment: dataCommitment, encodedYellInfo: encodedYellInfo });
    }

    function test_RevertsWhen_EncodingOverflows() public {
        YellInfo memory yellInfo = YellInfo({ endValue: 2 ** 253, lifeSeconds: 0, to: 0 });
        vm.expectRevert(YellSystem.UnsafeCast.selector);
        world.encodeYellInfo({ yellInfo: yellInfo });
    }
}
