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
}
