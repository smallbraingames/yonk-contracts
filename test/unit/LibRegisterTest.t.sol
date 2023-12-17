// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest } from "../YellTest.t.sol";
import { LibRegister } from "libraries/LibRegister.sol";

contract LibRegisterTest is YellTest {
    function test_IsRegisteredTrueWhenRegistered() public {
        address accountAddress = address(0xface);
        vm.prank(accountAddress);
        world.register({ devicePublicKeyX: 234, devicePublicKeyY: 345 });
        assertTrue(LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    function testFuzz_IsRegisteredTrueWhenRegistered(
        address accountAddress,
        uint256 devicePublicKeyX,
        uint256 devicePublicKeyY
    )
        public
    {
        vm.assume(accountAddress != address(0));
        vm.prank(accountAddress);
        world.register({ devicePublicKeyX: devicePublicKeyX, devicePublicKeyY: devicePublicKeyY });
        assertTrue(LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    function test_IsRegisteredFalseWhenNoRegistrations() public {
        address accountAddress = address(0xface);
        assertTrue(!LibRegister.isRegistered({ accountAddress: accountAddress }));
    }

    function testFuzz_IsRegisteredFalseWhenNoRegistrations(address accountAddress) public {
        assertTrue(!LibRegister.isRegistered({ accountAddress: accountAddress }));
    }
}