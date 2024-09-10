// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundEth} from "../../src/FundEth.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundEthTest is Test {
    FundEth public fundeth;

    function setUp() public {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeedAddress = helperConfig.activeNetworkConfig();
        fundeth = new FundEth(priceFeedAddress);
    }

    function fundContract() internal returns (address) {
        address test_random = makeAddr("Random");
        vm.deal(test_random, 2.45 ether);
        vm.startPrank(test_random);
        fundeth.fund{value: 0.33 ether}();
        fundeth.fund{value: 0.12 ether}();
        fundeth.fund{value: 0.16 ether}();
        vm.stopPrank();
        return test_random;
    }

    function testMinAmountToBeDeposited() public view {
        assertEq(fundeth.MIN_AMOUNT_TO_BE_DEPOSITED(), 5e18);
    }

    function testIsOwner() public view {
        assertEq(fundeth.getOwner(), address(this));
    }

    function testPriceFeedVersion() public view returns (uint256) {
        return fundeth.getPriceFeedVersion();
    }

    function testLatestETHUSDPrice() public view returns (int256) {
        return fundeth.getLatestETHUSDPrice();
    }

    function testFailFunding() public {
        address test_random = makeAddr("Random");
        vm.deal(test_random, 3 ether);
        vm.prank(test_random);
        fundeth.fund{value: 0.001 ether}();
    }

    function testFundingSuccess() public {
        uint256 initial_balance = fundeth.checkBalance();
        fundContract();
        assertEq(
            fundeth.checkBalance(),
            initial_balance + (0.33 ether + 0.12 ether + 0.16 ether)
        );
    }

    function testCheckAmountFundedByFunder() public {
        address _addr1 = fundContract();
        uint256 previous_amount_funded_by_address = fundeth
            .checkAmountFundedByAddress(_addr1);
        vm.prank(_addr1);
        fundeth.fund{value: 0.13 ether}();
        assertEq(
            fundeth.checkAmountFundedByAddress(_addr1),
            previous_amount_funded_by_address + 0.13 ether
        );
    }

    function testCheckFundersListUpdate() public {
        address _addr1 = fundContract();
        assertEq(fundeth.checkFunderByIndex(0), _addr1);
    }

    function testWithdrawRevertIfNotOwner() public {
        vm.prank(address(33));
        vm.expectRevert();
        fundeth.withdraw();
    }

    function testWithdrawResetAddressFundedValue() public {
        address _addr1 = fundContract();
        fundeth.withdraw();
        assertEq(fundeth.checkAmountFundedByAddress(_addr1), 0);
    }

    function testWithdrawDeleteFundersList() public {
        fundContract();
        fundeth.withdraw();
        assertEq(fundeth.getNumberOfFunders(), 0);
    }

    function testOwnerBalance() public {
        fundContract();
        vm.deal(address(this), 11 ether);
        uint256 initial_balance = address(this).balance;
        fundeth.withdraw();
        assertEq(address(this).balance, initial_balance + 0.61 ether);
    }

    function testReceive() public {
        uint256 initial_balance = fundeth.checkBalance();
        (bool success, ) = payable(fundeth).call{value: 0.5 ether}("");
        require(success, "could not send ether");
        (bool success1, ) = payable(fundeth).call{value: 1.5 ether}("");
        require(success1, "could not send ether");
        assertEq(
            fundeth.checkBalance(),
            initial_balance + (0.5 ether + 1.5 ether)
        );
    }

    receive() external payable {}
}
