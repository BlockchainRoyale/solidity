pragma solidity ^0.4.24;

contract GameFactory{

    address[] public deployedGames;

    function startGame(uint buyInAmount) public {
        address newGame = new Game(msg.sender, buyInAmount);
        deployedGames.push(newGame);
    }

    function getDeployedGames() public view returns (address[]) {
        return deployedGames;
    }
}

contract Game {

    struct Player {
        uint location;
        address playerAddress;
        mapping(uint => bool) objects;
        bool inBattle;
        bool alive;
    }

    uint constant mapBoundary = 10;
    uint buyInAmount;
    uint playerCount;
    Player[] public players;
    mapping(address => bool) isPlayer;

    constructor(address creator, uint amount) public {
        isPlayer[creator] = true;
        buyInAmount = amount;
        Player memory newPlayer = ({
        location: 0,
        playerAddress: creator,
        inBattle: false,
        alive: true
        });
        players.push(newPlayer);
    }

    function joinGame() public payable {
        require(msg.value == buyInAmount);
        isPlayer[msg.sender] = true;
        Player memory newPlayer = ({
        location: 0,
        playerAddress: msg.sender,
        inBattle: false,
        alive: true
        })
        players.push(newPlayer);
    }


    function generateRandomObjects() private view returns (uint) {
        return(random() % mapBoundary * 10) + random() % mapBoundary;
    }

    function generateRandomLocation() private view returns (uint) {
        return random() % 4 + 1;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(
                players[0].playerAddress,
                players[1].playerAddress,
                players[2].playerAddress,
                players[3].playerAddress)));
    }


}

contract Battle{

    uint battleSize = 7;
    address player1;
    bool[] player1Weapons;
    string player1Moves;
    address player2;
    bool[] player2Weapons;
    string player2Moves;
    uint objectLocation;
    uint object;

    constructor
    (address playerOne, bool[] playerOneWeapons, string player1hash, address playerTwo, bool[] playerTwoWeapons, string player2hash, uint randomObject, uint randomObjectLocation)
    public {
        player1 = playerOne;
        player1Weapons = playerOneWeapons;
        player1Moves = player1hash;
        player2 = playerTwo;
        player2Weapons = playerTwoWeapons;
        player2Moves = player2hash;
        objectLocation = randomObjectLocation;
        object = randomObject;
    }

}