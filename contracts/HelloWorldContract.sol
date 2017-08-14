pragma solidity ^0.4.4;

contract HelloWorldContract {

address public owner;
string _word="HelloWorld";

event _updated(string _a);

function HelloWorldContract() {
    owner = msg.sender;
  }

modifier ifowner() {
  if (msg.sender!=owner) throw;
  _;
}

function getWord() constant ifowner returns(string){
    return _word;
  }

function setword(string _a) ifowner {
  _word = _a;
  _updated("Word has been updated by owner!");
}
}
