//SPDX_License-Identifier:MIT

pragma solidity 0.8.20;

contract MultiSigWallet{
    error MultiSigWallet__IncreaseNoOfOwners();
    error MultiSigWallet__IncreaseNumberOfConfirmations();
    error  MultiSigWallet__AddressCantBeZero();
    error MultiSigWallet__OwnerMustBeUnique();
    error MultiSigWallet__OnlyOwnerCanPerformAction();
    error MultiSigWallet__TransactionDoesNotExist();
    error MultiSigWallet__TransactionExecutedAlready();
    error MultiSigWallet__NotEnoughConfirmations();
    error MultiSigWallet__TransactionAlreadyConfrimed();


    event DepositReceived(address indexed sender, uint amount, uint balance);
    event SubmittedTransaction(address indexed owner, uint indexed txIndex);
    event ConfirmedTransaction(address indexed owner, uint indexed txIndex);
    event ExecutedTransaction(address indexed owner, uint indexed txIndex);
    event RevokedConfirmation(address indexed owner, uint indexed txIndex);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint confirmations;
    }
    Transaction[] public transactions;
    

    address[] public owners;
    uint public numberOfConfirmationsRequired;

    mapping(address => bool) public isOwner;
    //we can also use loops and isOwner modifier, but this mapping is more efficient
mapping(uint => mapping(address => bool)) public isConfirmed;

    modifier OnlyOwner {
        if(!isOwner[msg.sender]){
            revert MultiSigWallet__OnlyOwnerCanPerformAction();
        }
        _;
    }
    modifier txExists(uint _txIndex){
        if(transactions.length < _txIndex)
        {
            revert MultiSigWallet__TransactionDoesNotExist();
        }
        _;
    }
    modifier notExecuted(uint _txIndex)
    {
        if(transactions[_txIndex].executed)
        {
            revert MultiSigWallet__TransactionExecutedAlready();
        }
        _;
    }
    modifier notConfirmed(uint _txIndex)
    {
        if(isConfirmed[_txIndex][msg.sender])
        {
            revert MultiSigWallet__TransactionAlreadyConfrimed();
        }
        _;

    }
    constructor (address[] memory _owners, uint _numberOfConfirmationsRequired){

    if( _owners.length < 0){
        revert MultiSigWallet__IncreaseNoOfOwners();
    }
    if(!(_numberOfConfirmationsRequired > 0 && _numberOfConfirmationsRequired < _owners.length)) 
    {
        revert MultiSigWallet__IncreaseNumberOfConfirmations();
    }
    for(uint i=0; i< _owners.length; i++)
    {
        address owner = _owners[i];

        if(owner == address(0))
        {
            revert MultiSigWallet__AddressCantBeZero();
        }

        if(isOwner[owner])
        {
            revert MultiSigWallet__OwnerMustBeUnique();
        }

        isOwner[owner] = true;
        owners.push(owner);
    }
    numberOfConfirmationsRequired = _numberOfConfirmationsRequired;
    }
    function submitTransaction(address _to, uint _value,bytes memory _data) public OnlyOwner {
uint txIndex = transactions.length;
emit SubmittedTransaction(msg.sender, txIndex);
 transactions.push(Transaction({to: _to,value: _value,data:_data,executed: false,confirmations:0}));
    }

    function confirmTransaction(uint _txIndex) public OnlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        
        transaction.confirmations +=1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmedTransaction(msg.sender, _txIndex);

    }

    function executeTransaction(uint _txIndex) public OnlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction  = transactions[_txIndex];
        if(transaction.confirmations <= numberOfConfirmationsRequired)
        {
            revert MultiSigWallet__NotEnoughConfirmations();
        }
        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require (success, "Transaction Failed");
        emit ExecutedTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex) public OnlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        transaction.confirmations -=1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokedConfirmation(msg.sender, _txIndex);
    }

    receive() external payable {
        emit DepositReceived(msg.sender, msg.value, address(this).balance);
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    function getOwners() public view returns (address[] memory){
        return owners;
    }
    function getTransactionCount() public view returns (uint){
        return transactions.length;
    }
    function getTransaction(uint _txIndex) public view returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations)
    {
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to, transaction.value, transaction.data, transaction.executed,transaction.confirmations);
    }
    
}