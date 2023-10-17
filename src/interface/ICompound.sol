// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

interface ICompound {
    struct RewardOwed {
        address token;
        uint owed;
    }

    function supply(address asset, uint amount) external;

    function supplyTo(address dst, address asset, uint amount) external;

    function supplyFrom(
        address from,
        address dst,
        address asset,
        uint amount
    ) external;

    function withdraw(address asset, uint amount) external;

    function withdrawTo(address to, address asset, uint amount) external;

    function withdrawFrom(
        address src,
        address to,
        address asset,
        uint amount
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function baseBorrowMin() external view returns (uint256);

    function isBorrowCollateralized(
        address account
    ) external view returns (bool);

    function borrow(uint borrowAmount) external returns (uint);

    function totalBorrow() external view returns (uint256);

    function borrowBalanceOf(address account) external view returns (uint256);

    // claim reward
    function claim(address comet, address src, bool shouldAccrue) external;

    // comet: The address of the Comet contract.
    // src: The account in which to claim rewards.
    // to: The account in which to transfer the claimed rewards.
    // shouldAccrue: If true, the protocol will account for the rewards owed to the account as of the current block before transferring.
    // RETURN: No return, reverts on error.
    function getRewardOwed(
        address comet,
        address account
    ) external returns (RewardOwed memory);

    function baseTrackingAccrued(
        address account
    ) external view returns (uint64);
    function getUtilization() external view returns (uint);
    function getBorrowRate(uint utilization) external view returns (uint64);
}
