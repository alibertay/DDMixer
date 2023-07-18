// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "contracts/DDSoldier.sol";

contract DDCommander {
    uint256 QueIndex;
    uint256 QueLimit;

    bool NeedNewQue = true;

    address[] ActiveSoldiers;

    mapping(bytes32 => address[]) Army;

    function deposit() public payable {
        require(msg.value == 1000000000000000000);

        if (NeedNewQue) {
            QueLimit = getLastBlockDigit();

            uint256 AmountPerSoldier = msg.value / QueLimit; // Now constant but workin on make it dynamic
            
            for (uint8 i = 0; i < QueLimit; i++) 
            {
                DDSoldier soldier = new DDSoldier();
                payable(address(soldier)).transfer(AmountPerSoldier);
                ActiveSoldiers.push(address(soldier));
            }

            bytes32 soldierHash = hashAddressList(ActiveSoldiers);
            Army[soldierHash] = ActiveSoldiers;

            QueIndex += 1;
            NeedNewQue = false;
        } else {
            uint256 AmountPerSoldier = msg.value / QueLimit; // Now constant but workin on make it dynamic
            
            for (uint8 i = 0; i < QueLimit; i++) 
            {
                payable(ActiveSoldiers[i]).transfer(AmountPerSoldier);
            }

            QueIndex += 1;

            if (QueIndex == QueLimit) {
                NeedNewQue = true;

                for (uint8 i = 0; i < ActiveSoldiers.length; i++) 
                {
                    ActiveSoldiers.pop();
                }
            }
        }
    }

    function getLastBlockDigit() public view returns (uint8) {
        uint8 lastBlock = uint8(block.number % 10);

        if (lastBlock < 2) {
            lastBlock = 3;
        }

        return lastBlock;
    }

    function hashAddressList(address[] memory addresses) public pure returns (bytes32) {
        bytes memory concatenatedAddresses = abi.encodePacked(addresses);
        bytes32 hash = keccak256(concatenatedAddresses);
        return hash;
    }

    receive() external payable {}
}
