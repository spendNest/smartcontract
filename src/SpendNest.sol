// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ICompound} from "./interface/ICompound.sol";
pragma solidity ^0.8.20;

contract SpendNest {
    // how do we have access to money been shared
    // how do i know that i am been shared money

    struct userAccount {
        uint256 totalSavings;
        uint256 availableBalance;
        uint256 sharedBalance;
        uint256 noOfClubs;
        uint256 BorrowedAmount;
        uint256 AmountToBePayedBack;
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
        uint Personalsavings;
    }

    struct ClubCreated {
        string clubName;
        uint startDate;
        uint endDate;
        uint savingsGoal;
        uint totalParticipant;
        mapping(address => bool) aUser;
        mapping(address => uint256) myBalance;
    }

    mapping(address => bool) accountCreated;
    mapping(address => userAccount) myAccount;
    mapping(address => mapping(string => personalClubCreated)) personalClubs;
    mapping(address => mapping(string => bool)) stringExists;

    mapping(address => string[]) PersonalClubName;
    mapping(string => ClubCreated) publicClubs;
    string[] publicClubsNames;

    address TokenAccepted;
    address owner = msg.sender;
    address compound;

    // collect payment as sDai

    // EVENTS
    event Transfer(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed time
    );

    event Withdrawal(
        address user,
        uint256 indexed amount,
        uint256 indexed time
    );

    event FundWithdraw(
        address sender,
        address indexed receiver,
        uint indexed amount,
        uint256 indexed time
    );

    event PersonalClubDeposit(
        address indexed sender,
        uint indexed amount,
        uint256 indexed time
    );
    event PublicClubDeposit(
        address indexed sender,
        uint indexed amount,
        uint256 indexed time
    );
    event Borrowed(
        address indexed sender,
        uint256 indexed amount,
        uint256 indexed time
    );

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
            noOfClubs: 0,
            BorrowedAmount: 0,
            AmountToBePayedBack: 0
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
    function viewAccount(
        address _user
    ) external view returns (userAccount memory) {
        return myAccount[_user];
    }

    function withdraw(uint _amount, address _user) internal {
        require(accountCreated[_user], "ACCOUNT_DOES_NOT_EXIST");

        userAccount storage myBalance = myAccount[_user];
        uint256 BalanceLeft = myBalance.availableBalance;
        require(BalanceLeft >= _amount, "INSUFFICIENT_AMOUNT");
        uint amountLeft = BalanceLeft - _amount;
        myBalance.availableBalance = amountLeft;
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

        withdraw(_amount, msg.sender);
        receiver.availableBalance += _amount;
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
    function createPersonalSavingsClub(
        string memory _clubName,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external {
        address user = msg.sender;

        require(
            stringExists[user][_clubName] == false,
            "CLUB_NAME_ALREADY_EXIST"
        );

        personalClubCreated storage newClub = personalClubs[user][_clubName];

        newClub.clubName = _clubName;
        newClub.startDate = block.timestamp;
        newClub.endDate = _endDate;
        newClub.savingsGoal = _savingsGoal;

        PersonalClubName[msg.sender].push(_clubName);
    }

    /**
     * Return my personal club
     */
    function showMyPersonalCreatedClub(
        address _clubOwner
    ) public view returns (personalClubCreated[] memory) {
        string[] memory _myClubName = PersonalClubName[_clubOwner];
        uint clubLength = _myClubName.length;
        personalClubCreated[] memory clubsCreated = new personalClubCreated[](
            clubLength
        );

        for (uint256 i = 0; i < clubLength; i++) {
            personalClubCreated storage club = personalClubs[_clubOwner][
                _myClubName[i]
            ];
            clubsCreated[i] = club;
        }
        return clubsCreated;
    }

    /**
     * show single personal created club
     */
    function showSingleClub(
        address _owner,
        string calldata _clubName
    ) external view returns (personalClubCreated memory) {
        return personalClubs[_owner][_clubName];
    }

    /**
     *Add money to your savings
     */
    function depositToPersonalClub(
        string calldata _clubName,
        uint256 _amount
    ) external {
        address _owner = msg.sender;
        address token = TokenAccepted;
        address _compound = compound;
        userAccount storage _myOwnAccount = myAccount[_owner];
        uint _balance = _myOwnAccount.availableBalance;
        require(_balance >= _amount, "INSUFFICIENT_BALANCE");
        _balance -= _amount;
        IERC20(token).approve(_compound, _amount);
        ICompound(_compound).supply(token, _amount);
        personalClubCreated storage _myClub = personalClubs[_owner][_clubName];
        _myClub.Personalsavings += _amount;
        _myOwnAccount.totalSavings += _amount;

        emit PersonalClubDeposit(_owner, _amount, block.timestamp);
    }

    function loanToPayment() external returns (uint) {
        userAccount storage _myOwnAccount = myAccount[_owner];
        
    }

    /**
withdraw personal savings
*/
    function withdrawPersonalSavings(string memory _clubName) external {
        address _owner = msg.sender;
        require(stringExists[_owner][_clubName], "CLUB_DOES_NOT_EXIST");
        userAccount storage _myOwnAccount = myAccount[_owner];
        personalClubCreated storage _myClub = personalClubs[_owner][_clubName];

        require(
            _myOwnAccount.AmountToBePayedBack == 0,
            "YOU_HAVE_UNPAID_OVERDRAFT"
        );
        uint time = _myClub.endDate;
        require(block.timestamp >= time, "SAVINGS_NOT_READY_FOR_HARVEST");
        uint savings = _myClub.Personalsavings;

        require(savings > 0, "NO_SAVINGS");
        _myClub.Personalsavings = 0;
        _myOwnAccount.totalSavings -= savings;
        _myOwnAccount.availableBalance += savings;
    }

    /**
     * check if the name already exist
     */
    function checkNameExist(string memory _name) internal view returns (bool) {
        string[] memory allNames = publicClubsNames;
        if (allNames.length > 0) {
            for (uint256 index = 0; index < allNames.length; index++) {
                if (
                    keccak256(bytes(_name)) == keccak256(bytes(allNames[index]))
                ) {
                    revert("exists");
                }
                break;
            }
        }
        return true;
    }

    /**
     *create public clubs
     */
    function createPublicClubs(
        string memory _clubName,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external {
        address _user = msg.sender;
        require(accountCreated[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkNameExist(_clubName) == false, "CLUB_NAME_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        createClub.clubName = _clubName;
        createClub.startDate = _startDate;
        createClub.endDate = _endDate;
        createClub.savingsGoal = _savingsGoal;
        createClub.totalParticipant += 1;
        createClub.aUser[_user] = true;
    }

    /**
     * join savings club
     */
    // ##create a goal
    // __ percentage will be shared

    function joinSavingsClub(string memory _clubName) external {
        address _user = msg.sender;
        require(accountCreated[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkNameExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        createClub.aUser[_user] = true;
        createClub.totalParticipant += 1;
    }

    /**
     * move fund to savings club
     */
    function addFundSavingsClub(
        string memory _clubName,
        uint256 _amount
    ) external {
        address _user = msg.sender;
        address token = TokenAccepted;
        address _compound = compound;
        require(accountCreated[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkNameExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        userAccount storage _myOwnAccount = myAccount[_user];
        uint _balance = _myOwnAccount.availableBalance;

        require(
            block.timestamp >= createClub.startDate,
            "SAVINGS_CLUB_NOT_STARTED"
        );
        require(_balance >= _amount, "INSUFFICIENT_BALANCE");
        require(block.timestamp <= createClub.endDate, "SAVINGS_ENDED");
        require(createClub.aUser[_user], "NOT_A_USER");
        IERC20(token).approve(_compound, _amount);
        _balance -= _amount;
        ICompound(_compound).supply(token, _amount);
        createClub.myBalance[_user] += _amount;
        _myOwnAccount.totalSavings += _amount;
        emit PublicClubDeposit(_user, _amount, block.timestamp);
    }

    /**
     *remove fund from saving
     */
    function removeFundSavingsClub(string memory _clubName) external {}

    /**
     * Return all public deposit
     */

    function showPublicDeposit()
        external
        view
        returns (
            string[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory
        )
    {
        uint length = publicClubsNames.length;
        string[] memory clubName = new string[](length);
        uint[] memory startDate = new uint[](length);
        uint[] memory endDate = new uint[](length);
        uint[] memory savingsGoal = new uint[](length);
        uint[] memory totalParticipant = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            string memory currentClubName = publicClubsNames[i];
            ClubCreated storage currentClub = publicClubs[currentClubName];

            clubName[i] = currentClub.clubName;
            startDate[i] = currentClub.startDate;
            endDate[i] = currentClub.endDate;
            savingsGoal[i] = currentClub.savingsGoal;
            totalParticipant[i] = currentClub.totalParticipant;
        }
        return (clubName, startDate, endDate, savingsGoal, totalParticipant);
    }

    /**
     *show public club savings
     */

    function showMyPublicSavings(
        string memory _clubName
    ) external view returns (uint) {
        ClubCreated storage createClub = publicClubs[_clubName];
        return createClub.myBalance[msg.sender];
    }

    //lending & borrowing __ only people that have savings in thesaving club can borrow
    //Comet,Polygon, Tableland and Compound.
    /**
     *Borrow
     * user should only be able to borrow 20% of savings 
     * base asset can be borrowed using withdraw function
     * borrow usdc

     */
    function lend(uint256 _amount) external {
        address user = msg.sender;
        address _compound = compound;
        address token = TokenAccepted;
        userAccount storage _myOwnAccount = myAccount[user];
        uint256 balance = _myOwnAccount.totalSavings;
        uint256 percent = ((20 * balance) / 100);
        require(_amount <= percent, "ONLY_20%_CAN_BE_BORROWED");
        _myOwnAccount.BorrowedAmount += _amount;
        ICompound(_compound).withdraw(token, _amount);
        _myOwnAccount.availableBalance += _amount;
        emit Borrowed(user, _amount, block.timestamp);
    }

    /**
     * Payback lend Protocol
     */
    function payback() external {}
}
