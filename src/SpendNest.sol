// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
pragma solidity ^0.8.20;

contract SpendNest {
    // how do we have access to money been shared
    // how do i know that i am been shared money 

    struct userAccount {
        uint256 totalSavings;
        uint256 availableBalance;
        uint256 sharedBalance; 
        uint256 noOfClubs;
        // sharedFund mysharedFund;
        
    }

    // struct sharedFund{
       
    //     mapping(address=>uint256) yourSharedAmount;
    // }

    struct personalClubCreated {
        string clubName;
        uint startDate;
        uint endDate;
        uint savingsGoal;
        uint totalParticipant;
        bool aUser;
        uint Personalsavings;
       
    }

    // struct ClubCreated {
    //     string clubName;
    //     uint startDate;
    //     uint endDate;
    //     uint savingsGoal;
    //     uint totalParticipant;
    //     bool aUser;
    //     uint Personalsavings;
    //     mapping(address => uint256) myBalance;
    // }

    mapping(address => bool) accountCreated;
    mapping(address => userAccount) myAccount;
    mapping(string => personalClubCreated) personalClubs;
    mapping(address=> mapping(string=>bool)) stringExists;

    mapping (address =>string[]) PersonalClubName;

    address TokenAccepted;
    address owner = msg.sender;

    // collect payment as sDai

    // EVENTS
    event Transfer(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed time
    );

    event Withdrawal(address user, uint256 indexed amount, uint256 indexed time);

    event FundWithdraw(address sender, address indexed receiver, uint indexed amount, uint256 indexed time);

    function set_Token(address _tokenAceppted) external {
        require(msg.sender == owner, "Not Owner");
        TokenAccepted = _tokenAceppted;
    }

    function createAccount() external {
        address user = msg.sender;
        require(accountCreated[user] == false, "ACCOUNT_ALREADY_EXIST");
        accountCreated[user] = true;
        userAccount memory newUser = userAccount({
            totalSavings: 0,
            availableBalance: 0,
            sharedBalance: 0,
            noOfClubs: 0
        });

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
        require(
            IERC20(TokenAccepted).transferFrom(user, address(this), _amount),
            "transfer Failed"
        );
        userAccount storage _user = myAccount[user];
        _user.availableBalance += _amount;
        emit Transfer(user, _amount, block.timestamp);
    }

    /**
     * View my fund
     */
    function viewAccount(address _user) external view returns (userAccount memory) {
        return myAccount[_user];
    }

    function withdraw(uint _amount, address _user) internal{
        require(accountCreated[_user], 'ACCOUNT_DOES_NOT_EXIST');
        
        userAccount storage myBalance = myAccount[_user];
        uint256 BalanceLeft = myBalance.availableBalance;
        require(BalanceLeft >= _amount, "INSUFFICIENT_AMOUNT");
        uint amountLeft = BalanceLeft-_amount;
        myBalance.availableBalance=amountLeft;
    }
    // withdrwaing stable coin
    /**
     *Withdraw Fund
     */
    function withdrawFund(uint _amount) external {
        address user = msg.sender;
       withdraw(_amount, user);
        IERC20(TokenAccepted).transfer(user, _amount);
        emit Withdrawal(user, _amount, block.timestamp);
        

    }

    /**
     *Total savings
     */

    //token transfer between people having account on the system
    /**
     * Transfer within address registered on the contract
     */
    function transferFund(address _receiver, uint _amount) external {
        require(accountCreated[_receiver], "RECEIVER_DOES_NOT_EXIST");

        userAccount storage receiver = myAccount[_receiver];
     
        withdraw(_amount,msg.sender);
        receiver.availableBalance +=_amount;
        emit FundWithdraw(msg.sender, _receiver, _amount, block.timestamp);



    }

    //Granting someone access to spend fund - whitelist address

    /**
     * Grant users Access to spend your fund
     */
    // function grantAccessToFund(address _spender, uint _amount) external view {
    //        require(accountCreated[_spender], "RECEIVER_DOES_NOT_EXIST");
    // }

    // Savings club_ ___ deposit to spark protocol
    /**
     * create savings club
     */
    function createPersonalSavingsClub(string memory _clubName, uint256 _endDate, uint256 _savingsGoal) external {
        address user = msg.sender;
    
        require(stringExists[user][_clubName] == false, "CLUB_NAME_ALREADY_EXIST");
        
        personalClubCreated storage newClub = personalClubs[_clubName];

            newClub.clubName= _clubName;
            newClub.startDate= block.timestamp;
            newClub.endDate= _endDate;
            newClub.savingsGoal= _savingsGoal;
            newClub.totalParticipant= 0;
            newClub.aUser=true;
          

       PersonalClubName[msg.sender].push(_clubName);
    }

/**
* Return my personal club
*/    
// function showMyPersonalCreatedClub() public returns(){

// }
    /**
     * join savings club
     */
    // ##create a goal
    // __ percentage will be shared

    function joinSavingsClub() external {}

    /**
     * move fund to savings club
     */
    function addFundSavingsClub() external {}

    /**
     *remove fund from saving
     */
    function removeFundSavingsClub() external {}

    //lending & borrowing __ only people that have savings in thesaving club can borrow
    //Comet,Polygon, Tableland and Compound.
    /**
     *Borrow
     */
    function lend() external {}

    /**
     * Payback lend Protocol
     */
    function payback() external {}
}
