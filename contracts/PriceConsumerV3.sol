// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    struct swapInfo {
        address swapFrom;
        address swapTo;
        address ownerAddress;
        uint256 usdcbalance;
        uint256 ethbalance;
    }

    struct buyInfo {
        address ownedtoken;
        uint256 buyAmount;
        uint256 balance;
        uint256 usdcbalance;
        uint256 ethbalance;
    }

    uint256 decimal = 10**18;

    uint256 swapId;

    mapping(uint256 => swapInfo) offer;

    mapping(address => buyInfo) buy;

    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor(address aggregator) {
        priceFeed = AggregatorV3Interface(aggregator);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/
            ,
            ,

        ) = /*uint timeStamp*/
            /*uint80 answeredInRound*/
            priceFeed.latestRoundData();
        return price;
    }

    function swapTokens(
        address _eth,
        uint256 _amount,
        address _usdc,
        address _owner
    ) public {
        swapInfo storage s = offer[swapId];
        s.swapFrom = _eth;
        s.swapTo = _usdc;
        s.ownerAddress = _owner;
        s.usdcbalance = 0;
        s.ethbalance = _amount;
        swapId++;
    }

    function swapper(
        uint256 _swapId,
        uint256 _amount,
        address _buyAdd,
        address _usdc
    ) public {
        swapInfo storage sI = offer[_swapId];
        // require(sI.amount, "amount too low");
        uint256 rate = uint256(getLatestPrice());
        uint256 sendUsdcAmount = rate / _amount;
        uint256 ethAmount = rate * _amount;
        // IERC20(sI.swapFrom).transfer(sI.ownerAddress, sendAmount);
        // IERC20(sI.swapTo).transferFrom(sI.ownerAddress,msg.sender , _amount);
        buy[_buyAdd].ownedtoken = _usdc;
        buy[_buyAdd].buyAmount = _amount;
        sI.usdcbalance += sendUsdcAmount;
        buy[_buyAdd].usdcbalance -= sendUsdcAmount;
        sI.ethbalance -= ethAmount;
        buy[_buyAdd].ethbalance += ethAmount;
    }

    function buyBal(address _buyAdd) public view returns (uint256) {
        return buy[_buyAdd].ethbalance;
    }
}
