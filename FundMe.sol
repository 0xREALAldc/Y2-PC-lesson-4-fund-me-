// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18; // we need to leave the minimum also with 18 decimals
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        //want to be able to set a minimum fund amount in USD
        // require(getConversionRate(msg.value) > minimumUsd, "Didn't send enough");//1e18 == 1 * 10 ** 18 == 1000000000000000000
        require(msg.value.getConversionRate() > minimumUsd, "Didn't send enough");

        //if the condition above was met, we then continue the process
        funders.push(msg.sender);  //we add the address that sent the funds into our `funders` array
        addressToAmountFunded[msg.sender] = msg.value; //we map the address of the `funder` in our mapping to know how much he has contributed
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            // or we could use also addressToAmountFunded[funders[funderIndex]] = 0;
        }

        //reset the array
        funders = new address[](0);

        //withdraw the funds

        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        //send 
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        //call - MORE RECOMENDED TO BE USED 
        // (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        //because we aren't calling a function, we don't have and don't care for the result, so we leave the dataReturned place blank
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Senders is not owner!");
        _;
    }
}
