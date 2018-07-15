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
        bytes32 moveHash;
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

    function initiateBattle(address opponentAdd, bytes32 hashOfMove) public {
        Player storage initiator = players[playerIndex[msg.sender]];
        Player storage personToAttack = players[playerIndex[opponentAdd]];
        require(initiator.location == personToAttack.location);
        initiator.opponentAddress = opponentAdd;
        personToAttack.opponentAddress = msg.sender;
        initiator.moveHash = hashOfMove;
    }

    function startBattle(uint[] moves) public {
        Player storage defender = players[playerIndex[msg.sender]];
        Player storage initiator = players[playerIndex[defender.opponentAddress]];
        require(initiator.opponentAddress == msg.sender);
        if (!(initiator.moveHash.length == 0)) {
            address newBattle = new Battle(initiator.playerAddress,
                initiator.moveHash,
                defender.playerAddress,
                moves,
                this);
            defender.inBattle = newBattle;
            initiator.inBattle = newBattle;
        }
    }
}

contract Battle{

    uint public battleSize = 7;
    address public initiator;
    bytes32 public initiatorHash;
    uint[] public initiatorMoves;
    uint public initiatorLocationY;
    uint public initiatorLocationX;
    address public defender;
    bytes32 public defenderHash;
    uint[] public defenderMoves;
    uint public defenderLocationX;
    uint public defenderLocationY;
    uint public turnNumber;
    Game public game;

    constructor(address _initiator,
        bytes32 _initiatorHash,
        address _defender,
        uint[] defenderMoves,
        address _game)
    public {
        initiator = _initiator;
        initiatorHash = _initiatorHash;
        initiatorLocationY = generateStartingLocation();
        initiatorLocationX = generateStartingLocation();
        defenderLocationY = generateStartingLocation();
        defenderLocationX = generateStartingLocation();
    }

    function verifyMove(uint[] _moves, bytes32 hashToCompare) returns (bool){
        return keccak256(abi.encodePacked(_moves)) == hashToCompare;
    }

    function generateStartingLocation() public returns (uint) {
        return 10 ; // need to fix keccak256(abi.encodePacked(block.difficulty, now)) % battleSize;
    }
}
