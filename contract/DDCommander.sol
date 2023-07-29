// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "contracts/DDSoldier.sol";

interface Soldier {
    function withdrawOrder(address _toWallet, uint256 _value) external;
    function soldierBalance() external view returns(uint256);
}

contract DDCommander {
    uint256 QueIndex;
    uint256 QueLimit;
    uint256 TotalCommision;

    address owner;

    bool NeedNewQue = true;

    address[] ActiveSoldiers;
    bytes32[] Garrisons;

    mapping(bytes32 => address[]) Army;

    constructor(){
        owner = msg.sender;
    }

    function deposit(bytes32 _toWalletHash) public payable returns(bytes32) {
        require(msg.value >= 11000000000000000); // /10 is commision

        bytes32 AllHash;

        if (NeedNewQue) {
            QueLimit = getLastBlockDigit(true);

            uint256 AmountPerSoldier = 10000000000000000 / QueLimit; // Now constant but workin on make it dynamic

            for (uint8 i = 0; i < QueLimit; i++)
            {
                DDSoldier soldier = new DDSoldier();
                payable(address(soldier)).transfer(AmountPerSoldier);
                ActiveSoldiers.push(address(soldier));
            }

            bytes32 SoldierHash = hashAddressList(ActiveSoldiers);
            AllHash = hashValues(SoldierHash, _toWalletHash);
            Army[AllHash] = ActiveSoldiers;

            QueIndex += 1;
            NeedNewQue = false;
        } else {
            uint256 AmountPerSoldier = 10000000000000000 / QueLimit; // Now constant but workin on make it dynamic

            for (uint8 i = 0; i < QueLimit; i++)
            {
                payable(ActiveSoldiers[i]).transfer(AmountPerSoldier);
            }

            bytes32 SoldierHash = hashAddressList(ActiveSoldiers);
            AllHash = hashValues(SoldierHash, _toWalletHash);
            Army[AllHash] = ActiveSoldiers;

            QueIndex += 1;

            if (QueIndex == QueLimit) {
                NeedNewQue = true;

                for (uint8 i = 0; i < ActiveSoldiers.length; i++)
                {
                    ActiveSoldiers.pop();
                }
            }
        }

        Garrisons.push(AllHash);

        TotalCommision += msg.value - 10000000000000000;

        return AllHash;
    }

    function withdraw(bytes32 _armyHash) public {
        address[] memory SoldierList = Army[_armyHash];

        bytes32 SoldierHash = hashAddressList(SoldierList);

        address[] memory senderArray = new address[](1);
        senderArray[0] = msg.sender;
        bytes32 SenderHash = hashAddressList(senderArray);

        bytes32 AllHash = hashValues(SoldierHash, SenderHash);

        require(_armyHash == AllHash, "You are not the receiver.");

        // Total Balance constant now but it is developing to make it dynamic.
        uint256 TotalBalance = 10000000000000000;

        uint256 GarrisonIndex = getLastBlockDigit(false);

        bytes32 Garrison = Garrisons[GarrisonIndex];

        SoldierList = Army[Garrison];

        uint256 AmountPerSoldier = TotalBalance / SoldierList.length;

        for (uint8 i = 0; i < SoldierList.length; i++)
        {
            Soldier soldier = Soldier(SoldierList[i]);
            soldier.withdrawOrder(msg.sender, AmountPerSoldier);
        }

        delete Garrisons[GarrisonIndex];
        delete Army[Garrison];

    }

    function getLastBlockDigit(bool isDeposit) public view returns (uint256) {
        uint256 lastBlock;

        if (isDeposit) {
            lastBlock = uint256(block.number % 10);

            if (lastBlock < 2) {
                lastBlock = 3;
            }
        } else {
            uint256 factor = findTheFactor();

            lastBlock = uint256(block.number % 10 * factor);

            if (lastBlock > Garrisons.length) {
                lastBlock = Garrisons.length;
        }

            if (lastBlock >= Garrisons.length) {
                lastBlock = Garrisons.length - 1; // boş çıkarsa garrison karşısındaki, başka kontrata geç gelecek
            }
        }

        return lastBlock;

    }

    function findTheFactor() private view returns(uint256) {
        uint256 factor;
        uint256 GarrisonsLength = Garrisons.length;
        if (GarrisonsLength < 10) {
            factor = 1;
        } else if (GarrisonsLength >= 10 && GarrisonsLength < 100) {
            factor = 2;
        } else if (GarrisonsLength >= 100 && GarrisonsLength < 1000) {
            factor = 3;
        } else {
            factor = 4;
        }

        return factor;
    }

    function hashAddressList(address[] memory addresses) public pure returns (bytes32) {
        bytes memory concatenatedAddresses = abi.encodePacked(addresses);
        bytes32 hash = keccak256(concatenatedAddresses);
        return hash;
    }

    function hashValues(bytes32 value1, bytes32 value2) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(value1, value2));
        return hash;
    }

    function commision() public {
        require(msg.sender == owner, "This is an only owner function!");

        payable(owner).transfer(TotalCommision);
        TotalCommision = 0;
    }

    receive() external payable {}
}