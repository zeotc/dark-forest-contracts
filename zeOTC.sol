// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./interfaces/IzeOTC.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract OTC is IOTC {
    using SafeERC20 for IERC20;

    /**
     * @dev Contract owner, able to withdraw fees.
     */
    address public feeRecipient;
    address public owner;
    /**
     * @dev Restrict function to the contract owner only.
     */

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyFeeRecipient() {
        require(msg.sender == feeRecipient, "Not allowed");
        _;
    }

    modifier onlyWhitelisted(address _asset) {
        require(whitelistedAssets[_asset], "Not whitelisted");
        _;
    }

    /**
     * @dev Set the initial owner to the deployer of the contract.
     */
    constructor(address _feeRecipient) {
        owner = msg.sender;
        feeRecipient = _feeRecipient;
    }

    // Whitelisted assets
    mapping(address => bool) public whitelistedAssets;
    // Asset data
    mapping(address => uint256) public assetFees;
    // Store all open asks: user => have_token => index => Ask
    // mapping(address => mapping(address => mapping(uint256 => Ask))) public openAsks;
    // Track each user's latest ask index: user => have_token => index => allOpenAsks ID
    mapping(address => mapping(address => mapping(uint256 => uint256))) public allOpenAsksIds;
    // Track number of open asks for a given asset: user => have_token => count
    mapping(address => mapping(address => uint256)) public openAsksCount;
    // All unmet asks: allOpenAsks[allOpenAsksIds<...>]
    Ask[] public allOpenAsks;

    // Track the outstanding fees eligible for withdrawal
    mapping(address => uint256) public feesPayable;
    // Track the contracts balances.
    mapping(address => uint256) internal balances;

    // Precision for all calcs
    uint256 public constant PRECISION = 1e18;

    // Make a new ask on behalf of 'onBehalfOf'
    function makeAsk(Ask memory ask, address _maker) external override onlyWhitelisted(ask.have) {
        // require(ask.index == 0, "Invalid index");
        require(ask.deadline > block.timestamp, "Invalid deadline");
        require(ask.amountHave > 0 && ask.amountWant > 0, "Invalid amounts");
        require(ask.have != ask.want, "Cannot want the same asset");
        _checkMaxAmount(ask.amountHave, ask.amountWant);

        // Transfer have token from maker to contract
        IERC20 haveToken = IERC20(ask.have);
        SafeERC20.safeTransferFrom(haveToken, _maker, address(this), ask.amountHave);

        // ID of the ask in the openAsks / allOpenAsksIds mapping
        uint256 id = openAsksCount[_maker][ask.have];
        // Index of the ask in the allOpenAsks array
        uint256 index = allOpenAsks.length;

        ask.index = id;

        allOpenAsks.push(ask);
        allOpenAsksIds[_maker][ask.have][id] = index;
        openAsksCount[_maker][ask.have]++;

        emit AskMade(_maker, ask.have, ask, id);
    }

    // Fill an ask as taker for an ask made by Maker for Asset at Idx.
    function fillAsk(address _taker, address _maker, address _asset, uint256 _idx)
        external
        override
        onlyWhitelisted(_asset)
    {
        Ask storage askToFill = allOpenAsks[allOpenAsksIds[_maker][_asset][_idx]];
        require(askToFill.amountHave > 0, "No valid ask found");
        require(askToFill.maker == _maker && askToFill.have == _asset && askToFill.index == _idx, "Incorrect fill");
        bool isExpired = _checkAndRemoveExpiredAsk(_maker, _asset, _idx, askToFill.deadline);
        if (isExpired) return;

        uint256 feeP = assetFees[_asset];
        uint256 feeAmount = (askToFill.amountWant * feeP) / PRECISION;
        uint256 netAmount = askToFill.amountWant - feeAmount;

        // Transfer want token from taker to contract
        IERC20 wantToken = IERC20(askToFill.want);
        SafeERC20.safeTransferFrom(wantToken, _taker, address(this), askToFill.amountWant);

        // Transfer net amount from contract to maker.
        // Note: maker gets charged the fee
        SafeERC20.safeTransfer(wantToken, _maker, netAmount);
        feesPayable[askToFill.want] += feeAmount;

        // Transfer have token from contract to taker
        IERC20 haveToken = IERC20(_asset);
        SafeERC20.safeTransfer(haveToken, _taker, askToFill.amountHave);

        _removeAskFromStorage(_maker, _asset, _idx);

        emit AskFilled(_maker, _taker, _asset, _idx, askToFill.amountHave, askToFill.amountWant);
    }

    function cancelOpenAsk(address _maker, address _asset, uint256 _id) external {
        Ask storage a = allOpenAsks[allOpenAsksIds[_maker][_asset][_id]];
        require(msg.sender == _maker && msg.sender == a.maker, "Invalid user");

        IERC20 haveToken = IERC20(_asset);
        haveToken.safeTransfer(msg.sender, a.amountHave);

        _removeAskFromStorage(_maker, _asset, _id);

        emit AskCancelled(_maker, _asset, _id);
    }

    function withdrawFees(address _asset, uint256 _amount) external onlyFeeRecipient {
        require(_amount <= feesPayable[_asset] && _amount > 0, "Invalid Amount");
        require(IERC20(_asset).balanceOf(address(this)) >= _amount, "Insufficient contract balance");

        SafeERC20.safeTransfer(IERC20(_asset), feeRecipient, _amount);
        feesPayable[_asset] -= _amount;

        emit FeesWithdrawn(_asset, feeRecipient, _amount);
    }

    function addWhitelistedAsset(address _asset, uint256 _feeP) external onlyOwner {
        require(_feeP < PRECISION, "Fee < 100% not allowed");
        whitelistedAssets[_asset] = true;
        assetFees[_asset] = _feeP;

        emit AssetWhitelisted(_asset, _feeP);
    }

    // *** internal functions ***
    function _checkAndRemoveExpiredAsk(address _maker, address _asset, uint256 _id, uint256 _deadline)
        internal
        returns (bool _isExpired)
    {
        _isExpired = _deadline < block.timestamp;

        if (_isExpired) {
            // Get the ask before removing it
            Ask storage askToRemove = allOpenAsks[allOpenAsksIds[_maker][_asset][_id]];
            
            // Transfer tokens back to maker
            IERC20 haveToken = IERC20(_asset);
            SafeERC20.safeTransfer(haveToken, _maker, askToRemove.amountHave);
            
            // Remove from storage
            _removeAskFromStorage(_maker, _asset, _id);
            
            emit AskCancelled(_maker, _asset, _id); // Emit event for expired ask
        }
    }

    function _checkMaxAmount(uint256 amountHave, uint256 amountWant) internal pure {
        require(amountHave < type(uint256).max && amountWant < type(uint256).max, "Exceeds max amount");
    }

    function _removeAskFromStorage(address _maker, address _asset, uint256 _id) internal {
        if (!hasOpenAsk(_maker, _asset, _id)) return;

        uint256 index = allOpenAsksIds[_maker][_asset][_id];
        allOpenAsks[index] = allOpenAsks[allOpenAsks.length - 1];
        allOpenAsksIds[allOpenAsks[index].maker][allOpenAsks[index].have][allOpenAsks[index].index] = index;

        delete allOpenAsksIds[_maker][_asset][_id];
        allOpenAsks.pop();
        openAsksCount[_maker][_asset]--;
    }

    function hasOpenAsk(address _maker, address _asset, uint256 _id) public view returns (bool) {
        if (allOpenAsks.length == 0) return false;
        Ask storage a = allOpenAsks[allOpenAsksIds[_maker][_asset][_id]];
        return a.maker == _maker && a.have == _asset && a.index == _id;
    }

    // for frontend
    function getAllOpenAsks() external view returns (Ask[] memory) {
        return allOpenAsks;
    }
}
