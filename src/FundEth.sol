// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundEth {
    using PriceConverter for uint256;

    uint256 public constant MIN_AMOUNT_TO_BE_DEPOSITED = 5e18;
    address private immutable I_OWNER;
    address[] private funders;
    mapping(address => uint256) private amount_deposited_by_each_funder;
    mapping(address => bool) private funder_address_exists;
    bool private is_locked;
    AggregatorV3Interface internal price_feed;

    constructor(address _price_feed) {
        I_OWNER = msg.sender;
        price_feed = AggregatorV3Interface(_price_feed);
    }

    modifier onlyOwner() {
        require(msg.sender == I_OWNER, "You are not authorized");
        _;
    }

    modifier nonReEntrant() {
        require(!is_locked, "Function can not be accessed now");
        is_locked = true;
        _;
        is_locked = false;
    }

    function getPriceFeedVersion() external view returns (uint256) {
        return price_feed.version();
    }

    function getLatestETHUSDPrice() public view returns (int256) {
        (
            ,
            /* uint80 roundID */
            int256 answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = price_feed.latestRoundData();
        return answer;
    }

    function getOwner() public view returns (address) {
        return I_OWNER;
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(price_feed) >=
                MIN_AMOUNT_TO_BE_DEPOSITED,
            "Amount too low"
        );
        amount_deposited_by_each_funder[msg.sender] += msg.value;
        if (!funder_address_exists[msg.sender]) {
            funders.push(msg.sender);
            funder_address_exists[msg.sender] = true;
        }
    }

    function getNumberOfFunders() public view returns (uint256) {
        return funders.length;
    }

    function checkFunderByIndex(uint256 _index) public view returns (address) {
        return funders[_index];
    }

    function checkAmountFundedByAddress(
        address _address
    ) public view returns (uint256 _funded_amount) {
        _funded_amount = amount_deposited_by_each_funder[_address];
    }

    function withdraw() public onlyOwner nonReEntrant {
        uint256 funders_length = funders.length;
        for (uint256 index = 0; index < funders_length; index++) {
            amount_deposited_by_each_funder[funders[index]] = 0;
        }
        delete funders;
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call Failed");
    }

    receive() external payable {
        fund();
    }
}
