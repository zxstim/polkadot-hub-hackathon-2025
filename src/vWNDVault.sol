// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "src/ERC20.sol";
import {IVUSD} from "src/IVUSD.sol";

contract vWNDVault {
  uint public constant MIN_COLLAT_RATIO = 1.5e18;

  ERC20 public vwnd;
  IVUSD public vusd;

  uint256 constant yield = 3e14; // yield per second 0.0000003
  uint256 public vaultCreationTime;
  uint256 public vWNDPriceAtCreation;
                          
  mapping(address => uint) public addressToDeposit;
  mapping(address => uint) public addressToMinted;

  constructor(address _vwnd, address _vusd, uint256 _vWNDPriceAtCreation) {
    vwnd = ERC20(_vwnd);
    vusd = IVUSD(_vusd);
    vaultCreationTime = block.timestamp;
    vWNDPriceAtCreation = _vWNDPriceAtCreation;
  }

  function deposit(uint amount) public {
    vwnd.transferFrom(msg.sender, address(this), amount);
    addressToDeposit[msg.sender] += amount;
  }

  function burn(uint amount) public {
    addressToMinted[msg.sender] -= amount;
    vusd.burn(msg.sender, amount);
  }

  function mint(uint amount) public {
    addressToMinted[msg.sender] += amount;
    require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
    vusd.mint(msg.sender, amount);
  }

  function withdraw(uint amount) public {
    addressToDeposit[msg.sender] -= amount;
    require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
    vwnd.transfer(msg.sender, amount);
  }

  function liquidate(address user) public {
    require(collateralRatio(user) < MIN_COLLAT_RATIO);
    vusd.burn(msg.sender, addressToMinted[user]);
    vwnd.transfer(msg.sender, addressToDeposit[user]);
    addressToDeposit[user] = 0;
    addressToMinted[user] = 0;
  }

  function getVWNDCurrentPrice() public view returns (uint256) {
    // calculate how many seconds have passed since the vault was created
    uint256 secondsPassed = block.timestamp - vaultCreationTime;
    // calculate the current price of vWND
    uint256 vWNDCurrentPrice = (secondsPassed * yield) + vWNDPriceAtCreation;
    return vWNDCurrentPrice;
  }

  function collateralRatio(address user) public view returns (uint) {
    uint minted = addressToMinted[user];
    if (minted == 0) return type(uint256).max;
    uint256 totalValue = addressToDeposit[user] * getVWNDCurrentPrice();
    return totalValue / minted;
  }
}