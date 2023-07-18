// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract DDSoldier {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function withdrawOrder(address _toWallet, uint256 _value) public onlyOwner {
        payable(_toWallet).transfer(_value);
    }

    function soldierBalance() public view returns(uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
