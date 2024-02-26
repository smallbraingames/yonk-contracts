// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkSystem } from "../../src/systems/YonkSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";

import { EphemeralOwnerAddress, Yonk, YonkData } from "codegen/index.sol";
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
        YonkInfo memory yonkInfo = YonkInfo({
            startValue: 100,
            endValue: 0,
            lifeSeconds: 100,
            to: LibRegister.getAddressId({ accountAddress: b })
        });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(a, 100);
        vm.prank(a);
        uint64 yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });

        YonkData memory yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.dataCommitment, dataCommitment);
        assertEq(yonkData.startValue, 100);
        assertEq(yonkData.endValue, yonkInfo.endValue);
        assertEq(yonkData.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(yonkData.startTimestamp, block.timestamp);
        assertEq(yonkData.from, LibRegister.getAddressId({ accountAddress: a }));
        assertEq(yonkData.to, LibRegister.getAddressId({ accountAddress: b }));
        assertEq(yonkData.claimed, false);
        assertEq(token.balanceOf(worldAddress), 100);
        assertEq(yonkData.isToEphemeralOwner, false);
    }

    function testFuzz_CorrectlySetsYonk(
        address from,
        address to,
        uint40 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp,
        bool isToEphemeralOwner
    )
        public
    {
        assumeValidPayableAddress(from);
        assumeValidPayableAddress(to);
        vm.assume(from != to);
        vm.assume(uint256(endValue) <= startValue);
        vm.assume(startValue > 0);
        vm.assume(lifeSeconds > 0);

        vm.prank(from);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        vm.prank(to);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            startValue: startValue,
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(from, startValue);
        vm.warp(startTimestamp);
        uint64 yonkId;
        if (!isToEphemeralOwner) {
            vm.prank(from);
            yonkId = world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
        } else {
            vm.startPrank(from);
            yonkId = world.yonkEphemeralOwner({
                dataCommitment: dataCommitment,
                encodedYonkInfo: world.encodeYonkInfo({
                    yonkInfo: YonkInfo({ startValue: startValue, endValue: endValue, lifeSeconds: lifeSeconds, to: 0 })
                }),
                ephemeralOwner: to
            });
            vm.stopPrank();
        }

        YonkData memory yonkData = Yonk.get({ id: yonkId });
        assertEq(yonkData.dataCommitment, dataCommitment);
        assertEq(yonkData.startValue, startValue);
        assertEq(yonkData.endValue, yonkInfo.endValue);
        assertEq(yonkData.lifeSeconds, yonkInfo.lifeSeconds);
        assertEq(yonkData.startTimestamp, startTimestamp);
        assertEq(yonkData.from, LibRegister.getAddressId({ accountAddress: from }));
        assertEq(yonkData.claimed, false);
        assertEq(token.balanceOf(worldAddress), startValue);
        assertEq(yonkData.isToEphemeralOwner, isToEphemeralOwner);
        if (!isToEphemeralOwner) {
            assertEq(yonkData.to, LibRegister.getAddressId({ accountAddress: to }));
        } else {
            assertEq(EphemeralOwnerAddress.get({ id: yonkData.to }), to);
        }
    }

    function test_RevertsWhen_FromNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo = YonkInfo({
            startValue: 100,
            endValue: 0,
            lifeSeconds: 100,
            to: LibRegister.getAddressId({ accountAddress: b })
        });

        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(a, 100);

        vm.prank(a);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_ToNotRegistered() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo = YonkInfo({
            startValue: 100,
            endValue: 0,
            lifeSeconds: 100,
            to: LibRegister.getAddressId({ accountAddress: b })
        });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(a, 100);
        vm.prank(a);
        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_EndValueGreaterThanStart() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo = YonkInfo({
            startValue: 100,
            endValue: 101,
            lifeSeconds: 100,
            to: LibRegister.getAddressId({ accountAddress: b })
        });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(a, 100);
        vm.prank(a);
        vm.expectRevert(YonkSystem.EndValueGreaterThanStart.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
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
        vm.assume(startValue > 0);
        vm.assume(lifeSeconds > 0);

        vm.prank(from);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(to);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            startValue: startValue,
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        YonkInfo memory ephemeralYonkInfo =
            YonkInfo({ startValue: startValue, endValue: endValue, lifeSeconds: lifeSeconds, to: 0 });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        uint176 encodedEphemeralYonkInfo = world.encodeYonkInfo({ yonkInfo: ephemeralYonkInfo });

        mintAndApproveToken(from, startValue);

        vm.warp(startTimestamp);

        vm.prank(from);
        vm.expectRevert(YonkSystem.EndValueGreaterThanStart.selector);
        world.yonkEphemeralOwner({
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedEphemeralYonkInfo,
            ephemeralOwner: to
        });

        vm.prank(from);
        vm.expectRevert(YonkSystem.EndValueGreaterThanStart.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function test_RevertsWhen_EncodingOverflows() public {
        YonkInfo memory yonkInfo = YonkInfo({ startValue: 30, endValue: 2 ** 253, lifeSeconds: 0, to: 0 });
        vm.expectRevert(YonkSystem.UnsafeCast.selector);
        world.encodeYonkInfo({ yonkInfo: yonkInfo });
    }

    function test_RevertsWhen_ZeroValue() public {
        address a = address(0xface);
        address b = address(0xdead);

        vm.prank(a);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.prank(b);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        bytes32 dataCommitment = bytes32(uint256(123));
        YonkInfo memory yonkInfo = YonkInfo({
            startValue: 0,
            endValue: 0,
            lifeSeconds: 100,
            to: LibRegister.getAddressId({ accountAddress: b })
        });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        vm.prank(a);
        vm.expectRevert(YonkSystem.ZeroValue.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }

    function testFuzz_RevertsWhen_DuplicateEphemeralOwner(
        address from,
        address to,
        uint40 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        bytes32 dataCommitment,
        uint160 startTimestamp
    )
        public
    {
        assumeValidPayableAddress(from);
        vm.assume(from != to);
        vm.assume(uint256(endValue) <= startValue);
        vm.assume(startValue > 0);
        vm.prank(from);
        vm.assume(lifeSeconds > 0);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });

        YonkInfo memory yonkInfo = YonkInfo({
            startValue: startValue,
            endValue: endValue,
            lifeSeconds: lifeSeconds,
            to: LibRegister.getAddressId({ accountAddress: to })
        });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(from, startValue);
        vm.warp(startTimestamp);
        uint64 yonkId;
        vm.prank(from);
        yonkId = world.yonkEphemeralOwner({
            dataCommitment: dataCommitment,
            encodedYonkInfo: encodedYonkInfo,
            ephemeralOwner: to
        });

        vm.expectRevert(YonkSystem.EphemeralOwnerAlreadyExists.selector);
        vm.prank(from);
        world.yonkEphemeralOwner({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo, ephemeralOwner: to });
    }
}
