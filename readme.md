### INSTALLATIONS
#### Clone the repository
git clone https://github.com/spendNest/smartcontract.git

#### Navigate to the project directory
cd smartcontract

#### Install necessary dependencies
npm install


## Factory contract
https://mumbai.polygonscan.com/address/0xa8d1b6fab28a0b653befbdd3b1f8fe6ea36f78f5#writeContract

# Factory Smart Contract: An Overview
In the realm of blockchain and decentralized applications (dApps), a factory contract is a type of smart contract that is responsible for creating other contracts. It's akin to a production line in a factory, but instead of producing physical goods, it produces other smart contracts.

### The Purpose of the Factory Contract
The factory contract in the provided Ethereum Improvement Proposal (EIP) is designed to create and manage various aspects of a savings club on the Ethereum blockchain. It includes functions for creating an account, joining a savings club, adding funds to a savings club, and viewing public data related to the savings club.

## Responsibilities of the Factory Contract
The factory contract has several responsibilities:

 - Creating Accounts: The createAccount function allows a user to create a new account. This is typically the first step a user would take to interact with the savings club.

 - Returning Address: The _returnAddress function returns the address of the contract owner. This is useful for verifying the identity of the contract owner.

 - Token Address: The tokenAddress function returns the address of the token contract. This is important for interacting with the tokens associated with the savings club.

 - User Existence: The userExist function checks if a user exists. This is useful for verifying if a user is already a member of the savings club.

 - Creating Public Clubs: The createPublicClubs function allows a user to create a new public savings club. This function requires the name of the club, the start and end dates of the club, and the savings goal.

 - Joining a Savings Club: The joinSavingsClub function allows a user to join an existing savings club. The user needs to provide the name of the club they wish to join.

 - Adding Funds to a Savings Club: The addFundSavingsClub function allows a user to add funds to a savings club. The user needs to provide the name of the club, the amount they wish to add, and their user address.

 - Showing Public Data: The showPublicData function allows anyone to view public data related to the savings club. This includes the names of the clubs, the start and end dates, the savings goals, and the current savings amounts.

### Conclusion
In conclusion, the factory contract is a crucial component of the savings club dApp. It provides the functionality necessary for users to create accounts, join clubs, add funds, and view public data. By understanding the purpose and responsibilities of the factory contract, we can better understand how the savings club dApp operates on the Ethereum blockchain.



# SpendNest Overview.
https://mumbai.polygonscan.com/address/0x9E36522fa421fF0950a59A45741Bde0F18EF2B1D
### Introduction
The SpendNest smart contract is a decentralized application (dApp) that resides on the Ethereum blockchain. It is written in Solidity, a programming language specifically designed for creating smart contracts on the Ethereum platform.

In the realm of Web3, blockchain, and dApps, smart contracts like SpendNest are pivotal. They are self-executing contracts with the terms of the agreement directly written into the code. This allows them to automate complex operations, and once deployed, they are immutable and distributed across the blockchain network.

### Purpose of the SpendNest Contract
The SpendNest contract is designed to manage personal and shared savings in a decentralized manner. It is part of a larger system or dApp that enables users to create, manage, and interact with savings clubs.

A savings club, in this context, is a group of people who save money together. Each member contributes a certain amount at regular intervals, and the total savings can be used by members as per the rules defined in the contract.

### Key Features of the SpendNest Contract
The SpendNest contract includes several key features and functions:

    - State Variables: These are variables that hold the contract's state. For SpendNest, these include total savings, shared balance, number of clubs, borrowed amount, amount to be paid back, and personal savings.

    - Structs: The contract defines a struct called personalClubCreated. A struct is a custom data type that allows grouping of several data types. In this case, it includes club name, start date, end date, savings goal, and personal savings.

    - Mappings: These are data structures that allow linking of one data type to another, similar to a dictionary or a hash table. SpendNest uses mappings to track if an account is created and to link addresses to personal clubs.

    - Functions: The contract includes several functions that allow interaction with the contract. These include transferring funds between own accounts, transferring funds to another account, viewing account details, and withdrawing funds.

### Conclusion
In conclusion, the SpendNest contract is a sophisticated piece of code that forms a crucial part of a decentralized savings club application. It leverages the power of Ethereum's smart contracts to provide a secure, transparent, and automated system for managing personal and shared savings.

While the technical details can be complex, the underlying principles are straightforward: using blockchain technology to provide a decentralized solution for savings management. This is a prime example of how blockchain and smart contracts can revolutionize traditional financial systems and provide innovative solutions for savings and investment.


## LINKS
 - Figma: [https://www.figma.com/file/600pDBesFnMvjwRVWacKE3?type=design](https://www.figma.com/file/600pDBesFnMvjwRVWacKE3?type=design)

 - FrontEnd: [https://github.com/spendNest/frontendv2](https://github.com/spendNest/frontendv2)