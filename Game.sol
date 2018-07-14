pragma solidity ^0.4.24;

contract GameFactory{

    address[] public deployedGames;

    function startGame(uint buyInAmount) public {
        address newGame = new Game(msg.sender);
        deployedGames.push(newGame);
    }

    function getDeployedGames() public view returns (address[]) {
        return deployedGames;
    }
}

contract Game {

    struct Player {
        bool[] inventory;
        uint location;
        address playerAddress;
        mapping(address => uint) playerID;
    }

    uint constant mapBoundary = 5;
    uint constant buyInAmount = 100;
    uint constant numberOfPlayers = 4;
    Player[] public players;
    mapping(address => bool) isPlayer;
    mapping(uint => uint) objects;

    constructor(address creator) public {
        isPlayer[creator] = true;
    }

    function joinGame() public payable {
        require(msg.value == buyInAmount);
        isPlayer[msg.sender] = true;
    }

    function generateObjects() private view {
        randomLocation = (random() % mapBoundary * 10) + random() % mapBoundary;
        objects[randomLocation] = random() % 4 + 1;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(
                players[0].playerAddress,
                players[1].playerAddress,
                players[2].playerAddress,
                players[3].playerAddress)));
    }

}