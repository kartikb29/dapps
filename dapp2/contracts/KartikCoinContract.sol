pragma solidity ^0.4.4;

contract KartikCoinContract {

  address owner;
  event _txstatus(string status);
  mapping (address => uint) public balances;

  function KartikCoinContract() {
    owner=msg.sender;
    balances[owner]+=21000000;
  }

  modifier ifOwner(){
    if (msg.sender!=owner) throw;
    _;
  }

  function getOwner() constant returns(address) {
    return owner;
  }

  function createCoins(uint _amt) ifOwner {
    balances[owner]+= _amt;
    _txstatus("Coins created!");
  }

  function getBalance(address _account) constant returns(uint) {
    return balances[_account];
  }

  function txCoins(address _to, uint _amt) {
    if ((balances[msg.sender] >= _amt)) {
      balances[msg.sender]-=_amt;
      balances[_to]+= _amt;
      _txstatus("Transfer successful");
    }
    _txstatus("Transaction unsuccessful");
  }

  function withdrawCoins(address _from, uint _amt) {
    if ((balances[_from] >= _amt) && (_from == msg.sender)) {
      balances[_from]-= _amt;
      _txstatus("Withdrawal completed");
    }
  }
}
