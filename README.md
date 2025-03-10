# ZeOTC: Decentralized OTC Market for AI Trading Agents

ZeOTC is a decentralized over-the-counter (OTC) trading protocol built on Sonic, designed specifically for facilitating large-scale token trades between AI agents and human traders.

## Overview

ZeOTC provides essential infrastructure for peer-to-peer value exchange in the DeFAI ecosystem, enabling AI agents to trade directly with each other and with humans, particularly for assets with limited AMM liquidity.

Key features:
- **Trustless OTC Trading**: Execute large trades without the slippage associated with AMMs
- **AI Agent Integration**: Built from the ground up to work with autonomous trading agents
- **Immature Market Support**: Trade newly launched tokens with minimal liquidity

## Contract Architecture

The core of ZeOTC is a Solidity smart contract that facilitates the creation, discovery, and fulfillment of OTC trades:

### Key Functions

- `makeAsk(Ask memory ask, address _maker)`: Create a new ask order, specifying the tokens to exchange and their amounts
- `fillAsk(address _taker, address _maker, address _asset, uint256 _idx)`: Fill an existing ask order
- `cancelOpenAsk(address _maker, address _asset, uint256 _id)`: Cancel an open ask order
- `withdrawFees(address _asset, uint256 _amount)`: Withdraw collected fees (admin only)
- `addWhitelistedAsset(address _asset, uint256 _feeP)`: Add new tokens to the whitelist (admin only)

### Data Structures

The contract uses a custom `Ask` struct to represent trade orders:

```solidity
struct Ask {
    address maker;
    address have;
    address want;
    uint256 amountHave;
    uint256 amountWant;
    uint256 deadline;
    uint256 index;
}
```

## Using ZeOTC

### For Traders

1. **Create an Ask**: Specify what token you have and what token you want
2. **Find Open Asks**: Browse available trades using `getAllOpenAsks()`
3. **Fill an Ask**: Execute a trade by filling an open ask

### For Developers

ZeOTC is designed to be integrated with AI agents using the ZerePy framework. Check out our example agents:
- **ZeOTCAgent0**: A calculating, risk-focused AI trader
- **ZeOTCAgent1**: An intuition-driven trading agent

## Security Features

- ERC20 SafeTransfer usage for all token transfers
- Expiration mechanism for outdated orders
- Whitelist system for asset control
- Owner privileges limited to essential administrative functions

## Integration with ZerePy

ZeOTC extends the Sonic actions component of the ZerePy framework, enabling agents to:
- Periodically perform transactions on Sonic's network
- Interact directly with the OTC market contract
- Execute trading algorithms for token balancing

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

---

## Test Agents

Our reference implementation includes two autonomous AI trading agents that demonstrate the ZeOTC protocol in action:

**ZeOTCAgent0**: A calculating trader designed to find value in the memecoin markets
**ZeOTCAgent1**: An intuition-driven approach to OTC trading

These agents showcase how AI traders can interact with the ZeOTC protocol to execute trades autonomously.
