// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ownable.sol";

contract DealEstate is Ownable {
  
  struct Estate {
    string name;
    string place;
    uint price; //wei = 
  }

  Estate[] public estates;
  uint releaseCount = 0;

  mapping (uint => address) public estateToOwner;
  mapping (uint => bool) public estateIsRelease;
  mapping (address => uint) ownerEstateCount;

  function registerEstate(string memory _name, string memory _place, uint _price) public {
    estates.push(Estate(_name, _place, _price));
    uint id = estates.length - 1;
    estateToOwner[id] = msg.sender;
    ownerEstateCount[msg.sender]++;
    estateIsRelease[id] = false;
  }

  function changePrice(uint _key, uint _newPrice) public {
    require(msg.sender == estateToOwner[_key]);
    estates[_key].price = _newPrice;
  }

  function release(uint _key) public {
    require(msg.sender == estateToOwner[_key]);
    require(!estateIsRelease[_key]);
    estateIsRelease[_key] = true;
    releaseCount++;
  }

  function unrelease(uint _key) public {
    require(msg.sender == estateToOwner[_key]);
    require(estateIsRelease[_key]);
    estateIsRelease[_key] = false;
    releaseCount--;
  }

  function _changeOwner(uint _key) internal {
    ownerEstateCount[estateToOwner[_key]]--;
    estateToOwner[_key] = msg.sender;
    ownerEstateCount[msg.sender]++;
  }

  function payPrice(uint _key) public payable {
    require(estates[_key].price == msg.value);
  }

  function withdraw(uint _key) public {
    require(address(this).balance >= estates[_key].price);
    payable(estateToOwner[_key]).transfer(estates[_key].price);
  }

  function purchase(uint _key) external {
    require(estateIsRelease[_key]);
    payPrice(_key);
    withdraw(_key);
    _changeOwner(_key);
    unrelease(_key);
  }

  function getEstate(uint _key) external view returns (string memory, string memory, uint){
    return (estates[_key].name, estates[_key].place, estates[_key].price);
  }

  function getMyEstates() external view returns (uint[] memory){
    uint[] memory myEstates = new uint[](ownerEstateCount[msg.sender]);
    uint x = 0; 
    for(uint i = 0; i < estates.length; i++) {
      if(estateToOwner[i] == msg.sender){
        myEstates[x] = i;
        x++;
      }
    }
    return myEstates;
  }

  function getAllReleased() external view returns (uint[] memory){
    uint[] memory releasedEstates = new uint[](releaseCount);
    uint x = 0;
    for(uint i = 0; i < estates.length; i++){
      if(estateIsRelease[i]){
        releasedEstates[x] = i;
        x++;
      }
    }
    return releasedEstates;
  }

  function isReleasedByEstate(uint _key) external view returns (bool){
    return estateIsRelease[_key];
  }
}