// SPDX-License_Identifier:MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./interface/ICompound.sol";
import "./SpendNest.sol";
pragma solidity ^0.8.21;

contract factory {
    address[] childContracts;
    address tokenAccepted;
    address compound;
    address owner = msg.sender;

    struct ClubCreated {
        string clubName;
        uint startDate;
        uint endDate;
        uint savingsGoal;
        uint totalParticipant;
        mapping(address => bool) aUser;
        mapping(address => uint256) myBalance;
    }
    string[] publicClubsNames;

    mapping(address => address) myAddress;
    mapping(address => bool) userExists;
    mapping(string => ClubCreated) publicClubs;

event AccountCreated(
    address indexed creator,
    address indexed factory

);
    function set_Token(address _tokenAcepted) external {
        require(msg.sender == owner, "Not Owner");
        tokenAccepted = _tokenAcepted;
    }

    function setCompound(address _compound) external {
        require(msg.sender == owner, "Not Owner");
        compound = _compound;
    }

    function createAccount() external {
        address _owner = msg.sender;
        SpendNest newContract = new SpendNest(address(this), tokenAccepted, compound ,_owner);
        childContracts.push(address(newContract));
        myAddress[_owner] = address(newContract);
        userExists[address(newContract)] = true;
        emit AccountCreated(_owner, address(newContract));

    }

    function _returnAddress(
        address _contractOwner
    ) external view returns (address) {
        address contractAddress = myAddress[_contractOwner];
        return contractAddress;
    }

    function _tokenAddress() public view returns (address) {
        return tokenAccepted;
    }

    function userExist(address _user) external view returns (bool) {
        return userExists[_user];
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
                // break;
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

function checkClubExist(string memory _name) internal view returns (bool) {
        string[] memory allNames = publicClubsNames;
        if (allNames.length > 0) {
            for (uint256 index = 0; index < allNames.length; index++) {
                if (
                    keccak256(bytes(_name)) == keccak256(bytes(allNames[index]))
                ) {
                // break;
                    return true;
                }
               break;
            }
        }
        return true;
    }
    /**
     * join savings club
     */
    // ##create a goal
    // __ percentage will be shared

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
     * move fund to savings club
     */
    function addFundSavingsClub(
        string memory _clubName,
        uint256 _amount,
        address _user
    ) external {
        // address _user = msg.sender;
        address token = tokenAccepted;
        address _compound = compound;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkClubExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        //userAccount storage _myOwnAccount = myAccount[_user];
        uint _balance = IERC20(token).balanceOf(_user);

        require(
            block.timestamp >= createClub.startDate,
            "SAVINGS_CLUB_NOT_STARTED"
        );
        // require(_balance >= _amount, "INSUFFICIENT_BALANCE");
        require(block.timestamp <= createClub.endDate, "SAVINGS_ENDED");
        require(createClub.aUser[_user], "NOT_A_USER");
        // IERC20(token).approve(_compound, _amount);
        //IERC20(token).approve(_compound, _amount);
        
        // ICompound(_compound).supply(token, _amount);
        createClub.myBalance[_user] += _amount;
        //_myOwnAccount.totalSavings += _amount;

    }

    function showPublicData()
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
* @notice This function returns single public club
* @dev the returns are from the club created
* @param _name the name of the club you want to view
 */
function viewSinglePublic(string memory _name) external view returns(string memory, uint256, uint256, uint256, uint256) {
    ClubCreated storage currentClub = publicClubs[_name];
    string memory _clubName = currentClub.clubName;
    uint _startDate = currentClub.startDate;
    uint _endDate = currentClub.endDate;
    uint _savingsGoal = currentClub.savingsGoal;
    uint _totalParticipant = currentClub.totalParticipant;

    return(_clubName, _startDate, _endDate, _savingsGoal, _totalParticipant);


}

    function showMyPublicSavings(
        string memory _clubName
    ) external view returns (uint256) {
        ClubCreated storage createClub = publicClubs[_clubName];
        return createClub.myBalance[msg.sender];
    }

    /**
    * @notice Shows if the msg.sender is a user 
    * @param _clubName the name of the club
    * @return the function retuturns bool
     */
    function showPublicMember(
        string memory _clubName
    ) external view returns (bool) {
        ClubCreated storage createClub = publicClubs[_clubName];
        return createClub.aUser[msg.sender];
    }

    /**
     *remove fund from saving
     */
    function withdrawPublicClub(string memory _clubName, address _user) external returns(uint256, uint256){
        // address _user = msg.sender;
        address _compound = compound;
        require(userExists[_user], "ACCOUNT_DOES_NOT_EXIST");
        require(checkClubExist(_clubName), "CLUB_DOES_NOT_EXIST");
        ClubCreated storage createClub = publicClubs[_clubName];
        uint256 borrowBal = ICompound(_compound).borrowBalanceOf(_user);
        uint256 amount = createClub.myBalance[_user];
        if (borrowBal == 0 ) {
            uint256 bal= amount;
            createClub.myBalance[_user] = 0;
            return (bal, amount);
            // ICompound(_compound).withdraw(tokenAccepted, amount);
        }  else if(borrowBal > 0 && amount > borrowBal){
           uint256 rem = amount - borrowBal;
           createClub.myBalance[_user] = 0;
           return (rem, amount);
        //    ICompound(_compound).withdrawFrom(tokenAccepted, rem);

        } else {
             revert("YOU_HAVE_UNPAID_OVERDRAFT");

        }
        

    }

function lendPublic() external returns(uint256){

}








}
