// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "src/ERC20.sol";

contract VUSD is ERC20("vUSD", "vUSD", 18) {
    address public owner;

    constructor(address _owner) { owner = _owner; }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function mint(address to,   uint amount) public onlyOwner { _mint(to,   amount); }
    function burn(address from, uint amount) public onlyOwner { _burn(from, amount); }
    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}