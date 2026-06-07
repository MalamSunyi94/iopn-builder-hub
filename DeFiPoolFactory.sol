// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract DeFiPool {
    IERC20 public token;
    address public creator;

    uint256 public reserveNative;
    uint256 public reserveToken;

    uint256 public constant FEE = 3;
    uint256 public constant FEE_DENOMINATOR = 1000;

    event LiquidityAdded(address indexed provider, uint256 nativeAmount, uint256 tokenAmount);
    event SwappedNativeToToken(address indexed user, uint256 nativeIn, uint256 tokenOut);
    event SwappedTokenToNative(address indexed user, uint256 tokenIn, uint256 nativeOut);

    constructor(address _token, address _creator) {
        require(_token != address(0), "Invalid token");
        token = IERC20(_token);
        creator = _creator;
    }

    function addLiquidity(uint256 tokenAmount) external payable {
        require(msg.value > 0, "Native required");
        require(tokenAmount > 0, "Token required");

        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "Token transfer failed"
        );

        reserveNative += msg.value;
        reserveToken += tokenAmount;

        emit LiquidityAdded(msg.sender, msg.value, tokenAmount);
    }

    function getAmountOut(uint256 amountIn, bool nativeToToken)
        public
        view
        returns (uint256)
    {
        require(amountIn > 0, "Invalid amount");

        uint256 reserveIn = nativeToToken ? reserveNative : reserveToken;
        uint256 reserveOut = nativeToToken ? reserveToken : reserveNative;

        require(reserveIn > 0 && reserveOut > 0, "No liquidity");

        uint256 amountInWithFee = amountIn * (FEE_DENOMINATOR - FEE);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * FEE_DENOMINATOR + amountInWithFee;

        return numerator / denominator;
    }

    function swapNativeToToken() external payable {
        require(msg.value > 0, "Native required");

        uint256 tokenOut = getAmountOut(msg.value, true);

        require(tokenOut > 0, "Zero output");
        require(tokenOut < reserveToken, "Low token liquidity");

        reserveNative += msg.value;
        reserveToken -= tokenOut;

        require(token.transfer(msg.sender, tokenOut), "Token transfer failed");

        emit SwappedNativeToToken(msg.sender, msg.value, tokenOut);
    }

    function swapTokenToNative(uint256 tokenAmount) external {
        require(tokenAmount > 0, "Token required");

        uint256 nativeOut = getAmountOut(tokenAmount, false);

        require(nativeOut > 0, "Zero output");
        require(nativeOut < reserveNative, "Low native liquidity");

        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "Token transfer failed"
        );

        reserveToken += tokenAmount;
        reserveNative -= nativeOut;

        (bool success, ) = payable(msg.sender).call{value: nativeOut}("");
        require(success, "Native transfer failed");

        emit SwappedTokenToNative(msg.sender, tokenAmount, nativeOut);
    }

    function getReserves()
        external
        view
        returns (uint256 nativeAmount, uint256 tokenAmount)
    {
        return (reserveNative, reserveToken);
    }

    receive() external payable {}
}

contract DeFiPoolFactory {
    address[] public allPools;

    mapping(address => address) public tokenToPool;
    mapping(address => address[]) public creatorPools;

    event PoolCreated(
        address indexed token,
        address indexed pool,
        address indexed creator
    );

    function createPool(address tokenAddress) external returns (address) {
        require(tokenAddress != address(0), "Invalid token");
        require(tokenToPool[tokenAddress] == address(0), "Pool exists");

        DeFiPool pool = new DeFiPool(tokenAddress, msg.sender);

        tokenToPool[tokenAddress] = address(pool);
        creatorPools[msg.sender].push(address(pool));
        allPools.push(address(pool));

        emit PoolCreated(tokenAddress, address(pool), msg.sender);

        return address(pool);
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    function getMyPools() external view returns (address[] memory) {
        return creatorPools[msg.sender];
    }

    function totalPools() external view returns (uint256) {
        return allPools.length;
    }
}
