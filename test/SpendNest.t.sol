// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SpendNest.sol";
import "../src/factory.sol";

contract SpendNestTest is Test {

   factory Bank;
    address owner = 0x7CCbb89862f5cA9A83562Aa6cB8Af686c89A3701;
    address user1 = 0x2b90c6615546a35f19Da18ffb665cdba4c634a13;
    address user2 = 0x019D0706D65c4768ec8081eD7CE41F59Eef9b86c;
    address compound = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function setUp() public {
        vm.startPrank(owner);
        uint polygon = vm.createFork(
            "https://polygon-mainnet.g.alchemy.com/v2/Kfu0P4sjuA6I77BDTOiWxhMPm1BD307A"
        );
        vm.selectFork(polygon);
        Bank = new factory();
        Bank.set_Token(usdc);
        Bank.setCompound(compound);
        vm.stopPrank();
    }

    function testCreateAccount() public {
        vm.startPrank(user1);
        Bank.createAccount();
    }
}
