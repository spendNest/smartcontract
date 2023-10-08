// SPDX-License_Identifier:MIT

pragma solidity ^0.8.17;

contract SpendNest {
        struct userAccount{
                uint256 totalSavings;
                uint256 availableBalance;
                uint256 sharedBalance;
                uint256 clubSavings;
        }
    mapping (address => userAccount) myAccount;
    
    address TokenAccepted;

    // collect payment as sDai

    // EVENTS

      //Depositing stable_coin ___they can deposit to our contract
    /**
Deposit function
 */
    function depositFund(uint _amount) external {

    }

/**
* View my fund
*/ 
function viewAccount() external returns(userAccount memory){

}
 // withdrwaing stable coin
/**
*Withdraw Fund
 */
    function withdrawFund() external{

    }

/**
*Total savings
*/
  
   
    //token transfer between people having account on the system
        /**
        * Transfer within address registered on the contract
        */
        function transferFund() external{

        }


    //Granting someone access to spend fund - whitelist address

/**
* Grant users Access to spend your fund
*/     
function grantAccessToFund() external{

}


    // Savings club_ ___ deposit to spark protocol
/** 
* create savings club
*/
function createSavingsClub() external{

}
/**
* join savings club
 */
  // ##create a goal
  // __ percentage will be shared

 function joinSavingsClub() external{

 }
   
   /**
   * move fund to savings club
    */
    function addFundSavingsClub() external{

    }

    /**
    *remove fund from saving
    */
    function removeFundSavingsClub() external{

    }


    
   
    //lending & borrowing __ only people that have savings in thesaving club can borrow
    //Comet,Polygon, Tableland and Compound.
    /**
    *Borrow 
     */
    function lend() external{

    }

    /**
    * Payback lend Protocol
    */
    function payback() external{
        
    }

}
