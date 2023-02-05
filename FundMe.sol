// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    
    uint256 public minimumUsd = 50 * 1e18; // we need to leave the minimum also with 18 decimals
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        //want to be able to set a minimum fund amount in USD
        require(getConversionRate(msg.value) > minimumUsd, "Didn't send enough");//1e18 == 1 * 10 ** 18 == 1000000000000000000
        
        //if the condition above was met, we then continue the process
        funders.push(msg.sender);  //we add the address that sent the funds into our `funders` array
        addressToAmountFunded[msg.sender] = msg.value; //we map the address of the `funder` in our mapping to know how much he has contributed
    }
}
