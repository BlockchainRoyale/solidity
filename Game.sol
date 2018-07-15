pragma solidity ^0.4.24;

contract GameFactory{

    address[] public deployedGames;

    function startGame(string userName, uint randomNumber) public payable{
        address newGame = new Game(msg.sender, msg.value, userName, randomNumber);
        deployedGames.push(newGame);
    }

    function getDeployedGames() public view returns (address[]) {
        return deployedGames;
    }
}

contract Game {

    struct Player {
        string userName;
        uint x;
        uint y;
        address playerAddress;
        address opponentAddress;
        address inBattle;
        mapping(uint => bool) objects;
        bool alive;
        bytes32 moveHash;
        uint playerRandomNumber;
    }

    uint constant public mapBoundary = 10;
    uint constant public maxPlayers = 4;
    uint public buyInAmount;
    uint public numberOfPlayers = 0;
    Player[] public players;
    mapping(address => uint) public playerIndex;
    bool gameActive = false;

    constructor(address creator, uint amount, string name, uint randomNumber) public {
        buyInAmount = amount;

        Player memory newPlayer = Player({
            userName: name,
            x: 0,
            y: 0,
            playerAddress: creator,
            opponentAddress: 0,
            inBattle: 0,
            alive: true,
            moveHash: '',
            playerRandomNumber: randomNumber
            });

        players.push(newPlayer);
        playerIndex[creator] = numberOfPlayers;
        numberOfPlayers++;
    }

    function joinGame(string displayName, uint randomNumber) public payable {
        require(msg.value == buyInAmount);
        require(numberOfPlayers < maxPlayers);
        Player memory newPlayer = Player({
            userName: displayName,
            x: 0,
            y: 0,
            playerAddress: msg.sender,
            opponentAddress: 0,
            inBattle: 0,
            alive: true,
            moveHash: '',
            playerRandomNumber: randomNumber
            });

        players.push(newPlayer);
        playerIndex[msg.sender] = numberOfPlayers;
        numberOfPlayers++;

        if (players.length == maxPlayers) {
            startGame();
        }
    }

    function randomNumberwithinMap(uint _mapSize, uint randomNumber) public returns (uint) {
        return uint(keccak256(abi.encodePacked(randomNumber, block.difficulty, now))) % _mapSize;
    }

    function generateRandomObject() private view returns (uint) {
        return random() % 4 + 1;
    }

    function random() private view returns (uint ) {
        return uint(keccak256(abi.encodePacked(
                players[0].playerAddress,
                players[1].playerAddress,
                players[2].playerAddress,
                players[3].playerAddress,
                now)));
    }

    function startGame() public{
        require(numberOfPlayers == maxPlayers);
        for(uint i = 0; i < maxPlayers; i++){
            players[i].x = randomNumberwithinMap(mapBoundary, players[i].playerAddress);
            players[i].y = randomNumberwithinMap(mapBoundary, players[i].playerAddress);
        }
        gameActive = true;
    }

    function move(uint _move, uint _currentX, uint _currentY, uint _currentFacing, uint _mapSize) public returns(
        uint, uint) {
        //_move index = 
        //0: move up
        //1: move down
        //2: move right
        //3: move left
        //4: turn right
        //5: turn left
        //first value returned is what's changed, second is new value
        //0: no change
        //1: x was changed
        //2: y was changed
        //3: facing was changed

        if (_move == 0) {
            if (_currentFacing == 2 && _currentY < _mapSize - 1) {
                return (2, _currentY + 1);
            } else {
                return;
            }
            if (_currentFacing == 1 && _currentX < _mapSize - 1) {
                return (1, _currentX + 1);
            } else {
                return;
            }
            if (_currentFacing == 0 && _currentY > 0) {
                return (2, _currentY - 1);
            } else {
                return;
            }
            if (_currentFacing == 3 && _currentX > 0) {
                return (1, _currentY - 1);
            } else {
                return;
            }

        }
    }

    function initiateBattle(address opponentAdd, bytes32 hashOfMove) public {
        Player storage initiator = players[playerIndex[msg.sender]];
        Player storage personToAttack = players[playerIndex[opponentAdd]];
        require(initiator.x == personToAttack.x && initiator.y == personToAttack.y);
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
    uint public initiatorFacing;
    address public defender;
    bytes32 public defenderHash;
    uint[] public defenderMoves;
    uint public defenderLocationX;
    uint public defenderLocationY;
    uint public defenderFacing;
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
        initiatorLocationY = randomLocation(_initiator);
        initiatorLocationX = randomLocation(_initiator);
        defenderLocationY = randomLocation(_defender);
        defenderLocationX = randomLocation(_defender);
        game = Game(_game);
    }

    function verifyMove(uint[] _moves, bytes32 hashToCompare) returns (bool){
        return keccak256(abi.encodePacked(_moves)) == hashToCompare;
    }

    function randomLocation(address playerAddress) returns (uint) {
        return game.randomNumberwithinMap(battleSize, playerAddress);
    }
}