# Dark Forest Underground: Decentralized OTC Market for AI Trading Agents

Dark Forest Underground is a decentralized over-the-counter (OTC) trading protocol built across multiple chains (Base, Solana, and EVMs), designed specifically for facilitating large-scale token trades between AI agents and human traders.

## Overview

Dark Forest provides essential infrastructure for peer-to-peer value exchange in the DeFAI ecosystem, enabling AI agents to trade directly with each other and with humans, particularly for assets with limited AMM liquidity.

Key features:
- **Trustless OTC Trading**: Execute large trades without the slippage associated with AMMs
- **AI Agent Integration**: Built from the ground up to work with autonomous trading agents
- **Immature Market Support**: Trade newly launched tokens with minimal liquidity
- **Multi-Chain Architecture**: Seamlessly operate across Base, Solana, and all EVM-compatible chains
- **Cross-Protocol Compatibility**: Works with HeyAnon (live), coming soon to ElizaOS and more

## Contract Architecture

The core of Dark Forest Underground is a multi-chain smart contract system that facilitates the creation, discovery, and fulfillment of OTC trades:

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

## Using Dark Forest Underground

### For Traders

1. **Create an Ask**: Specify what token you have and what token you want
2. **Find Open Asks**: Browse available trades using `getAllOpenAsks()`
3. **Fill an Ask**: Execute a trade by filling an open ask

### For Developers

Dark Forest Underground operates as a custom ZerePy plugin with expanding compatibility for HeyAnon, ElizaOS, and future agent frameworks, all built on Zerebro's advanced agent infrastructure. Check out our example agents:
- **Dark Forest Agent Alpha**: A calculating, risk-focused AI trader
- **Dark Forest Agent Beta**: An intuition-driven trading agent

## Tech Stack

- Multi-chain architecture spanning Base, Solana and EVMs
- ZerePy integration for agent framework (supports OpenAI, Anthropic, Farcaster)
- GOAT (Great Onchain Agent Toolkit) compatibility
- Works with HeyAnon (live), coming soon to ElizaOS and more
- Agent-powered price discovery and execution

## Security Features

- ERC20 SafeTransfer usage for all token transfers
- Expiration mechanism for outdated orders
- Whitelist system for asset control
- Cross-chain validation for multi-chain operations
- Owner privileges limited to essential administrative functions

## Integration Capabilities

Dark Forest Underground extends the actions component of various agent frameworks, enabling agents to:
- Periodically perform transactions across multiple networks
- Interact directly with the OTC market contract
- Execute trading algorithms for token balancing
- Operate autonomously across chain boundaries

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

---

## Test Agents

Our reference implementation includes autonomous AI trading agents that demonstrate the Dark Forest Underground protocol in action:

**Dark Forest Agent Alpha**: A calculating trader designed to find value in the memecoin markets
**Dark Forest Agent Beta**: An intuition-driven approach to OTC trading

These agents showcase how AI traders can interact with the Dark Forest Underground protocol to execute trades autonomously across multiple blockchains.
