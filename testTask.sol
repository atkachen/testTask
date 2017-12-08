pragma solidity ^ 0.4.6;

import "dev.oraclize.it/api.sol";

contract UserCrud is usingOraclize {

    struct UserStruct {
        bytes32 userEmail;
        uint userAge;
        uint endTime;
        uint index;
    }

    mapping(address= > UserStruct) private userStructs;
    address[] private userIndex;

    event LogNewUser(address indexed userAddress, uint index, bytes32 userEmail, uint userAge);
    event LogPrintUser(address indexed userAddress, bytes32 userEmail, uint userAge);
    event LogUpdateUser(address indexed userAddress, uint index, bytes32 userEmail, uint userAge);
    event LogDeleteUser(address indexed userAddress, uint index);


    function UserCrud() {
         oraclize_query(3600, "URL", "");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        uint j = 0;
        for (uint i = 0; i < userIndex.length; i++){
            if (userStructs[userIndex[j]].endTime < now) deleteUser(userIndex[j]);
            else j++;
        }
    }

    function printAllUsers() {
        for (uint i = 0; i < userIndex.length; i++){
            LogPrintUser(userIndex[i], userStructs[userIndex[i]].userEmail, userStructs[userIndex[i]].userAge);
        }
    }

    function isUser(address userAddress) public constant returns(bool isIndeed) {
        if (userIndex.length == 0) return false;
        return (userIndex[userStructs[userAddress].index] == userAddress);
    }

    function insertUser(address userAddress, bytes32 userEmail, uint userAge, uint workTimeSec) public returns(uint index) {
        if (isUser(userAddress)) throw;
        userStructs[userAddress].userEmail = userEmail;
        userStructs[userAddress].userAge = userAge;
        userStructs[userAddress].endTime = now + workTimeSec;
        userStructs[userAddress].index = userIndex.push(userAddress) - 1;
        LogNewUser(
            userAddress,
            userStructs[userAddress].index,
            userEmail,
            userAge);

        return userIndex.length - 1;
    }

    function deleteUser(address userAddress) public returns(uint index) {
        if (!isUser(userAddress)) throw;
        uint rowToDelete = userStructs[userAddress].index;
        address keyToMove = userIndex[userIndex.length - 1];
        userIndex[rowToDelete] = keyToMove;
        userStructs[keyToMove].index = rowToDelete;
        userIndex.length--;
        LogDeleteUser(
            userAddress,
            rowToDelete);
        LogUpdateUser(
            keyToMove,
            rowToDelete,
            userStructs[keyToMove].userEmail,
            userStructs[keyToMove].userAge);

        return rowToDelete;
    }

    function getUser(address userAddress) public constant returns(bytes32 userEmail, uint userAge, uint index) {
        if (!isUser(userAddress)) throw;

        return (
            userStructs[userAddress].userEmail,
            userStructs[userAddress].userAge,
            userStructs[userAddress].index);
    }

    function updateUserEmail(address userAddress, bytes32 userEmail) public returns(bool success) {
        if (!isUser(userAddress)) throw;
        userStructs[userAddress].userEmail = userEmail;
        LogUpdateUser(
           userAddress,
           userStructs[userAddress].index,
           userEmail,
           userStructs[userAddress].userAge);

        return true;
    }

    function updateUserAge(address userAddress, uint userAge) public returns(bool success) {
        if (!isUser(userAddress)) throw;
        userStructs[userAddress].userAge = userAge;
        LogUpdateUser(
            userAddress,
            userStructs[userAddress].index,
            userStructs[userAddress].userEmail,
            userAge);

        return true;
    }

    function getUserCount() public constant returns(uint count) {
        return userIndex.length;
    }

    function getUserAtIndex(uint index) public constant returns(address userAddress) {
        return userIndex[index];
    }

}
