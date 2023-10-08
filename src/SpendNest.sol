// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
pragma solidity ^0.8.20;

contract SpendNest {
    struct userAccount {
        uint256 totalSavings;
        uint256 availableBalance;
        uint256 sharedBalance;
        uint256 noOfClubs;
    }
    struct clubCreated {
        string clubName;
        uint startDate;
        uint endDate;
        uint savingsGoal;
        uint totalParticipant;
        bool aUser;
        mapping(address => uint256) myBalance;
    }

    mapping(address => bool) accountCreated;
    mapping(address => userAccount) myAccount;
    mapping(string =>clubCreated) clubs;

    string[] allClubsName;

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

    // withdrwaing stable coin
    /**
     *Withdraw Fund
     */
    function withdrawFund(uint _amount) external {
        address user = msg.sender;
        userAccount storage myBalance = myAccount[user];
        uint256 BalanceLeft = myBalance.availableBalance;
        require(BalanceLeft >= _amount, "INSUFFICIENT_AMOUNT");
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
    function transferFund() external {}

    //Granting someone access to spend fund - whitelist address

    /**
     * Grant users Access to spend your fund
     */
    function grantAccessToFund() external {}

    // Savings club_ ___ deposit to spark protocol
    /**
     * create savings club
     */
    function createSavingsClub() external {}

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
