// SPDX-License-Identifier:MIT
pragma solidity ^0.8.21;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./interface/ICompound.sol";
import "./SpendNest.sol";

contract factory {
    /**
     * @dev STATE VARIABLE
     */
    address[] childContracts;
    address tokenAccepted;
    address compound;
    address owner = msg.sender;

    struct ClubCreated {
        string clubName;
        uint256 startDate;
        uint256 endDate;
        uint256 savingsGoal;
        uint256 totalParticipant;
        mapping(address => bool) aUser;
        mapping(address => uint256) myBalance;
    }
    string[] publicClubsNames;

    mapping(address => address) myAddress;
    mapping(address => bool) userExists;
    mapping(string => ClubCreated) publicClubs;

    /**
     * @dev set token for transactions
     * @param _tokenAcepted address of token
     */
    function set_Token(address _tokenAcepted) external {
        require(msg.sender == owner, "Not Owner");
        tokenAccepted = _tokenAcepted;
    }

    /**
     * @dev set compound address
     * @param _compound compound protocol
     */
    function setCompound(address _compound) external {
        require(msg.sender == owner, "Not Owner");
        compound = _compound;
    }

    /**@notice this func deploys an account for users
     * @dev create an account
     */
    function createAccount() external {
        address _owner = msg.sender;
        SpendNest newContract = new SpendNest(
            address(this),
            tokenAccepted,
            compound,
            _owner
        );
        childContracts.push(address(newContract));
        myAddress[_owner] = address(newContract);
        userExists[address(newContract)] = true;
    }

    /**@notice this external func returns address of account for user.
     * @dev func to get the account address
     * @param _contractOwner address of account owner
     */
    function _returnAddress(
        address _contractOwner
    ) external view returns (address) {
        address contractAddress = myAddress[_contractOwner];
        return contractAddress;
    }

    /**
     * @return address of token of the contract
     */
    function _tokenAddress() public view returns (address) {
        return tokenAccepted;
    }

    function userExist(address _user) external view returns (bool) {
        return userExists[_user];
    }

    /** @notice this internal func checks if strings of name already exist
     * @param _name  strings to be checked
     * @return true if name already exists
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
            }
        }
        return true;
    }

    /**@notice this function creates a new public savings club
     *
     * @param _clubName string name of the new club
     * @param _startDate start date of the new club
     * @param _endDate  end date of the new club
     * @param _savingsGoal the amount in the total to be saved in the new club
     */
    function createPublicClubs(
        string memory _clubName,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external {
        address _user = msg.sender;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkNameExist(_clubName) == true, "CLUB_NAME_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        createClub.clubName = _clubName;
        createClub.startDate = _startDate;
        createClub.endDate = _endDate;
        createClub.savingsGoal = _savingsGoal;
        createClub.totalParticipant += 1;
        createClub.aUser[_user] = true;
        publicClubsNames.push(_clubName);
    }

    /**
     *
     * @param _name string to check, if it already exists
     */
    function checkClubExist(string memory _name) internal view returns (bool) {
        string[] memory allNames = publicClubsNames;
        if (allNames.length > 0) {
            for (uint256 index = 0; index < allNames.length; index++) {
                if (
                    keccak256(bytes(_name)) == keccak256(bytes(allNames[index]))
                ) {
                    return true;
                }
                break;
            }
        }
        return true;
    }

    /**
     * @notice this function is called when a user wants to join a public club
     * @param _clubName string name of the club to be joined.
     */

    function joinSavingsClub(string memory _clubName) external {
        address _user = msg.sender;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkClubExist(_clubName) == true, "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        require(createClub.aUser[_user] == false, "YOU_BELONG_TO_THE_CLUB");
        createClub.totalParticipant += 1;
        createClub.aUser[_user] = true;
    }

    /**
     * @dev func to add funds to public clubs
     * @param _clubName name of club to add funds to
     * @param _amount amount of token
     * @param _user msg.sender
     */
    function addFundSavingsClub(
        string memory _clubName,
        uint256 _amount,
        address _user
    ) external {
        address token = tokenAccepted;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkClubExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        uint256 _balance = IERC20(token).balanceOf(_user);

        require(
            block.timestamp >= createClub.startDate,
            "SAVINGS_CLUB_NOT_STARTED"
        );
        require(_balance >= _amount, "INSUFFICIENT_BALANCE");
        require(block.timestamp >= createClub.endDate, "SAVINGS_ENDED");
        require(createClub.aUser[_user], "NOT_A_USER");
        createClub.myBalance[_user] += _amount;
    }

    /**
     *
     * @return all public savings clubs details
     */
    function showPublicData()
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
        uint length = publicClubsNames.length;
        string[] memory clubName = new string[](length);
        uint256[] memory startDate = new uint256[](length);
        uint256[] memory endDate = new uint256[](length);
        uint256[] memory savingsGoal = new uint256[](length);
        uint256[] memory totalParticipant = new uint256[](length);
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
     *
     * @param _clubName string of a public club
     * @return uint balance of msg.sender balance in public club
     */
    function showMyPublicSavings(
        string memory _clubName
    ) external view returns (uint256) {
        ClubCreated storage createClub = publicClubs[_clubName];
        return createClub.myBalance[msg.sender];
    }

    /**
     * @dev withdrawal func for public clubs
     * @param _clubName string of club to withdraw from
     * @param _user address of the user
     * @return (uint256, uint256)
     */
    function withdrawPublicClub(
        string memory _clubName,
        address _user
    ) external returns (uint256, uint256) {
        address _compound = compound;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkClubExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        uint256 borrowBal = ICompound(_compound).borrowBalanceOf(_user);
        uint256 amount = createClub.myBalance[_user];
        if (borrowBal == 0) {
            uint256 bal = amount;
            createClub.myBalance[_user] = 0;
            return (bal, amount);
        } else if (borrowBal > 0 && amount > borrowBal) {
            uint256 rem = amount - borrowBal;
            createClub.myBalance[_user] = 0;
            return (rem, amount);
        } else {
            revert("YOU_HAVE_UNPAID_OVERDRAFT");
        }
    }

    function lendPublic() external returns (uint256) {}
}
