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
        require(msg.value == 1000000000000000000);

        bytes32 AllHash;

        if (NeedNewQue) {
            QueLimit = getLastBlockDigit();

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

        return AllHash;
    }

    function withdraw(bytes32 _armyHash) public {
        address[] memory SoldierList = Army[_armyHash];

        bytes32 SoldierHash = hashAddressList(SoldierList);

        address[] memory senderArray = new address[](1);
        senderArray[0] = msg.sender;
        bytes32 SenderHash = hashAddressList(senderArray);

        bytes32 AllHash = hashValues(SoldierHash, SenderHash);

        require(_armyHash == AllHash);

        // Total Balance constant now but it is developing to make it dynamic.
        uint256 TotalBalance = 1000000000000000000; 
        
        uint256 Commision = 1000000000000000000 / settings.CommisionRatio;
        payable(settings.CommisionWallet).transfer(Commision);

        TotalBalance -= (1000000000000000000 - Commision);

        uint8 SoldierCall = getLastBlockDigit();
        uint256 AmountPerSoldier = TotalBalance / SoldierCall;
        
        uint8 Counter = 0;

        while (TotalBalance > 1000000000000) // 12 decimal = 0.000001 BNB dust
        {
                Soldier NewSoldier = Soldier(SoldierList[Counter]);
                uint256 NewSoldierBalance = NewSoldier.soldierBalance();

                if (NewSoldierBalance > 0) {
                    if (NewSoldierBalance <= AmountPerSoldier) {
                        
                    NewSoldier.withdrawOrder(msg.sender, NewSoldierBalance);
                    TotalBalance -= NewSoldierBalance;

                    } else {
                        NewSoldier.withdrawOrder(msg.sender, AmountPerSoldier);
                        TotalBalance -= AmountPerSoldier;
                    }
                }

                if (Counter == SoldierList.length) {
                    Counter = 0;
                } else {
                    Counter += 1;
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

    function hashValues(bytes32 value1, bytes32 value2) public pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(value1, value2));
        return hash;
    }

    receive() external payable {}
}
