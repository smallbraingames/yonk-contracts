// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkTest } from "../YonkTest.t.sol";

import { RegisteredAddress, Registration } from "codegen/index.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract LibRegisterTest is YonkTest {
    function test_IsRegisteredTrueWhenRegistered() public {
        address accountAddress = address(0xface);
        vm.prank(accountAddress);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        assertTrue(LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    /// forge-config: default.fuzz.runs = 2048
    function testFuzz_IsRegisteredTrueWhenRegistered(
        address accountAddressOne,
        address accountAddressTwo,
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY
    )
        public
    {
        vm.assume(accountAddressOne != address(0) && accountAddressTwo != address(0));
        vm.assume(accountAddressOne != accountAddressTwo);
        vm.assume(accountAddressOne != worldAddress);
        vm.assume(accountAddressTwo != worldAddress);

        vm.prank(accountAddressOne);
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        assertTrue(LibRegister.isRegistered({ accountAddress: accountAddressOne }));

        vm.prank(accountAddressTwo);
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        assertTrue(LibRegister.isRegistered({ accountAddress: accountAddressTwo }));
    }

    function test_IsRegisteredFalseWhenNoRegistrations() public {
        address accountAddress = address(0xface);
        assertTrue(!LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    /// forge-config: default.fuzz.runs = 2048
    function testFuzz_IsRegisteredFalseWhenNoRegistrations(address accountAddress) public {
        assertTrue(!LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    /// forge-config: default.fuzz.runs = 2048
    function testFuzz_IsRegisteredFalseForUnregisteredAddress(
        address registeredAddress,
        address unregisteredAddress
    )
        public
    {
        vm.assume(registeredAddress != address(0) && registeredAddress != address(0));
        vm.assume(registeredAddress != unregisteredAddress);
        vm.assume(registeredAddress != worldAddress);

        vm.prank(registeredAddress);
        world.register({ devicePublicKeyX: 1234, devicePublicKeyY: 5678 });

        assertTrue(!LibRegister.isRegistered({ accountAddress: unregisteredAddress }));
    }
}
