// SPDX-License-Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ICompound} from "./interface/ICompound.sol";
import "./factory.sol";
import "./interface/Ifactory.sol";
pragma solidity ^0.8.21;

contract SpendNest {
    /**
     * @dev STATE VARIABLES
     */
    using SafeERC20 for IERC20;

    uint256 totalSavings;
    uint256 sharedBalance;
    uint256 noOfClubs;
    uint256 BorrowedAmount;
    uint256 AmountToBePayedBack;

    struct personalClubCreated {
        string clubName;
        uint256 startDate;
        uint256 endDate;
        uint256 savingsGoal;
        uint256 Personalsavings;
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

    /**
     * @notice EVENTS
     *
     */
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
        uint256 indexed amount,
        uint256 indexed time
    );

    event PersonalClubDeposit(
        address indexed sender,
        uint256 indexed amount,
        uint256 indexed time
    );
    event PublicClubDeposit(
        address indexed sender,
        uint256 indexed amount,
        uint256 indexed time
    );
    event Borrowed(
        address indexed sender,
        uint256 indexed amount,
        uint256 indexed time
    );

    constructor(
        address _factory,
        address _token,
        address _compound,
        address _owner
    ) {
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
     * @dev userExists
     * @param _user  checks if the user exists
     */

    function checkUser(address _user) internal view {
        require(factory.userExist(_user) == true, "RECEIVER_DOES_NOT_EXIST");
    }

    /**
     * @dev deposit token func.
     * @param _amount  to be deposited uint.
     */
    function depositFund(uint256 _amount) external {
        address _user = msg.sender;
        uint256 senderBal = IERC20(TokenAccepted).balanceOf(_user);
        require(senderBal > _amount, "senderBal not sufficient");
        IERC20(TokenAccepted).safeTransferFrom(_user, address(this), _amount);
        emit Transfer(_user, _amount, block.timestamp);
    }

    /**
     * @notice this func increases the state of shared bal.
     * @param amount to share
     */
    function transferBetweenOwnAcct(uint256 amount) external onlyOwner {
        sharedBalance += amount;
    }

    /**
     * @dev  returns user account details.
     * @return available balance of an account.
     * @return borrowed balance of an account.
     * @return total savings of an account.
     * @return shared balance with another user
     * @return number of savings club a user is participating in.
     * @return Amount plus interest to be payed back after borrowing.
     */
    function viewAccount()
        external
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
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

    /** @dev Account withdrawal
     * @param _amount withdraw uint to EOA.
     */

    function withdrawFund(uint256 _amount) external onlyOwner {
        require(
            IERC20(TokenAccepted).balanceOf(address(this)) >= _amount,
            "Insufficient fund"
        );
        IERC20(TokenAccepted).transfer(owner, _amount);
        emit Withdrawal(owner, _amount, block.timestamp);
    }

    /**
     * @dev transfer between users.
     * @param _receiver another account to receive funds address
     * @param _amount to transfer from sender to receiver uint
     */
    function transferFund(
        address _receiver,
        uint256 _amount
    ) external onlyOwner {
        checkUser(_receiver);
        require(
            IERC20(TokenAccepted).balanceOf(address(this)) >= _amount,
            "Insufficient fund"
        );
        IERC20(TokenAccepted).transfer(_receiver, _amount);
        emit FundWithdraw(msg.sender, _receiver, _amount, block.timestamp);
    }

    /**
     * @dev ERC20 approval
     * @param _spender to receive allowance
     * @param _amount transfer uint
     */
    function grantAccessToFund(
        address _spender,
        uint256 _amount
    ) external onlyOwner {
        checkUser(_spender);
        IERC20(TokenAccepted).approve(_spender, _amount);
        sharedBalance += _amount;
        sharedUsers.push(_spender);
    }

    /**
     * @dev personal savings
     * @param _clubName savings club string
     * @param _endDate timestamp to withdraw savings uint
     * @param _savingsGoal amount in total to save in club uint
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

    /** @dev returns array of structs of all personal savings
     * @return all personal savings created struct array
     */
    function showMyPersonalCreatedClub()
        public
        view
        returns (personalClubCreated[] memory)
    {
        string[] memory _myClubName = PersonalClubName[address(this)];
        uint256 clubLength = _myClubName.length;
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
     * @dev returns just a single club
     * @param _clubName  personalClub string to be returned
     * @return a club
     */
    function showSingleClub(
        string calldata _clubName
    ) external view returns (personalClubCreated memory) {
        return personalClubs[address(this)][_clubName];
    }

    /**
     * @dev Personal savings deposit func
     * @param _clubName savings to be deposited string
     * @param _amount amount to be added uint
     */
    function depositToPersonalClub(
        string calldata _clubName,
        uint256 _amount
    ) external {
        address token = TokenAccepted;
        address _compound = compound;
        uint256 _balance = IERC20(TokenAccepted).balanceOf(address(this));
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

    /**
     *  @dev personal savings withdrawal func
     * @param _clubName  savings to withdraw string
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

    /**
     * @dev create a public savings club
     * @param _clubName  new savings club string
     * @param _startDate time in seconds to start the savings club
     * @param _endDate time in seconds to end
     * @param _savingsGoal amount to be saved in total
     */
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

    /**
     * @dev participate in a public savings
     * @param _clubName  string of the club to join
     */

    function joinPublicClub(string memory _clubName) external {
        factory.joinSavingsClub(_clubName);
    }

    /**
     * @dev fund a public savings club
     * @param _clubName club string to add funds to
     * @param _amount amount to be added uint
     */
    function addFundpublic(string memory _clubName, uint256 _amount) external {
        IERC20(TokenAccepted).approve(compound, _amount);
        factory.addFundSavingsClub(_clubName, _amount, address(this));
        ICompound(compound).supply(TokenAccepted, _amount);
        totalSavings += _amount;
        emit PublicClubDeposit(address(this), _amount, block.timestamp);
    }

    /**
     *
     * @return Return all public club details
     */
    function getPublicSavingData()
        external
        view
        returns (
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        factory.showPublicData();
    }

    /**
     *@param _clubName club string to show balanceOf
     *@return uint amount of public club total funds
     */
    function getPublicClubFund(
        string memory _clubName
    ) external view returns (uint256) {
        uint256 amount = factory.showMyPublicSavings(_clubName);
        return amount;
    }

    /**
     * @dev public savings withdrawals
     * @param _clubName string name of club to withdraw from
     * @return uint balance after withdrawal
     */
    function withdrawPublic(
        string memory _clubName
    ) external returns (uint256) {
        (uint256 _balance, uint256 _amount) = factory.withdrawPublicClub(
            _clubName,
            address(this)
        );
        totalSavings -= _amount;
        ICompound(compound).withdraw(TokenAccepted, _balance);
        return totalSavings;
    }

    /**
     * @notice lending & borrowing __ only people that have savings in thesaving club can borrow
     * user should only be able to borrow 20% of savings
     * borrow usdc
     * @dev for borrowing
     * @param _amount uint to borrow
     */
    function lend(uint256 _amount) external {
        address _compound = compound;
        address token = TokenAccepted;
        uint256 balance = totalSavings;
        uint256 percent = ((20 * balance) / 100);
        require(_amount <= percent, "ONLY_20%_CAN_BE_BORROWED");
        BorrowedAmount += _amount;
        ICompound(_compound).withdraw(token, _amount);
        emit Borrowed(address(this), _amount, block.timestamp);
    }

    /**
     * @dev Payback lend
     * @return borrowed balance after payback
     */
    function payback() external returns (uint256) {
        address user = address(this);
        uint256 borrowBal = ICompound(compound).borrowBalanceOf(user);
        require(
            IERC20(TokenAccepted).balanceOf(user) >= borrowBal,
            "Insufficient availableBal."
        );
        IERC20(TokenAccepted).approve(compound, borrowBal);
        ICompound(compound).supply(TokenAccepted, borrowBal);
        BorrowedAmount = 0;
        AmountToBePayedBack = 0;
        return BorrowedAmount;
    }

    /**
     * @dev borrowRate used
     * @return the amount to be paid back after borrow uint
     */
    function payBackAmount() public view returns (uint256) {
        address user = address(this);
        uint256 borrowBal = ICompound(compound).borrowBalanceOf(user);
        return (borrowBal);
    }
}
