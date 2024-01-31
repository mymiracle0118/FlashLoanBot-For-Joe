// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.17;

import { FlashLoanReceiverBase } from "./FlashLoanReceiverBase.sol";
import { ILendingPool, ILendingPoolAddressesProvider, IERC20 } from "./Interfaces.sol";
import { SafeMath } from "./Libraries.sol";
import "./Ownable.sol";

/*
*
* A contract that executes the following logic in a single atomic transaction
*/
contract BatchFlashDemo is FlashLoanReceiverBase, Ownable {
    
    ILendingPoolAddressesProvider provider;
    using SafeMath for uint256;
    
    uint256 flashUSDCAmt;

    address lendingPoolAddr;
    
    //stable: 1, variable: 2
    uint256 borrowMode;

    struct op {
        uint256 typeCode;
        uint256 amount;
    }

    uint256 DEPOSIT = 1;
    uint256 BORROW = 2;
    uint256 REPAY = 3;
    // uint256 WITHDRAW = 4;

    uint256 opCnt;

    mapping ( uint256 => op ) opMap;
 
    //mumbai reserve asset address
    // address USDC_ADDRESS = 0x2058A9D7613eEE744279e3856Ef0eAda5FCbaA7e;

    address USDC_ADDRESS;
    address AMUSDC_ADDRESS;

    address WALLET_ADDRESS;



    // intantiate lending pool addresses provider and get lending pool address
    constructor(ILendingPoolAddressesProvider _addressProvider, address _usdcAddress, address _amUsdcAddress, uint256 _borrowMode) FlashLoanReceiverBase(_addressProvider) {
        provider = _addressProvider;
        USDC_ADDRESS = _usdcAddress;
        AMUSDC_ADDRESS = _amUsdcAddress;
        borrowMode = _borrowMode;
        lendingPoolAddr = provider.getLendingPool();
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata
    )
        external
        override
        returns (bool)
    {
        
        // initialise lending pool instance
        ILendingPool lendingPool = ILendingPool(lendingPoolAddr);
        
        for (uint i = 0; i < opCnt; i++) {
            if (opMap[i].typeCode == DEPOSIT) {
                flashDeposit(lendingPool, opMap[i].amount);
            } else if(opMap[i].typeCode == BORROW) {
                flashBorrow(lendingPool, opMap[i].amount);
            } else if(opMap[i].typeCode == REPAY) {
                flashRepay(lendingPool, opMap[i].amount);
            // } else if(opMap[i].typeCode == WITHDRAW) {
            //     flashWithdraw(lendingPool, opMap[i].amount);
            }
        }

        // Approve the LendingPool contract allowance to *pull* the owed amount
        // i.e. AAVE V2's way of repaying the flash loan
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(_lendingPool), amountOwing);
        }

        return true;
    }

    /*
    * Deposits the flashed AAVE, DAI and LINK liquidity onto the lending pool as collateral
    */
    function flashDeposit(ILendingPool _lendingPool, uint256 _depositAmt) public {
        IERC20(USDC_ADDRESS).approve(lendingPoolAddr, _depositAmt);
        _lendingPool.deposit(USDC_ADDRESS, _depositAmt, address(this), uint16(0));
        flashReturnFunds(_depositAmt);
    }

    /*
    * Withdraws the AAVE, DAI and LINK collateral from the lending pool
    */
    function flashWithdraw(ILendingPool _lendingPool, uint256 _withdrawAmount) public {
        _lendingPool.withdraw(USDC_ADDRESS, _withdrawAmount, address(this));   
    }

    /*
    * Return amUSDC to the wallet from the contract
    */
    function flashReturnFunds(uint256 _returnFundsAmount) public {
        IERC20(AMUSDC_ADDRESS).transfer(WALLET_ADDRESS, _returnFundsAmount);
    }

    
    /*
    * Borrows _borrowAmt amount of _borrowAsset based on the existing deposited collateral
    */
    function flashBorrow(ILendingPool _lendingPool, uint256 _borrowAmt) public {
        // borrowing x asset at stable rate, no referral, for yourself
        _lendingPool.borrow(
            USDC_ADDRESS, 
            _borrowAmt, 
            borrowMode, 
            uint16(0), 
            WALLET_ADDRESS
        );
        
    }

    /*
    * Repays _repayAmt amount of _repayAsset
    */
    function flashRepay(ILendingPool _lendingPool, uint256 _repayAmt) public {
        
        // approve the repayment from this contract
        IERC20(USDC_ADDRESS).approve(lendingPoolAddr, _repayAmt);
        
        _lendingPool.repay(
            USDC_ADDRESS, 
            _repayAmt, 
            borrowMode, 
            WALLET_ADDRESS
        );
    }

    /*
    * Repays _repayAmt amount of _repayAsset
    */
    function flashSwapBorrowRate(ILendingPool _lendingPool, address _asset, uint256 _rateMode) public {
        
        _lendingPool.swapBorrowRateMode(_asset, _rateMode);
        
    }


    function deposit(
        uint256 _amount) public {
        IERC20(USDC_ADDRESS).transferFrom(msg.sender, address(this), _amount);
    }
    /*
    * This function is manually called to commence the flash loans sequence
    */
    function executeFlashLoans(
        uint256 _flashUSDCAmt, 
        uint256[] calldata _typeArray, 
        uint256[] calldata _amtArray
        ) public onlyOwner {
        
        WALLET_ADDRESS = msg.sender;

        opCnt = _typeArray.length; //count of operations

        op memory newOp;
        
        for (uint i = 0; i < opCnt; i++) {
            
            newOp.typeCode = _typeArray[i];
            newOp.amount = _amtArray[i];

            opMap[i] = newOp;
        }

        address receiverAddress = address(this);

        // the various assets to be flashed
        address[] memory assets = new address[](1);
        assets[0] = USDC_ADDRESS; 

        // the amount to be flashed for each asset
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _flashUSDCAmt;
       
        flashUSDCAmt = _flashUSDCAmt;
        
        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;
        
        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        _lendingPool.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );


        if (IERC20(USDC_ADDRESS).balanceOf(address(this)) > 1) {
            IERC20(USDC_ADDRESS).transfer(WALLET_ADDRESS, IERC20(USDC_ADDRESS).balanceOf(address(this)));
        }
        // withdraw all x ERC20 tokens
    }
    
    /*
    * Rugpull all ERC20 tokens from the contract
    */
    // function rugPull() public payable onlyOwner{
    function rugPull() public payable onlyOwner{
        // withdraw all ETH
        // msg.sender.call{ value: address(this).balance }("");
        payable(msg.sender).transfer(address(this).balance);
        
        // withdraw all x ERC20 tokens
        IERC20(USDC_ADDRESS).transfer(msg.sender, IERC20(USDC_ADDRESS).balanceOf(address(this)));
   }
    
}
