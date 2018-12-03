pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts
    // test that every modifier is working
    function testOnlyOwnerModifier() public {
      //instantiate contract
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //declare value
      uint expecter = 1;
      //test assertion
     Assert.equal(s.accessByOwner(), expected, "msg.sender should be the owner");
     //call via proxy; should return false
     bool proxyCallResult = p.accessByOwnerProxy(s);
     Assert.isFalse(proxyCallResult, "accessByOwner() should throw an exception when called by non-owner");
    }
    // buyItem
    // test for failure if user does not send enough funds
    function testItemPurchaseWithInsufficientFunds() public {
    //instantiate
    SupplyChain s = new SupplyChain();
    //add item
    s.addItem("first item", 100);
    //attempt to call buy item
    bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
    bool attemptedBuyCall = address(s).call.value(99)(functionSignature);
    //check assertion
    Assert.isFalse(attemptedBuyCall, "buyItem() should throw an exception");
  }


    // test for purchasing an item that is not for Sale
    function testItemPurchaseWhenNotForSale() public {
      //instantiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add item
      s.addItem("first item", 100);
      //buy via proxy
      p.buyProxy.value(100)(s);
      //attempt to call buy item on same item
      bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
      bool attemptedBuyCall = address(s).call.value(100)(functionSignature);
      //check assertion
      Assert.isFalse(attemptedBuyCall, "buyItem() should throw an exception");
    }



    // shipItem
    // test for calls that are made by not the seller
    function testShipItemNotFromSeller() public {
    //instantiate
    SupplyChain s = new SupplyChain();
    //add item
    s.addItem("first item", 100);
    //establish expected address (reconstructed tuple required here)
    (,,,,address expected,) = s.fetchItem(0);
    //check assertion
    Assert.equal(address(this), expected, "msg.sender should be the sender");
    }




    // test for trying to ship an item that is not marked Sold
    function testShipItemNotYetSold() public {
      //instantiate
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //attempt to ship item
      bytes memory functionSignature = padFunctionWithOneByteArgument("shipItem(uint256)", 0x00);
      bool attemptedShipCall = address(s).call(functionSignature);
      //establish expected value
      (,,,uint expected,,) = s.fetchItem(0); //expected state == 0 == State.ForSale
      //check assertions
      Assert.isFalse(attemptedShipCall, "shipItem() should throw an exception");
      Assert.equal(0, expected, "the state should be ForSale");
     }


    // receiveItem
    // test calling the function from an address that is not the buyer
    function testReceiveItemNotFromBuyer() public {
    //instantiate contracts
    SupplyChain s = new SupplyChain();
    ProxyTester p = new ProxyTester();
    //add an item
    s.addItem("first item", 100);
    //buy and ship item with ProxyTester
    p.buyProxy.value(100)(s);
    //ship item
    s.shipItem(0);
    //attempt to call receive item
    bytes memory functionSignature = padFunctionWithOneByteArgument("receiveItem(uint256)", 0x00);
    bool attemptedReceiveCall = address(s).call(functionSignature);
    //check assertion
    Assert.isFalse(attemptedReceiveCall, "receiveItem() should throw an exception");
    }



    // test calling the function on an item not marked Shipped

    function testReceiveItemNotYetShipped() public {
   //instantiate
   SupplyChain s = new SupplyChain();
   ProxyTester p = new ProxyTester();
   //add item via proxy
   p.addProxy(s);
   //buy item
   s.buyItem.value(100)(0);
   //attempt to call receive item
   bytes memory functionSignature = padFunctionWithOneByteArgument("receiveItem(uint256)", 0x00);
   bool attemptedReceiveCall = address(s).call(functionSignature);
   //check assertion
   Assert.isFalse(attemptedReceiveCall, "receiveItem() should throw an exception");
  }
