// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract ItemsSupplyChain {

    address private ownerContract;
    uint private id;

    // Define enum 'State' with the following values:
    enum State
      {
        ProduceByFarmer,         // 0 Produced by the farmer.
        ForSaleByFarmer,         // 1 For sale by farmer.
        PurchasedByDistributor,  // 2 Bought by distributor.
        ShippedByFarmer,         // 3 Sent by farmer.
        ReceivedByDistributor,   // 4 Received by distributor.
        ProcessedByDistributor,  // 5 Processed by distributor
        PackageByDistributor,    // 6 Packaged by distributor.
        ForSaleByDistributor,    // 7 For sale by distributor.
        PurchasedByRetailer,     // 8 Bought by retailer.
        ShippedByDistributor,    // 9 Sent by distributor.
        ReceivedByRetailer,      // 10 Received by retailer.
        ForSaleByRetailer,       // 11 For sale by retailer.
        PurchasedByConsumer      // 12 Bought by consumer.
    }

    function nextState(State _state) pure private returns(State){
        if(_state == State.ProduceByFarmer) {
            return State.ForSaleByFarmer;
        }else if(_state == State.ForSaleByFarmer){
            return State.PurchasedByDistributor;
        }else if(_state == State.PurchasedByDistributor){
            return State.ShippedByFarmer;
        }else if(_state == State.ShippedByFarmer){
            return State.ReceivedByDistributor;            
        }else if(_state == State.ReceivedByDistributor){
            return State.ProcessedByDistributor;
        }else if(_state == State.ProcessedByDistributor){
            return State.PackageByDistributor;
        }else if(_state == State.PackageByDistributor){
            return State.ForSaleByDistributor;
        }else if(_state == State.ForSaleByDistributor){
            return State.PurchasedByRetailer;
        }else if(_state == State.PurchasedByRetailer){
            return State.ShippedByDistributor;
        }else if(_state == State.ShippedByDistributor){
            return State.ReceivedByRetailer;
        }else if(_state == State.ReceivedByRetailer){
            return State.ForSaleByRetailer;
        }else {
            return State.PurchasedByConsumer;
        }
    }


    State constant defaultState = State.ProduceByFarmer;

    struct Item {    
        address owner;        
        string name;
        uint time;
        State   itemState;
        string description;
    }

    mapping(uint => Item) private items;

    constructor () public {
        ownerContract = msg.sender;
        id = 0;
    }

    function getOwnerContract() public view returns (address){
        return ownerContract;
    }

    function harvestItem(string memory _name, string memory _description) public {
        id++; // increment the id.
        items[id] = Item(msg.sender,_name,block.timestamp,defaultState, _description);        
    }

    function getItem(uint _id) public view returns(address,string memory,uint,State,string memory){
        require(_id <= id && _id > 0, "Error: Product not registered!" );
        return (items[_id].owner,
                items[_id].name,
                items[_id].time,
                items[_id].itemState,
                items[_id].description);
    }

    function getTotalItems() public view returns(uint){
        return id;
    }


    function nextStepProcess(uint _id, address _nextOwner) public returns(bool) {
        require(_id <= id && _id > 0, "Error: Product not registered!" );
        require(msg.sender == items[_id].owner, "Error: Must be the owner of the item.");
        require(items[_id].itemState < State.PurchasedByConsumer, "Error: The product has already reached the last step of the chain.");
        items[_id].owner = _nextOwner;
        items[_id].itemState = nextState(items[_id].itemState);
        return true;
    }

}
