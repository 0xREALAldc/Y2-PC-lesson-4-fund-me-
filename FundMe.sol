// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();

// 859,541  > first version
// 839, 981 > added the constant to MINIMUM_USD
// 816, 516 > added the immutable to i_owner
// 791, 404 > with the change of ONE require validation
contract FundMe {
    using PriceConverter for uint256;

    //21,415 - constant     = $ 1,053618
    //23,515 - non-constant = $ 1,156938
    uint256 public constant MINIMUM_USD = 50 * 1e18; // we need to leave the minimum also with 18 decimals
    
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    
    // 21,508 - immutable
    // 23,644 - without immutable
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        //want to be able to set a minimum fund amount in USD
        // require(getConversionRate(msg.value) > minimumUsd, "Didn't send enough");//1e18 == 1 * 10 ** 18 == 1000000000000000000
        require(msg.value.getConversionRate() > MINIMUM_USD, "Didn't send enough");

        //if the condition above was met, we then continue the process
        funders.push(msg.sender);  //we add the address that sent the funds into our `funders` array
        addressToAmountFunded[msg.sender] += msg.value; //we map the address of the `funder` in our mapping to know how much he has contributed
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
        // require(msg.sender == i_owner, "Sender is not owner!");

        // doing the validation as below, wich can be implemented from solidity 0.8.4, saves gas 
        // because we don't need to store the string array that's the message above
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    receive() external payable {
        // if someone sends ETH whithout any data in the transaction, we're going to automatically 
        // call our function fund()
        fund();                
    }

    // if someone sends ETH with data in the transaction, we're going to automatically 
    // call our function fund() too
    fallback() external payable {
        fund();
    }
}
