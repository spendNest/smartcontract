
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

interface Ifactory {
    function createAcount() external;

    function _returnAddress(
        address _contractOwner
    ) external view returns (address);

    function tokenAddress() external view returns (address);

    function userExist(address _user) external view returns (bool);

    function createPublicClubs(
        string memory _clubName,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _savingsGoal
    ) external;

    function joinSavingsClub(string memory _clubName) external;

    function addFundSavingsClub(
        string memory _clubName,
        uint256 _amount,
        address _user
    ) external;

    function showPublicData()
        external
        view
        returns (
            string[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory
        );

    function showMyPublicSavings(
        string memory _clubName
    ) external view returns (uint);

    function withdrawPublicClub(string memory _clubName, address _user) external returns(uint256, uint256);
}