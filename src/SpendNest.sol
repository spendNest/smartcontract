// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ICompound} from "./interface/ICompound.sol";
import "./factory.sol";
import "./interface/Ifactory.sol";
pragma solidity ^0.8.21;



contract SpendNest {
    // how do we have access to money been shared
    // how do i know that i am been shared money

    uint256 totalSavings;
    uint256 sharedBalance;
    uint256 noOfClubs;
    uint256 BorrowedAmount;
    uint256 AmountToBePayedBack;
    // sharedFund mysharedFund;

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

    mapping(address => bool) accountCreated;
    mapping(address => mapping(string => personalClubCreated)) personalClubs;
    mapping(address => mapping(string => bool)) stringExists;

    mapping(address => string[]) PersonalClubName;

    address[] sharedUsers;

    address TokenAccepted;
    Ifactory factory;
    address owner;
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

    constructor(address _factory, address _token, address _compound, address _owner) {
        factory = Ifactory(_factory);
        TokenAccepted = _token;
        compound = _compound;
        owner = _owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");

        _;
    }



    /**
     *
     * userExists
     */

    function checkUser(address _user) internal view {
        require(factory.userExist(_user) == true, "RECEIVER_DOES_NOT_EXIST");
    }

    //Depositing stable_coin ___they can deposit to our contract
    /**
Deposit function
 */
    function depositFund(uint _amount) external {
        address user = msg.sender;
        checkUser(address(this));
        uint256 senderBal = IERC20(TokenAccepted).balanceOf(user);
        require(senderBal >= _amount, "senderBal not sufficient");
        require(
            IERC20(TokenAccepted).transferFrom(user, address(this), _amount),
            "transfer Failed"
        );
        //userAccount storage _user = myAccount[user];
        //_user.availableBalance += _amount;
        emit Transfer(user, _amount, block.timestamp);
    }

    /**
     * View my fund
    //  */
    // issue wit borrow balance
    function viewAccount() external view returns (uint256, uint256,  uint256, uint256,uint256, uint256) {
        address user = address(this);
        uint256 availableBal = IERC20(TokenAccepted).balanceOf(user);
        uint256 borrowedAmount = ICompound(compound).borrowBalanceOf(user);
        return (
            totalSavings,
            availableBal,
            sharedBalance,
            noOfClubs,
            borrowedAmount,
            AmountToBePayedBack
        );
    }

  

    // withdrawing stable coin
    /**
     *Withdraw Fund
     */
    function withdrawFund(uint _amount) external onlyOwner {
        require(
            IERC20(TokenAccepted).balanceOf(address(this)) >= _amount,
            "Insufficient fund"
        );
        IERC20(TokenAccepted).transfer(owner, _amount);
        emit Withdrawal(owner, _amount, block.timestamp);
    }

    /**
     *Total savings
     */

    //token transfer between people having account on the system
    /**
     * Transfer within address registered on the contract
     */
    function transferFund(address _receiver, uint _amount) external onlyOwner {
        checkUser(_receiver);
        require(
            IERC20(TokenAccepted).balanceOf(address(this)) >= _amount,
            "Insufficient fund"
        );
        IERC20(TokenAccepted).transfer(_receiver, _amount);
        emit FundWithdraw(msg.sender, _receiver, _amount, block.timestamp);
    }

    //Granting someone access to spend fund - whitelist address

    /**
     * Grant users Access to spend your fund
     *
     */
    function grantAccessToFund(
        address _spender,
        uint _amount
    ) external onlyOwner {
        checkUser(_spender);
        IERC20(TokenAccepted).approve(_spender, _amount);
        sharedBalance += _amount;
        sharedUsers.push(_spender);
    }
    // Savings club_ ___ deposit to spark protocol
    /**
     * create savings club
     */
    function createPersonalSavingsClub(
        string memory _clubName,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external {
        require(
            stringExists[address(this)][_clubName] == false,
            "CLUB_NAME_ALREADY_EXIST"
        );

        personalClubCreated storage newClub = personalClubs[address(this)][
            _clubName
        ];

        newClub.clubName = _clubName;
        newClub.startDate = block.timestamp;
        newClub.endDate = _endDate;
        newClub.savingsGoal = _savingsGoal;
        PersonalClubName[address(this)].push(_clubName);
        stringExists[address(this)][_clubName] = true;
    }

    /**
     * Return my personal club
     */
    function showMyPersonalCreatedClub()
        public
        view
        returns (personalClubCreated[] memory)
    {
        string[] memory _myClubName = PersonalClubName[address(this)];
        uint clubLength = _myClubName.length;
        personalClubCreated[] memory clubsCreated = new personalClubCreated[](
            clubLength
        );

        for (uint256 i = 0; i < clubLength; i++) {
            personalClubCreated storage club = personalClubs[address(this)][
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
        string calldata _clubName
    ) external view returns (personalClubCreated memory) {
        return personalClubs[address(this)][_clubName];
    }

    /**
     *Add money to your savings
     */
    function depositToPersonalClub(
        string calldata _clubName,
        uint256 _amount
    ) external {
        address token = TokenAccepted;
        address _compound = compound;
        //userAccount storage _myOwnAccount = myAccount[_owner];
        uint _balance = IERC20(TokenAccepted).balanceOf(address(this));
        require(_balance >= _amount, "INSUFFICIENT_BALANCE");
        IERC20(token).approve(_compound, _amount);
        ICompound(_compound).supply(token, _amount);
        personalClubCreated storage _myClub = personalClubs[address(this)][
            _clubName
        ];
        _myClub.Personalsavings += _amount;
        totalSavings += _amount;

        emit PersonalClubDeposit(msg.sender, _amount, block.timestamp);
    }

    // function loanToPayment() external returns (uint) {
    //     address _compound = compound;
    //     userAccount storage _myOwnAccount = myAccount[_owner];
    //     ICompound(_compound).getUtilization();
    //     Icompound

    // }

    /**
    withdraw personal savings
    */
    function withdrawPersonalSavings(
        string memory _clubName
    ) external onlyOwner {
        require(stringExists[address(this)][_clubName], "CLUB_DOES_NOT_EXIST");
        personalClubCreated storage _myClub = personalClubs[address(this)][
            _clubName
        ];

        require(AmountToBePayedBack == 0, "YOU_HAVE_UNPAID_OVERDRAFT");
        uint256 time = _myClub.endDate;
        require(block.timestamp >= time, "SAVINGS_NOT_READY_FOR_HARVEST");
        uint256 savings = _myClub.Personalsavings;

        require(savings > 0, "NO_SAVINGS");
        _myClub.Personalsavings = 0;
        totalSavings -= savings;

        ICompound(compound).withdraw(TokenAccepted, savings);
    }

    function createPublicSav(
        string memory _clubName,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external {
        factory.createPublicClubs(
            _clubName,
            _startDate,
            _endDate,
            _savingsGoal
        );
    }

    function joinPublicClub(string memory _clubName) external {
        factory.joinSavingsClub(_clubName);
    }

    function addFundpublic(string memory _clubName, uint256 _amount) external {
        IERC20(TokenAccepted).approve(compound, _amount);
        factory.addFundSavingsClub(_clubName, _amount, address(this));
        ICompound(compound).supply(TokenAccepted, _amount);
        totalSavings += _amount;
        emit PublicClubDeposit(address(this), _amount, block.timestamp);
    }

    /**
     *remove fund from saving
     */
    // function withdrawPublicSavingsClub(string memory _clubName) external {

    // }

    /**
     * Return all public deposit
     */
    function getPublicSavingData()
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
        factory.showPublicData();
    }


    /**
     *show public club savings
     */
    function getPublicClubFund(
        string memory _clubName
    ) external view returns (uint256) {
        factory.showMyPublicSavings(_clubName);
    }

    /**
     * To return withdraw from public club
     */
    //  function 

    function withdrawPublic(string memory _clubName) external returns(uint) {
   (uint256 _balance, uint256 _amount)= factory.withdrawPublicClub(_clubName, address(this));
    totalSavings -= _amount;
        ICompound(compound).withdraw(TokenAccepted, _balance);
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
        uint256 balance = totalSavings;
        uint256 percent = ((20 * balance) / 100);
        require(_amount <= percent, "ONLY_20%_CAN_BE_BORROWED");
        BorrowedAmount += _amount;
        ICompound(_compound).withdraw(token, _amount);
        //_myOwnAccount.availableBalance += _amount;
        emit Borrowed(address(this), _amount, block.timestamp);
    }

    /**
     * Payback lend Protocol
     */
    function payback() external {
        address user = address(this);
        uint256 borrowBal = ICompound(compound).borrowBalanceOf(user);
        require(IERC20(TokenAccepted).balanceOf(user) >= borrowBal, "Insufficient availableBal.");
        IERC20(TokenAccepted).approve(compound, borrowBal);
        ICompound(compound).supply(TokenAccepted, borrowBal);
        BorrowedAmount = 0;
        AmountToBePayedBack = 0;
    }


    /**
     * returns the amount to be paid back to com
     */
    function payBackAmount() public returns(uint256){
         address user = address(this);
        uint256 borrowBal = ICompound(compound).borrowBalanceOf(user);
        return(borrowBal);
    }
}
