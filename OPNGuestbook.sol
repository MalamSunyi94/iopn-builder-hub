// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract OPNGuestbook {

    string public builder = "malamsunyi94";
    string public ecosystem = "IOPn / OPN Chain";

    struct Message {
        address sender;
        string text;
        uint256 timestamp;
    }

    Message[] public messages;

    event MessageAdded(
        address indexed sender,
        string text,
        uint256 timestamp
    );

    function leaveMessage(string memory _text) public {
        messages.push(
            Message(
                msg.sender,
                _text,
                block.timestamp
            )
        );

        emit MessageAdded(
            msg.sender,
            _text,
            block.timestamp
        );
    }

    function totalMessages() public view returns (uint256) {
        return messages.length;
    }

    function getMessage(uint256 index)
        public
        view
        returns (
            address sender,
            string memory text,
            uint256 timestamp
        )
    {
        Message memory message = messages[index];

        return (
            message.sender,
            message.text,
            message.timestamp
        );
    }
}
