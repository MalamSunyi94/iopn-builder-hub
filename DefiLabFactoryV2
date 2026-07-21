// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BuilderToken {

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        address _owner
    ){
        name = _name;
        symbol = _symbol;
        owner = _owner;

        totalSupply = _supply * 1e18;

        balanceOf[_owner] = totalSupply;

        emit Transfer(address(0),_owner,totalSupply);
    }

    function transfer(address to,uint256 amount)
        external
        returns(bool)
    {
        require(balanceOf[msg.sender] >= amount,"Balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender,to,amount);

        return true;
    }

    function approve(address spender,uint256 amount)
        external
        returns(bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender,spender,amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        external
        returns(bool)
    {
        require(balanceOf[from] >= amount,"Balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Allowance"
        );

        allowance[from][msg.sender] -= amount;

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from,to,amount);

        return true;
    }
}

contract TokenFactoryV2 {

    address[] public allTokens;

    mapping(address=>address[]) public myTokens;

    event TokenCreated(
        address indexed creator,
        address indexed token,
        string name,
        string symbol,
        uint256 supply
    );

    function createToken(
        string calldata name,
        string calldata symbol,
        uint256 supply
    )
        external
        returns(address)
    {
        BuilderToken token =
            new BuilderToken(
                name,
                symbol,
                supply,
                msg.sender
            );

        allTokens.push(address(token));

        myTokens[msg.sender].push(address(token));

        emit TokenCreated(
            msg.sender,
            address(token),
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
        return myTokens[msg.sender];
    }

    function totalTokens()
        external
        view
        returns(uint256)
    {
        return allTokens.length;
    }
}
