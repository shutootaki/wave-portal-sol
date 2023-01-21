// WavePortal.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("WavePortal Smart Contract!");
        seed = ((block.difficulty + block.timestamp) % 100);
    }

    function wave(string memory _message) public {
        // 最後のWaveから15分以内にWaveを送った場合はトランザクションをストップする
        require(
            lastWavedAt[msg.sender] + 1 minutes < block.timestamp,
            "wait 1m"
        );

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = ((block.difficulty + block.timestamp) % 100);
        console.log("Random # generated: %d", seed);

        if (seed < 50) {
            console.log("%s Won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has"
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract");
        } else {
            console.log("%s did not win...", msg.sender);
        }
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We Have %d total waves!", totalWaves);
        return totalWaves;
    }
}
