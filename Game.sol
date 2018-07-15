pragma solidity ^0.4.24;

contract GameFactory{

    address[] public deployedGames;

    function startGame(uint buyInAmount, string userName) public {
        address newGame = new Game(msg.sender, buyInAmount, userName);
        deployedGames.push(newGame);
    }

    function getDeployedGames() public view returns (address[]) {
        return deployedGames;
    }
}

contract Game {

    struct Player {
        string userName;
        uint location;
        address playerAddress;
        address opponentAddress;
        address inBattle;
        mapping(uint => bool) objects;
        bool alive;
        string moveHash;
    }

    uint constant public mapBoundary = 10;
    uint constant public maxPlayers = 4;
    uint public buyInAmount;
    uint public numberOfPlayers = 0;
    Player[] public players;
    mapping(address => uint) public playerIndex;
    bool gameActive = false;

    constructor(address creator, uint amount, string name) public {
        buyInAmount = amount;

        Player memory newPlayer = Player({
            userName: name,
            location: 0,
            playerAddress: creator,
            opponentAddress: 0,
            inBattle: 0,
            alive: true,
            moveHash: ''
            });

        players.push(newPlayer);
        playerIndex[creator] = numberOfPlayers;
        numberOfPlayers++;
    }

    function joinGame(string displayName) public payable {
        require(msg.value == buyInAmount);
        require(numberOfPlayers < maxPlayers);
        Player memory newPlayer = Player({
            userName: displayName,
            location: 0,
            playerAddress: msg.sender,
            opponentAddress: 0,
            inBattle: 0,
            alive: true,
            moveHash: ''
            });

        players.push(newPlayer);
        playerIndex[msg.sender] = numberOfPlayers;
        numberOfPlayers++;

        if (players.length == maxPlayers) {
            startGame();
        }
    }

    function generateRandomLocation() private view returns (uint) {
        return(random() % mapBoundary * 10) + random() % mapBoundary;
    }

    function generateRandomObject() private view returns (uint) {
        return random() % 4 + 1;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(
                players[0].playerAddress,
                players[1].playerAddress,
                players[2].playerAddress,
                players[3].playerAddress)));
    }

    function startGame() public{
        require(numberOfPlayers == maxPlayers);
        for(uint i = 0; i < maxPlayers; i++){
            players[i].location = generateRandomLocation();
        }
        gameActive = true;
    }

    function initiateBattle(address opponentAdd, string hashOfMove) public {
        Player storage initiator = players[playerIndex[msg.sender]];
        Player storage personToAttack = players[playerIndex[opponentAdd]];
        require(initiator.location == personToAttack.location);
        initiator.opponentAddress = opponentAdd;
        personToAttack.opponentAddress = msg.sender;
        initiator.moveHash = hashOfMove;
    }

    function startBattle(uint[] moves) public {
        Player storage respondent = players[playerIndex[msg.sender]];
        Player storage initiator = players[playerIndex[respondent.opponentAddress]];
        require(initiator.opponentAddress == msg.sender);
        bytes memory hashSubmitted = bytes(initiator.moveHash); // Uses memory
        if (hashSubmitted.length == 0) {
            address newBattle = new Battle(msg.sender, moves, initiator.playerAddress, initiator.moveHash);
            respondent.inBattle = newBattle;
            initiator.inBattle = newBattle;
        }
    }
}

contract Battle{

    uint public battleSize = 7;
    address public player1;
    string public player1hash;
    string public player1Moves;
    address public player2;
    string public player2hash;
    string public player2Moves;

    constructor(address playerOne,
        uint[] moves,
        address playerTwo,
        string playerTwoHash) public {
        player1 = playerOne;
        player1Moves = player1hash;
        player2 = playerTwo;
        player2Moves = player2hash;
    }

}