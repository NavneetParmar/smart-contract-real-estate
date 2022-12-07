// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LandContract {
    struct Land {
        address ownerAddress;
        string location;
        uint256 cost;
        uint256 landID;
        uint256 wantSell;
    }

    address public owner;
    uint256 public totalLandsCounter;

    //land addition event
    event AddLand(address _owner, uint256 _landID);
    event UpdateStatus(string _msg, uint256 _cost);

    //land transfer event
    event Transfer(address indexed _from, address indexed _to, uint256 _landID);
    // land Ether Transfer
    event EtherTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _cost
    );
    event Approval(
        address indexed _owner,
        address indexed _buyer,
        uint256 _landID,
        uint256 _amount
    );

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    //one account can hold many lands (many landTokens, each token one land)
    mapping(address => Land[]) public ownedLands;
    mapping(address => uint256) balance;
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public approvals;

    constructor(address _owner) {
        require(_owner == msg.sender);
        owner = payable(_owner);
        totalLandsCounter = 0;
    }

    receive() external payable {}

    //properties to be sold

    //1. FIRST OPERATION
    //owner shall add lands via this function
    function addLand(
        address _propertyOwner,
        string memory _location,
        uint256 _cost
    ) public isOwner {
        totalLandsCounter = totalLandsCounter + 1;
        Land memory myLand = Land({
            ownerAddress: _propertyOwner,
            location: _location,
            cost: _cost,
            landID: totalLandsCounter,
            wantSell: 1
        });

        ownedLands[msg.sender].push(myLand);
        emit AddLand(msg.sender, totalLandsCounter);
    }

    function transferEther(address _rec, uint256 _amount) public payable {
        payable(address(_rec)).transfer(_amount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalance(address _address) public view returns (uint256) {
        return address(_address).balance;
    }

    function approve(
        address _buyer,
        uint256 _landID,
        uint256 _amount
    ) public returns (bool success) {
        approvals[msg.sender][_buyer][_landID] = _amount;
        emit Approval(msg.sender, _buyer, _landID, _amount);
        return true;
    }

    //2. SECOND OPERATION
    //caller (owner/anyone) to transfer land to buyer provided caller is owner of the land

    function buy(Land memory _land, address _buyer)
        public
        payable
        returns (bool)
    {
        require(_land.cost <= approvals[msg.sender][_buyer][_land.landID]);
        require(address(_buyer).balance >= _land.cost, "Insufficient funds");

        return true;
    }

    function transferLand(address _landBuyer, uint256 _landID)
        public
        payable
        isOwner
        returns (bool)
    {
        //find out the particular land ID in owner's collectionexter
        for (uint256 i = 0; i < (ownedLands[msg.sender].length); i++) {
            //if given land ID is indeed in owner's collection
            if (ownedLands[msg.sender][i].landID == _landID) {
                Land memory myLand = Land({
                    ownerAddress: _landBuyer,
                    location: ownedLands[msg.sender][i].location,
                    cost: ownedLands[msg.sender][i].cost,
                    landID: _landID,
                    wantSell: ownedLands[msg.sender][i].wantSell
                });
                ownedLands[_landBuyer].push(myLand);

                // emit EtherTransfer(msg.sender,landBuyer,_ownedLands[msg.sender][i].cost);
                //remove land from current ownerAddress
                delete ownedLands[msg.sender][i];

                //inform the world
                emit Transfer(msg.sender, _landBuyer, _landID);

                return true;
            }
        }

        //if we still did not return, return false
        return false;
    }

    //3. THIRD OPERATION
    //get land details of an account
    function getLand(address _landHolder, uint256 _index)
        public
        view
        returns (
            string memory,
            uint256,
            address,
            uint256,
            uint256
        )
    {
        return (
            ownedLands[_landHolder][_index].location,
            ownedLands[_landHolder][_index].cost,
            ownedLands[_landHolder][_index].ownerAddress,
            ownedLands[_landHolder][_index].landID,
            ownedLands[_landHolder][_index].wantSell
        );
    }

    function getLandsByOwner(address _landHolder)
        public
        view
        returns (Land[] memory)
    {
        return ownedLands[_landHolder];
    }

    function getLandOfOwnerByLandID(uint256 _landID, address _landHolder)
        public
        view
        returns (Land memory)
    {
        Land memory land;
        for (uint256 i = 0; i < ownedLands[_landHolder].length; i++) {
            if (ownedLands[_landHolder][i].landID == _landID) {
                land = ownedLands[_landHolder][i];
            }
        }
        return land;
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    // REMOVE LAND FROM SALE

    function RemoveFromSale(address _landHolder, uint256 _landID)
        public
        isOwner
        returns (string memory)
    {
        uint256 indexer;

        for (
            indexer = 0;
            indexer < (ownedLands[_landHolder].length);
            indexer++
        ) {
            if (ownedLands[_landHolder][indexer].landID == _landID) {
                require(
                    ownedLands[_landHolder][indexer].wantSell != 0,
                    "PROPERTY ALREADY NOT FOR SALE"
                );
                ownedLands[_landHolder][indexer].wantSell = 0;
                return "OPERATION SUCCESSFULL";

                // if (ownedLands[_landHolder][indexer].wantSell == 1) {
                // } else {
                //     return "PROPERTY ALREADY NOT FOR SALE";
                // }
            }
        }

        return "INVALID LAND ID";
    }

    //4. GET TOTAL NO OF LANDS OWNED BY AN ACCOUNT AS NO WAY TO RETURN STRUCT ARRAYS
    function getNoOfLands(address _landHolder) public view returns (uint256) {
        return ownedLands[_landHolder].length;
    }
}
