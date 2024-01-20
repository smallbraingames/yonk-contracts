// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YonkSystem } from "../../src/systems/YonkSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";
import { RegisteredAddress, Registration, RegistrationData, Yonk, YonkData } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract RegisterSystemTest is YonkTest {
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
}
