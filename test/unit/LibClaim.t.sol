// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { YellTest, console } from "../YellTest.t.sol";

import { stdJson } from "forge-std/StdJson.sol";
import { LibClaim } from "libraries/LibClaim.sol";

using stdJson for string;

contract LibClaimTest is YellTest {
    function test_IsAliveTrueWhenAlive() public {
        assertTrue(LibClaim.isAlive({ startTimestamp: block.timestamp, lifeSeconds: 100 }));
        assertTrue(LibClaim.isAlive({ startTimestamp: block.timestamp, lifeSeconds: 1 }));
        vm.warp(100);
        assertTrue(LibClaim.isAlive({ startTimestamp: 0, lifeSeconds: 101 }));
    }

    function testFuzz_IsAliveTrueWhenAlive(uint256 startTimestamp, uint32 timePassed, uint32 lifeSeconds) public {
        startTimestamp = bound(startTimestamp, 0, 1e15);
        vm.assume(timePassed < lifeSeconds);
        vm.warp(uint256(startTimestamp) + uint256(timePassed));
        assertTrue(LibClaim.isAlive({ startTimestamp: startTimestamp, lifeSeconds: lifeSeconds }));
    }

    function test_IsAliveFalseWhenNotAlive() public {
        assertTrue(!LibClaim.isAlive({ startTimestamp: block.timestamp, lifeSeconds: 0 }));
        vm.warp(100);
        assertTrue(!LibClaim.isAlive({ startTimestamp: 0, lifeSeconds: 99 }));
    }

    function testFuzz_IsAliveFalseWhenNotAlive(uint256 startTimestamp, uint32 timePassed, uint32 lifeSeconds) public {
        startTimestamp = bound(startTimestamp, 0, 1e15);
        vm.assume(timePassed >= lifeSeconds);
        vm.warp(uint256(startTimestamp) + uint256(timePassed));
        assertTrue(!LibClaim.isAlive({ startTimestamp: startTimestamp, lifeSeconds: lifeSeconds }));
    }

    function test_VerifySignature() public {
        // P256 Vectors generated in test/p256-test-vectors/gen.ts
        string memory file = "./test/p256-test-vectors/vectors_random_valid.jsonl";

        while (true) {
            string memory vector = vm.readLine(file);
            if (bytes(vector).length == 0) {
                break;
            }
            uint256 x = uint256(vector.readBytes32(".x"));
            uint256 y = uint256(vector.readBytes32(".y"));
            uint256 r = uint256(vector.readBytes32(".r"));
            uint256 s = uint256(vector.readBytes32(".s"));
            bytes32 data = vector.readBytes32(".data");
            bytes32 messageHash = sha256(abi.encodePacked(data));
            assertTrue(LibClaim.isValidSignature({ messageHash: messageHash, r: r, s: s, x: x, y: y }));
            assertFalse(LibClaim.isValidSignature({ messageHash: messageHash, r: r, s: s, x: x + 1, y: y }));
        }
    }

    function test_GetYellAmount() public {
        assertEq(
            LibClaim.getYellAmount({ startValue: 100, endValue: 0, startTimestamp: block.timestamp, lifeSeconds: 10 }),
            100
        );
        assertEq(
            LibClaim.getYellAmount({
                startValue: 500,
                endValue: 500,
                startTimestamp: block.timestamp - 99,
                lifeSeconds: 100
            }),
            500
        );
        assertEq(
            LibClaim.getYellAmount({
                startValue: 500,
                endValue: 0,
                startTimestamp: block.timestamp - 100,
                lifeSeconds: 500
            }),
            400
        );
    }

    function testFuzz_GetYellAmount(uint160 yellAmount, uint160 startValue, uint160 endValue) public {
        vm.assume(startValue >= yellAmount);
        vm.assume(endValue <= yellAmount);
        vm.assume(uint256(startValue) - uint256(yellAmount) < 1e15);
        uint256 diff = uint256(startValue) - uint256(yellAmount);
        uint256 lifeSeconds = uint256(startValue) - uint256(endValue);
        if (lifeSeconds == 0) lifeSeconds++;
        vm.warp(diff + 10);
        assertEq(
            LibClaim.getYellAmount({
                startValue: startValue,
                endValue: endValue,
                startTimestamp: 10,
                lifeSeconds: lifeSeconds
            }),
            yellAmount
        );
    }
}
