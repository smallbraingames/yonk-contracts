// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkTest } from "../YonkTest.t.sol";

import { YonkInfo } from "common/YonkInfo.sol";
import { LibEphemeralOwner } from "libraries/LibEphemeralOwner.sol";

contract LibEphemeralOwnerTest is YonkTest {
    function testFail_RevertsWhen_SetEphemeralOwnerFromNotSystem() public {
        vm.prank(address(0x1));
        LibEphemeralOwner.setEphemeralOwnerAddress(address(0));
    }

    function testFail_Fuzz_RevertsWhen_SetEphemeralOwnerFromNotSystem(address setter, address ephemeralOwner) public {
        vm.assume(setter != address(0));
        vm.expectRevert();
        vm.prank(setter);
        LibEphemeralOwner.setEphemeralOwnerAddress(ephemeralOwner);
    }

    function testFuzz_CorrectlyChecksEphemeralOwnerIsRegistered(
        address yonker,
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY,
        uint40 startValue,
        uint40 endValue,
        uint32 lifeSeconds,
        address ephemeralOwner,
        address otherAddress
    )
        public
    {
        assumeValidPayableAddress(yonker);
        vm.assume(lifeSeconds > 0);
        vm.assume(startValue > 0);
        vm.assume(endValue <= startValue);
        vm.assume(devicePublicKeyX > 0);
        vm.assume(devicePublicKeyY > 0);
        vm.assume(ephemeralOwner != address(0));
        vm.assume(ephemeralOwner != otherAddress);
        vm.assume(ephemeralOwner != yonker);

        YonkInfo memory yonkInfo =
            YonkInfo({ startValue: startValue, endValue: endValue, lifeSeconds: lifeSeconds, to: 0 });
        uint176 encodedYonkInfo = world.encodeYonkInfo({ yonkInfo: yonkInfo });
        mintAndApproveToken(yonker, startValue);
        vm.prank(yonker);
        world.registerAndYonkEphemeralOwner({
            devicePublicKeyX: devicePublicKeyX,
            devicePublicKeyY: devicePublicKeyY,
            dataCommitment: bytes32(uint256(123)),
            encodedYonkInfo: encodedYonkInfo,
            ephemeralOwner: ephemeralOwner
        });

        assertTrue(LibEphemeralOwner.isRegistered({ accountAddress: ephemeralOwner }));
        assertTrue(!LibEphemeralOwner.isRegistered({ accountAddress: otherAddress }));
    }
}
