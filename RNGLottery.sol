contract RNGLottery {
    uint constant public TICKET_PRICE = 1e16; //ether payment is 0.01 ether

    address[] public tickets;
    address public winner;
    bytes32 public seed;
    mapping(address => bytes32) public commitments;

    uint public ticketDeadline; // number of tickets to be buy
    uint public revealDeadline; // number of turns for each tickets

    function RNGLottery (uint duration, uint revealDuration) public {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
    }
    
    function createCommitment(address user, uint N) 
      public pure returns (bytes32 commitment) {
        return keccak256(user, N);
    //this is for the hashing of the address of the participant
    //and the guess number
    }

    function buy (bytes32 commitment) payable public {
        require(msg.value == TICKET_PRICE); 
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
        //buying the ticket of the hash address and the
        //guess number
    }

    function reveal (uint N) public {
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);

        seed = keccak256(seed, N);
        tickets.push(msg.sender);
        //the buy ticket should be reveal to push in the tickets array
    }

    function drawWinner () public {
        require(block.number > revealDeadline);
        require(winner == address(0));

        uint randIndex = uint(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    function withdraw () public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }
}
