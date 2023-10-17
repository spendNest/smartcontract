// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SpendNest.sol";
import "../src/factory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SpendNestTest is Test {
   // using  SafeERC20 for IERC20; 
   factory Bank;
    address owner = 0x7CCbb89862f5cA9A83562Aa6cB8Af686c89A3701;
    address user1 = 0x2b90c6615546a35f19Da18ffb665cdba4c634a13;
    address user2 = 0x019D0706D65c4768ec8081eD7CE41F59Eef9b86c;
    address compound = 0xF25212E676D1F7F89Cd72fFEe66158f541246445;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    function setUp() public {
        vm.startPrank(owner);
      //   uint polygon = vm.createFork(
      //       "https://polygon-mainnet.g.alchemy.com/v2/Kfu0P4sjuA6I77BDTOiWxhMPm1BD307A"
      //   );
        uint polygon = vm.createFork(
            "https://polygon.rpc.thirdweb.com"
        );
        vm.selectFork(polygon);
        Bank = new factory();
        Bank.set_Token(usdc);
        Bank.setCompound(compound);
        vm.stopPrank();
    }

    function testCreateAccount() public {
        vm.prank(user1);
        Bank.createAccount();
        


    }
    
    function testdeposit() public {
      testCreateAccount();
      vm.startPrank(user1);
       address account = Bank._returnAddress(user1);
      SpendNest childBank = SpendNest(account);
      IERC20(usdc).approve(address(childBank), 1000000);
      childBank.depositFund(500000);
       childBank.viewAccount();
       vm.startPrank(user1);
       childBank.withdrawFund(10000);
       vm.stopPrank();

       vm.startPrank(user2);
      //   vm.prank(user2);
         Bank.createAccount();
      address account2 = Bank._returnAddress(user2);
      SpendNest childBank2 = SpendNest(account2);
      IERC20(usdc).approve(address(childBank2), 1000000);
      childBank2.depositFund(400000);
      vm.stopPrank();

      vm.prank(user1);
      childBank.transferFund(account2, 200000);

      vm.prank(user2);
       childBank2.viewAccount();
      
      // childBank.showMyPersonalCreatedClub();
     

    }
    

   //  function testviewAccount() public{
   //    testdeposit();
     
   //  }
}
