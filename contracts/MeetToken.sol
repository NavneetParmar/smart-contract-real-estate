//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MeetToken is ERC20, AccessControl {
    address payable public owner;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Initial supply = 1 Billion = 10^27 === 1000000000000000000000000000
    constructor(uint256 initialSupply)
        ERC20("YOur token", "Symbol(for ex. Dai)")
    {
        owner = payable(msg.sender);
        _mint(msg.sender, initialSupply);
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
