// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { IVUSD } from "src/IVUSD.sol";
import { VWND } from "src/VWND.sol";
import { VUSD } from "src/VUSD.sol";
import { vWNDVault } from "src/vWNDVault.sol";
import { Test, console } from "forge-std/Test.sol";

contract vWNDVaultTest is Test {
    VWND public vwnd;
    VUSD public vusd;
    vWNDVault public vwndVault;
    address public constant USER = address(1);
    uint256 public constant VWND_PRICE_AT_CREATION = 10e18;

    function setUp() public {
        vwnd = new VWND(USER);
        vusd = new VUSD(USER);
        vwndVault = new vWNDVault(address(vwnd), address(vusd), VWND_PRICE_AT_CREATION);
        vm.startPrank(USER);
        vusd.changeOwner(address(vwndVault));
        vm.stopPrank();
    }

    function test_VWNDOwner() public view {
        assertEq(address(vwnd.owner()), USER);
    }

    function test_VUSDOwner() public view {
        assertEq(address(vusd.owner()), address(vwndVault));
    }

    function test_VWNDVaultDepositAndMint() public {
        vm.startPrank(USER);
        vwnd.mint(USER, 1000000e18);
        vwnd.approve(address(vwndVault), 1000e18);
        vwndVault.deposit(1000e18);
        vwndVault.mint(100e18);
        vm.stopPrank();
        assertEq(vwnd.balanceOf(USER), 999000e18);
        assertEq(vusd.balanceOf(USER), 100e18);
    }
}