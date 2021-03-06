  pragma solidity ^0.4.24;

import "../coffeecore/Ownable.sol";

// Define a contract 'Supplychain'
contract SupplyChain is Ownable {

  // Define 'owner'
  //address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Harvested,    // 0
    Hulled,       // 1
    Dried,        // 2
    CropPacked,   // 3
    CropForSale,  // 4
    InterItem,    // 5
    InterForSale, // 6
    RoastItem,    // 7
    Roasted,      // 8
    RoastPacked,  // 9
    RoastForSale, // 10
    RetailerItem, // 11
    ForSale,      // 12
    Purchased     // 13
    }

  State constant defaultState = State.Harvested;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Grower, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 10 stages
    address originGrowerID; // Metamask-Ethereum address of the Grower
    string  originGrowerName; // Grower Name
    string  originGrowerInformation;  // Grower Information
    string  originGrowerLatitude; // Grower Latitude
    string  originGrowerLongitude;  // Grower Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address intermediaryID; // Metamask-Ethereum address of the Intermediary
    address roasterID;  // Metamask-Ethereum address of the Roaster
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 13 events with the same 13 state values and accept 'upc' as input argument
  event Harvested(uint upc);
  event Hulled(uint upc);
  event Dried(uint upc);
  event CropPacked(uint upc);
  event CropForSale(uint upc);
  event InterItem(uint upc);
  event InterForSale(uint upc);
  event RoastItem(uint upc);
  event Roasted(uint upc);
  event RoastPacked(uint upc);
  event RoastForSale(uint upc);
  event RetailerItem(uint upc);
  event ForSale(uint upc);
  event Purchased(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  // modifier onlyOwner() {
  //   require(msg.sender == owner);
  //   _;
  // }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _upc) { 
    uint _price = items[_upc].productPrice;
    require(msg.value >= _price, 'Insufficient Payment'); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    //items[_upc].consumerID.transfer(amountToReturn);
    msg.sender.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Harvested
  modifier harvested(uint _upc) {
    require(items[_upc].itemState == State.Harvested);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Hulled
  modifier hulled(uint _upc) {
    require(items[_upc].itemState == State.Hulled);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Dried
  modifier dried(uint _upc) {
    require(items[_upc].itemState == State.Dried);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is CropPacked
  modifier cropPacked(uint _upc) {
    require(items[_upc].itemState == State.CropPacked);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is CropForSale
  modifier cropForSale(uint _upc) {
    require(items[_upc].itemState == State.CropForSale, 'Crop is not for sale');
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is InterItem
  modifier interItem(uint _upc) {
    require(items[_upc].itemState == State.InterItem);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is InterForSale
  modifier interForSale(uint _upc) {
    require(items[_upc].itemState == State.InterForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RoastItem
  modifier roastItem(uint _upc) {
    require(items[_upc].itemState == State.RoastItem);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Roasted
  modifier roasted(uint _upc) {
    require(items[_upc].itemState == State.Roasted);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RoastPacked
  modifier roastPacked(uint _upc) {
    require(items[_upc].itemState == State.RoastPacked);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RoastForSale
  modifier roastForSale(uint _upc) {
    require(items[_upc].itemState == State.RoastForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RetailerItem
  modifier retailerItem(uint _upc) {
    require(items[_upc].itemState == State.RetailerItem);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased);
    _;
  }

  // Check input parameter is not empty
  modifier hasUPC(uint _upc) {
    require(_upc > 0, 'UPC cannot be empty or 0');
    _;
  }
  

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    //owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public onlyOwner {
      selfdestruct(msg.sender);
  }

  // Define a function 'harvestItem' that allows a grower to mark an item 'Harvested'
  function harvestItem(uint _upc, address _originGrowerID, string _originGrowerName, 
    string _originGrowerInformation, string  _originGrowerLatitude, string  _originGrowerLongitude, 
    string  _productNotes) public hasUPC(_upc)
  {
    
    require(_originGrowerID > 0x0, 'Grower ID cannot be empty');
    require(bytes(_originGrowerName).length > 0, 'Grower name cannot be empty');
    require(bytes(_originGrowerLatitude).length > 0, 'Grower latitude cannot be empty');
    require(bytes(_originGrowerLongitude).length > 0, 'Grower longitude cannot be empty');

    Item memory harvestedOne;
    
    harvestedOne.upc = _upc;
    harvestedOne.sku = sku;
    harvestedOne.productID = sku + _upc;
    harvestedOne.originGrowerID = _originGrowerID;
    harvestedOne.originGrowerName = _originGrowerName;
    harvestedOne.originGrowerInformation = _originGrowerInformation;
    harvestedOne.originGrowerLatitude = _originGrowerLatitude;
    harvestedOne.originGrowerLongitude = _originGrowerLongitude;
    harvestedOne.productNotes = _productNotes;
    harvestedOne.itemState = State.Harvested;
    harvestedOne.ownerID = _originGrowerID;
    
    items[_upc] = harvestedOne;

    // Increment sku
    sku = sku + 1;
    
    // Emit the appropriate event
    emit Harvested(_upc); 
  }

  // Define a function 'hullItem' that allows a grower to mark an item 'Hulled'
  function hullItem(uint _upc) public hasUPC(_upc) harvested(_upc) onlyGrower()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Hulled;
    
    // Emit the appropriate event
    emit Hulled(_upc);
  }

  // Define a function 'dryItem' that allows a grower to mark an item 'Dried'
  function dryItem(uint _upc) public hasUPC(_upc) hulled(_upc) onlyGrower()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Dried;
    
    // Emit the appropriate event
    emit Dried(_upc);
  }

  // Define a function 'cropPackItem' that allows a grower to mark an item 'CropPacked'
  function cropPackItem(uint _upc) public hasUPC(_upc) dried(_upc) onlyGrower()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.CropPacked;
    
    // Emit the appropriate event
    emit CropPacked(_upc);
  }

  // Define a function 'sellCropItem' that allows a grower to mark an item 'CropForSale'
  function sellCropItem(uint _upc, uint _price) public hasUPC(_upc) cropPacked(_upc) onlyGrower() 
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].productPrice = _price;
    items[_upc].itemState = State.CropForSale;
    // Emit the appropriate event
    emit CropForSale(_upc);
  }

  // Define a function 'buyCropItem' that allows the Intermediary to mark an item 'InterItem'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyCropItem(uint _upc) payable public hasUPC(_upc) onlyIntermediary() paidEnough(_upc) checkValue(_upc)
    
    //Call modifer to check if buyer has paid enough
    
   // Call modifer to send any excess ether back to buyer
   {
    
    // Update the appropriate fields - ownerID, intermediaryID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].intermediaryID = msg.sender;
    items[_upc].itemState = State.InterItem;

    // Transfer money to grower
    items[_upc].originGrowerID.transfer(items[_upc].productPrice);
    //emit the appropriate event
    emit InterItem(_upc);

  }


  // Define a function 'sellInterItem' that allows a grower to mark an item 'InterForSale'
  function sellInterItem(uint _upc, uint _price) public hasUPC(_upc) interItem(_upc) onlyIntermediary()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].productPrice = _price;
    items[_upc].itemState = State.InterForSale;
    // Emit the appropriate event
    emit InterForSale(_upc);
  }

  // Define a function 'buyInterItem' that allows the Intermediary to mark an item 'RoastItem'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyInterItem(uint _upc)  payable 
    public hasUPC(_upc) interForSale(_upc) onlyRoaster() paidEnough(_upc) checkValue(_upc)
    
    // Call modifer to check if buyer has paid enough
    
    // Call modifer to send any excess ether back to buyer
    
    {
    
    // Update the appropriate fields - ownerID, intermediaryID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].roasterID = msg.sender;
    items[_upc].itemState = State.RoastItem;

    // Transfer money to intermediary
    items[_upc].intermediaryID.transfer(items[_upc].productPrice);
    // emit the appropriate event
    emit RoastItem(_upc);
  }

  // Define a function 'roast' that allows a Roaster to mark an item 'Roasted'
  function roast(uint _upc) public hasUPC(_upc) roastItem(_upc) onlyRoaster()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Roasted;
    
    // Emit the appropriate event
    emit Roasted(_upc);
  }

  // Define a function 'roastPack' that allows a roaster to mark an item 'RoastPacked'
  function roastPack(uint _upc) public hasUPC(_upc) roasted(_upc) onlyRoaster()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.RoastPacked;
    
    // Emit the appropriate event
    emit RoastPacked(_upc);
  }

  // Define a function 'sellRoastItem' that allows a roaster to mark an item 'RoastForSale'
  function sellRoastItem(uint _upc, uint _price) public hasUPC(_upc) roastPacked(_upc) onlyRoaster()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].productPrice = _price;
    items[_upc].itemState = State.RoastForSale;
    // Emit the appropriate event
    emit RoastForSale(_upc);
  }

  // Define a function 'buyRoastItem' that allows the Retailer to mark an item 'RetailerItem'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyRoastItem(uint _upc) payable 
    public hasUPC(_upc) roastForSale(_upc) onlyRetailer() paidEnough(_upc) checkValue(_upc)
    
    // Call modifer to check if buyer has paid enough
    
    // Call modifer to send any excess ether back to buyer
    
    {
    
    // Update the appropriate fields - ownerID, intermediaryID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].retailerID = msg.sender;
    items[_upc].itemState = State.RetailerItem;

    // Transfer money to intermediary
    items[_upc].roasterID.transfer(items[_upc].productPrice);
    // emit the appropriate event
    emit RetailerItem(_upc);
  }

  // Define a function 'sellItem' that allows a retailer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public hasUPC(_upc) retailerItem(_upc) onlyRetailer()
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].productPrice = _price;
    items[_upc].itemState = State.ForSale;
    // Emit the appropriate event
    emit ForSale(_upc);
  }
  
  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc) payable 
    public hasUPC(_upc) forSale(_upc) onlyConsumer() paidEnough(_upc) checkValue(_upc)
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].consumerID = msg.sender;
    items[_upc].itemState = State.Purchased;    
    // Emit the appropriate event
    emit Purchased(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view hasUPC(_upc) returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originGrowerID,
  string  originGrowerName,
  string  originGrowerInformation,
  string  originGrowerLatitude,
  string  originGrowerLongitude
  ) 
  {
  // Assign values to the 8 parameters
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  ownerID = items[_upc].ownerID;
  originGrowerID = items[_upc].originGrowerID;
  originGrowerName = items[_upc].originGrowerName;
  originGrowerInformation = items[_upc].originGrowerInformation;
  originGrowerLatitude = items[_upc].originGrowerLatitude;
  originGrowerLongitude = items[_upc].originGrowerLongitude;

  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originGrowerID,
  originGrowerName,
  originGrowerInformation,
  originGrowerLatitude,
  originGrowerLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view hasUPC(_upc) returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  State    itemState,
  address intermediaryID,
  address roasterID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 10 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    productID = items[_upc].productID;
    productNotes = items[_upc].productNotes;
    productPrice = items[_upc].productPrice;
    itemState = items[_upc].itemState;
    intermediaryID = items[_upc].intermediaryID;
    roasterID = items[_upc].roasterID;
    retailerID = items[_upc].retailerID;
    consumerID = items[_upc].consumerID;
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  intermediaryID,
  roasterID,
  retailerID,
  consumerID
  );
  }
}
