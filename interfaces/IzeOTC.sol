pragma solidity ^0.8.23;

interface IOTC {
    struct Ask {
        address maker; // you
        uint256 amountHave; // ex. 0.0001 BTC
        uint256 amountWant; // ex. 1000 USDT
        address have; // ex. BTC
        address want; // ex. USDT
        uint256 deadline; // unix
        uint256 index;
    }

    struct Bid {
        uint256 amount;
        address want;
    }

    struct Token {
        uint8 decimals;
        uint256 totalSupply;
        uint256 feePercentage; // PRECISION
    }

    event AskMade(address indexed maker, address indexed asset, Ask ask, uint256 indexed idx);

    event AskFilled(
        address indexed maker,
        address indexed taker,
        address indexed asset,
        uint256 idx,
        uint256 amountHave,
        uint256 amountWant
    );

    event AskCancelled(address indexed maker, address indexed asset, uint256 idx);

    event AssetWhitelisted(address indexed asset, uint256 feePercentage);

    event FeesWithdrawn(address indexed asset, address indexed recipient, uint256 amount);

    function makeAsk(Ask calldata ask, address maker) external;

    function getAllOpenAsks() external view returns (Ask[] memory);

    function fillAsk(address taker, address maker, address asset, uint256 idx) external;

    function cancelOpenAsk(address maker, address asset, uint256 idx) external;

    function withdrawFees(address asset, uint256 amount) external;

    function addWhitelistedAsset(address asset, uint256 feePercentage) external;

    function hasOpenAsk(address maker, address asset, uint256 idx) external view returns (bool);
}
