// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RealEstate.sol";

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Escrow {
    address public nftAddress;
    address public buyer;
    address public seller;
    uint256 public nftID;
    uint256 public purchasePrice;
    uint256 public escrowAmount;
    address public inspector;
    address public lender;
    bool inspectionPassed = false;
    mapping(address => bool) public approval;

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier onlyInspector() {
        require(
            msg.sender == inspector,
            "Only inspector can call this function"
        );
        _;
    }

    constructor(
        address _nftAddress,
        address payable _seller,
        address payable _buyer,
        uint256 _nftID,
        uint256 _purchasePrice,
        uint256 _escrowAmount,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        buyer = _buyer;
        nftID = _nftID;
        purchasePrice = _purchasePrice;
        escrowAmount = _escrowAmount;
        inspector = _inspector;
        lender = _lender;
    }

    function buyerPay() public payable onlyBuyer {
        require(msg.value >= escrowAmount, "Insufficient funds");
    }

    function updateInspectionStatus(bool _passed) public onlyInspector {
        inspectionPassed = _passed;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function approveSale() public {
        approval[msg.sender] = true;
    }

    function finalizeSale() public {
        require(inspectionPassed, "Must pass inspection");
        require(approval[buyer], "Must be approved by buyer");
        require(approval[seller], "Must be approved by seller");
        require(approval[lender], "Must be approved by lender");
        require(
            address(this).balance >= purchasePrice,
            "Must have enough ether for sale"
        );

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);

        //transfer ownership of property
        IERC721(nftAddress).transferFrom(seller, buyer, nftID);
    }
}
