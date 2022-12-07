//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "./MeetToken.sol";
import "./DaiToken.sol";

contract LandContractManager {

    string public name = "MEET MANAGER SYSTEM";
    address payable public owner;
    TestDaiToken public daiInstance;
    MeetToken public meetInstance;
    //uint256 public totalSupply;
    //mapping(address => uint256) public balances;
    using SafeMath for uint256;

    event BoughtMeetToken(uint256 _daiAmountInvested, uint256 _crsipReceived, address _customer);
    event SoldMeetToken(uint256 _crsipAmountSold, uint256 _daiAmountReceived, address _customer);

    constructor(TestDaiToken _daiInstance, MeetToken _meetInstance){
        daiInstance = _daiInstance;
        meetInstance = _meetInstance;
        owner = payable(msg.sender);
    }

    function buy(uint256 daiAmount) external {
        uint256 xxxAmount = toCrsip(daiAmount);
        bool success = daiInstance.transferFrom(msg.sender, address(this), daiAmount);
        require(success,"Dai Transfer failed");
        success = meetInstance.transfer(msg.sender, xxxAmount);
        require(success,"Crsip transfer failed");
        emit BoughtMeetToken(daiAmount, xxxAmount, msg.sender);       
    }

    function sell(uint256 xxxAmount) external {
        uint256 daiAmount = toDAI(xxxAmount);       
        bool success = daiInstance.transfer(msg.sender, daiAmount);
        require(success, "Dai sell transfer failed");
        success = meetInstance.transferFrom(msg.sender, address(this), xxxAmount);
        require(success, "Crsip transfer failed");
        emit SoldMeetToken(xxxAmount, daiAmount, msg.sender);
    }

    function toMeet(uint256 daiAmount) internal pure returns (uint256) {
        // do some logic here
        return daiAmount;
    }

    function toDAI(uint256 xxxAmount) internal pure returns (uint256) {
        // do some logic here
        return xxxAmount;
    }
}