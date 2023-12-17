// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest } from "../YellTest.t.sol";
import { RegisteredAddress, Registration, RegistrationData } from "codegen/index.sol";

contract RegisterSystemTest is YellTest {
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
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        RegistrationData memory registration = Registration.get(1);
        assertEq(registration.devicePublicKeyX, devicePublicKeyX);
        assertEq(registration.devicePublicKeyY, devicePublicKeyY);
        assertEq(RegisteredAddress.get(1), sender);
    }
}
