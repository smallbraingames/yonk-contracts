// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { YonkTest } from "../YonkTest.t.sol";
import { LibERC20 } from "libraries/LibERC20.sol";

contract LibERC20Test is YonkTest {
    function test_TransferTo() public {
        address from = address(this);

        address to = address(0xdead);
        uint256 amount = 100;

        token.mint(from, amount);

        assertEq(token.balanceOf(from), amount);

        LibERC20.transferTo(to, amount);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(to), amount);
    }

    function testFuzz_TransferTo(address to, uint256 amount) public {
        address from = address(this);
        assumeValidPayableAddress(to);
        vm.assume(amount > 0);

        token.mint(from, amount);

        assertEq(token.balanceOf(from), amount);

        LibERC20.transferTo(to, amount);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(to), amount);
    }

    function test_Collect() public {
        address from = address(0xface);
        uint256 amount = 100;

        token.mint(from, amount);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(from);
        token.approve(address(this), amount);

        LibERC20.collect(from, amount);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(this)), amount);
    }

    function testFuzz_Collect(address from, uint256 amount) public {
        assumeValidPayableAddress(from);
        vm.assume(amount > 0);

        token.mint(from, amount);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(from);
        token.approve(address(this), amount);

        LibERC20.collect(from, amount);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(this)), amount);
    }

    function testFail_Fuzz_CollectRevertsOnInsufficientBalance(
        address from,
        uint256 amount,
        uint256 mintedAmount
    )
        public
    {
        assumeValidPayableAddress(from);
        vm.assume(amount > 0);
        vm.assume(mintedAmount < amount);
        vm.assume(token.balanceOf(from) == 0);

        token.mint(from, mintedAmount);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(from);
        token.approve(address(this), amount);

        LibERC20.collect(from, amount);

        assertEq(token.balanceOf(from), mintedAmount);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testFail_Fuzz_CollectRevertsOnInsufficientApproval(
        address from,
        uint256 amount,
        uint256 approveAmount
    )
        public
    {
        assumeValidPayableAddress(from);
        vm.assume(amount > 0);
        vm.assume(approveAmount < amount);

        token.mint(from, amount);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(from);
        token.approve(address(this), approveAmount);

        LibERC20.collect(from, amount);

        assertEq(token.balanceOf(from), amount);
        assertEq(token.balanceOf(address(this)), 0);
    }
}
