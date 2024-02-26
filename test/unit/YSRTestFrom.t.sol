// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkSystem } from "../../src/systems/YonkSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";

import { EphemeralOwnerAddress, Yonk, YonkData } from "codegen/index.sol";
import { YonkInfo } from "common/YonkInfo.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract YonkFuzzFromSystemRegistrationTest is YonkTest {
    function testFuzz_RevertsWhen_FromNotRegistered(
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
        assumeValidPayableAddress(to);
        startValue = uint40(bound(startValue, 1, 4_000_000));
        endValue = uint40(bound(endValue, 0, startValue - 1));
        lifeSeconds = uint32(bound(lifeSeconds, 1, 1_000_000));
        vm.assume(from != to);

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
        vm.prank(from);

        vm.expectRevert(YonkSystem.NotRegistered.selector);
        world.yonk({ dataCommitment: dataCommitment, encodedYonkInfo: encodedYonkInfo });
    }
}
