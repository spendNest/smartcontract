// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
pragma solidity ^0.8.20;

contract SpendNest {
        struct userAccount{
                uint256 totalSavings;
                uint256 availableBalance;  
                uint256 sharedBalance;
                uint256 noOfClubs;
        }
        struct clubCreated{
            string clubName;
            uint startDate;
            uint endDate;
            uint savingsGoal;
            uint totalParticipant;
            bool aUser;
            
        }
        mapping(address =>bool) accountCreated;
    mapping (address => userAccount) myAccount;
    
    address TokenAccepted;
    address owner = msg.sender;
    
    // collect payment as sDai

    // EVENTS
    event Transfer(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed time
    );

    function set_Token(address _tokenAceppted) external{
        require(msg.sender == owner, "Not Owner");
        TokenAccepted = _tokenAceppted;
    }

    function createAccount() external {
        address user = msg.sender;
        require(accountCreated[user] == false, 'ACCOUNT_ALREADY_EXIST');
        accountCreated[user] = true;
        userAccount memory newUser = userAccount({
            totalSavings: 0,
            availableBalance: 0,
            sharedBalance: 0 ,
            noOfClubs: 0
        });

        //  Person memory newPerson = Person(_name, _age);
        myAccount[user] = newUser;
    }

      //Depositing stable_coin ___they can deposit to our contract
    /**
Deposit function
 */
    function depositFund(uint _amount) external {
        address user = msg.sender;
        uint256 senderBal = IERC20(TokenAccepted).balanceOf(user);
        require(senderBal >= _amount, "senderBal not sufficient");
        require(IERC20(TokenAccepted).transferFrom(user, address(this), _amount), "transfer Failed");
        userAccount storage _user = myAccount[user];
        _user.availableBalance += _amount;
        emit Transfer(user, _amount, block.timestamp);
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


    // __ percentage will be shared
    // ##create a goal
    //lending & borrowing __ only people that have savings in thesaving club can borrow
    //Comet,Polygon, Tableland and Compound.
}
