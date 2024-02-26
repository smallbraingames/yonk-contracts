// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { RegisterSystem } from "../../src/systems/RegisterSystem.sol";
import { YonkTest } from "../YonkTest.t.sol";
import { RegisteredAddress, Registration, RegistrationData } from "codegen/index.sol";

contract RegisterSystemTest is YonkTest {
    function test_RegistersCorrectly() public {
        address sender = address(0xface);
        uint256 devicePublicKeyX = 234;
        uint256 devicePublicKeyY = 345;
        vm.prank(sender);
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegistrationData memory registration = Registration.get(1);
        assertEq(registration.devicePublicKeyX, devicePublicKeyX);
        assertEq(registration.devicePublicKeyY, devicePublicKeyY);
        assertEq(RegisteredAddress.get(1), sender);
    }

    function testFuzz_RegistersCorrectly(uint256 devicePublicKeyX, uint256 devicePublicKeyY, address sender) public {
        vm.prank(sender);
        vm.assume(sender != address(world));
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegistrationData memory registration = Registration.get(1);
        assertEq(registration.devicePublicKeyX, devicePublicKeyX);
        assertEq(registration.devicePublicKeyY, devicePublicKeyY);
        assertEq(RegisteredAddress.get(1), sender);
    }

    function test_RevertsWhen_DuplicateRegister() public {
        address sender = address(0xface);
        vm.prank(sender);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.expectRevert(RegisterSystem.AlreadyRegistered.selector);
        vm.prank(sender);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
    }

    function testFuzz_RevertsWhen_DuplicateRegister(
        address register,
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY
    )
        public
    {
        vm.prank(register);
        vm.assume(register != address(world));
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        vm.expectRevert(RegisterSystem.AlreadyRegistered.selector);
        vm.prank(register);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        vm.expectRevert(RegisterSystem.AlreadyRegistered.selector);
        vm.prank(register);
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
    }

    function testFuzz_IncrementsSequentialRegistrations(
        address[] memory registrations,
        uint256[] memory devicePublicKeyXRaw,
        uint256[] memory devicePublicKeyYRaw
    )
        public
    {
        vm.assume(registrations.length < 100);
        for (uint256 i = 0; i < registrations.length; i++) {
            for (uint256 j = i + 1; j < registrations.length; j++) {
                vm.assume(registrations[i] != registrations[j]);
            }
        }
        uint256[] memory devicePublicKeyX = new uint256[](registrations.length);
        uint256[] memory devicePublicKeyY = new uint256[](registrations.length);
        for (uint256 i = 0; i < registrations.length; i++) {
            if (i < devicePublicKeyXRaw.length) {
                devicePublicKeyX[i] = devicePublicKeyXRaw[i];
            } else {
                devicePublicKeyX[i] = 234;
            }
            if (i < devicePublicKeyYRaw.length) {
                devicePublicKeyY[i] = devicePublicKeyYRaw[i];
            } else {
                devicePublicKeyY[i] = 345;
            }
        }

        for (uint256 i = 0; i < registrations.length; i++) {
            vm.prank(registrations[i]);
            vm.assume(registrations[i] != address(world));
            world.register({ devicePublicKeyX: devicePublicKeyX[i], devicePublicKeyY: devicePublicKeyY[i] });
            RegistrationData memory registration = Registration.get(uint64(i + 1));
            assertEq(registration.devicePublicKeyX, devicePublicKeyX[i]);
            assertEq(registration.devicePublicKeyY, devicePublicKeyY[i]);
            assertEq(RegisteredAddress.get(uint64(i + 1)), registrations[i]);
        }
    }
}
