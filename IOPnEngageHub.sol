// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract IOPnEngageHub {

string public creator = "malamsunyi94";
string public ecosystem = "IOPn / OPN Chain";

mapping(address => uint256) public totalCheckIns;
mapping(address => uint256) public totalShips;
mapping(address => uint256) public lastCheckIn;

event ActionLogged(
    address indexed user,
    string actionName,
    uint256 timestamp
);

function dailyCheckIn() external {

    require(
        block.timestamp >= lastCheckIn[msg.sender] + 1 days,
        "Check-in once every 24h"
    );

    totalCheckIns[msg.sender] += 1;
    lastCheckIn[msg.sender] = block.timestamp;

    emit ActionLogged(
        msg.sender,
        "Daily Check In",
        block.timestamp
    );
}

function ship() external {

    totalShips[msg.sender] += 1;

    emit ActionLogged(
        msg.sender,
        "Ship",
        block.timestamp
    );
}

function getMyStats()
    external
    view
    returns (
        uint256 myCheckIns,
        uint256 myShips,
        uint256 nextCheckIn
    )
{
    return (
        totalCheckIns[msg.sender],
        totalShips[msg.sender],
        lastCheckIn[msg.sender] + 1 days
    );
}

}
