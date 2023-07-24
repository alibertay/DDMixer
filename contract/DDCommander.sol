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

    bool NeedNewQue = true;

    address[] ActiveSoldiers;
    bytes32[] Garrisons;

    mapping(bytes32 => address[]) Army;

    struct Settings {
        address CommisionWallet;
        uint256 CommisionRatio;
    }

    Settings settings;

    constructor(address _CommisionWallet, uint256 _CommisionRatio) {
        settings.CommisionWallet = _CommisionWallet;
        settings.CommisionRatio = _CommisionRatio;
    }

    function deposit(bytes32 _toWalletHash) public payable returns(bytes32) {
        require(msg.value == 10000000000000000);

        bytes32 AllHash;

        if (NeedNewQue) {
            QueLimit = getLastBlockDigit(true);

            uint256 AmountPerSoldier = msg.value / QueLimit; // Now constant but workin on make it dynamic

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
            uint256 AmountPerSoldier = msg.value / QueLimit; // Now constant but workin on make it dynamic

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
        uint256 TotalBalance = 1000000000000000000;

        uint256 Commision = 1000000000000000000 / settings.CommisionRatio;
        payable(settings.CommisionWallet).transfer(Commision);

        TotalBalance -= (1000000000000000000 - Commision);

        uint256 GarrisonIndex = getLastBlockDigit(false);

        bytes32 Garrison = Garrisons[GarrisonIndex];

        SoldierList = Army[Garrison];

        uint256 AmountPerSoldier = TotalBalance / SoldierList.length;

        for (uint8 i = 0; i < SoldierList.length; i++)
        {
            payable(msg.sender).transfer(AmountPerSoldier);
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

        address[] memory CalledSoldiers = Army[Garrisons[factor]];

        uint8 SoldiersCount = 0;

        while (SoldiersCount == 0) {
            if (CalledSoldiers.length == 0) {
                factor += 1;
                CalledSoldiers = Army[Garrisons[factor]];
            }
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

    receive() external payable {}
}