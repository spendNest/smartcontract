// SPDX-License_Identifier:MIT
pragma solidity ^0.8.21;

import "./SpendNest.sol";

contract factory {
 address[] childContracts;
 address tokenAccepted;

 mapping(address => address) myAddress;




function set_Token(address _tokenAceppted) external {
        //require(msg.sender == owner, "Not Owner");
        tokenAccepted = _tokenAceppted;
    }
function createAcount () external {
    SpendNest newContract = new SpendNest(address(this));
    childContracts.push(address(newContract));
    myAddress[msg.sender] = address(newContract);
}

function _returnAddress(address _contractOwner) external view returns(address) {
    
 address contractAddress = myAddress[_contractOwner];
    return contractAddress;
}

function _tokenAddress () public view returns(address) {
    return tokenAccepted;
}

functino
































}