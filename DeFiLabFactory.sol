// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract DeFiLabToken {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalSupply;
    address public creator;

    mapping(address => uint256) public balanceOf;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        address _creator
    ) {
        name = _name;
        symbol = _symbol;
        creator = _creator;

        totalSupply = _supply * 10 ** decimals;

        balanceOf[_creator] = totalSupply;

        emit Transfer(
            address(0),
            _creator,
            totalSupply
        );
    }

    function transfer(
        address to,
        uint256 amount
    ) external returns (bool) {

        require(
            balanceOf[msg.sender] >= amount,
            "Insufficient balance"
        );

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(
            msg.sender,
            to,
            amount
        );

        return true;
    }
}

contract DeFiLabFactory {

    address[] public allTokens;

    mapping(address => address[])
        public creatorTokens;

    event TokenCreated(
        address indexed token,
        address indexed creator,
        string name,
        string symbol,
        uint256 supply
    );

    function createToken(
        string memory name,
        string memory symbol,
        uint256 supply
    )
        external
        returns(address)
    {
        require(
            supply > 0,
            "Supply required"
        );

        DeFiLabToken token =
            new DeFiLabToken(
                name,
                symbol,
                supply,
                msg.sender
            );

        allTokens.push(
            address(token)
        );

        creatorTokens[msg.sender]
            .push(address(token));

        emit TokenCreated(
            address(token),
            msg.sender,
            name,
            symbol,
            supply
        );

        return address(token);
    }

    function getAllTokens()
        external
        view
        returns(address[] memory)
    {
        return allTokens;
    }

    function getMyTokens()
        external
        view
        returns(address[] memory)
    {
        return creatorTokens[msg.sender];
    }
}
