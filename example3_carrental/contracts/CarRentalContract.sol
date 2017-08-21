pragma solidity ^0.4.13;
//Import the string utils library
import "./StringUtils.sol";

contract CarRentalContract {

//Public address variable of creator
  address Creator;
//New complex type car describing a car
  struct Car {
    int ID;
    string Make;
    string Model;
    string RegNo;
    string Color;
    int MileCount;
    address CurrentOwner;
    bool Available;
  }
//New complex type for a rent proposal
  struct Proposal{
    string CarRegNo;
    uint Deposit;
    uint Rent;
    bool Approve;
    bool Check;
  }
//New complex type user
  struct User{
    string Name;
    string ID_Number;
    string Contact;
  }
//Map every possible address to a user struct
  mapping(address => User) Users;
//Map every address to a balance
  mapping(address => uint) Balances;
//Map every user to a proposal
  mapping(address => Proposal) _proposal;
//Mapping a deposit account for each address
  mapping(address => uint) Deposits;
//Dynamically sized array of Cars
  Car[] cars;
//Event to add a car
  event CarAdded(string regno);
//Event to add a user
  event UserAdded(address user);
// Event for creation of coins
  event CoinsCreated(uint amt);
//Event to transfer Coins
  event CoinsTransferred(address from, address to, uint amt);
//Event to edit a car
  event CarDeleted(string regno);
//Event to propse a renatl
  event RentalProposed(address user_ad, string regno, uint deposit);
//Event to approve a proposal
  event ProposalApproved(address user_ad,string regno, uint deposit);
//Event to return car
  event CarReturned(address user_ad, string regno, uint balance);
//Constructor to save the creator at the start of the contarct
  function CarRentalContract() {
    Creator=msg.sender;
  }
//Modifier to check for creator
  modifier IfCreator(){
    if (msg.sender!=Creator) revert();
    _;
  }
//Payable function to store ether
  function Fallback() payable {}
//Create cryptocurrency
  function MintCoins(uint amt) IfCreator {
    Balances[Creator]+=amt;
    CoinsCreated(amt);
  }
//Transfer coins
  function TransferCoins(address from, address to, uint amt){
    require(msg.sender==from);
    Balances[from]-=amt;
    Balances[to]+=amt;
    CoinsTransferred(from,to,amt);
  }
//Function to get balance
  function GetBalance(address user_ad) constant returns(uint){
    require(msg.sender==user_ad);
    return (Balances[user_ad]);
  }
//Function to get deposit of a user
  function GetDeposit(address user_ad) constant returns(uint){
    require(msg.sender==user_ad);
    return (Deposits[user_ad]);
  }
//Function to add a car to the catalogue
  function AddCar(
    int id,
    string make,
    string model,
    string regno,
    string color,
    int milecount
  )
    IfCreator
  {
    if (cars.length != 0) {
      for (uint256 i=0;i<cars.length;i++){
        if (StringUtils.equal(cars[i].RegNo,regno)) {
          revert();
        }
      }
    }
    Car memory vehicle;
    vehicle.ID=id;
    vehicle.Make=make;
    vehicle.Model=model;
    vehicle.RegNo=regno;
    vehicle.Color=color;
    vehicle.MileCount=milecount;
    vehicle.CurrentOwner=Creator;
    vehicle.Available=true;
    cars.push(vehicle);
    CarAdded(regno);
  }
//Function to add a user
  function AddUser(
    address ad,
    string name,
    string id_number,
    string contact
  )
    IfCreator
  {
    Users[ad].Name=name;
    Users[ad].ID_Number=id_number;
    Users[ad].Contact=contact;
    UserAdded(ad);
  }
//Function to get back a car using regno
  function GetCar(string regno)
    IfCreator
    constant
    returns
  (
    string,
    string,
    string,
    string,
    int,
    address,
    bool
  )
  {
    require(cars.length!=0);
    for (uint256 i=0; i<cars.length; i++)
    {
      if (StringUtils.equal(cars[i].RegNo,regno)){
        return
      (
        cars[i].Make,
        cars[i].Model,
        cars[i].RegNo,
        cars[i].Color,
        cars[i].MileCount,
        cars[i].CurrentOwner,
        cars[i].Available
      );
      }
      revert();
    }
  }
//Function to get a user, owner can check all users
//A user can check only his own details
  function GetUser(address ad) constant returns
  (
    string,
    string,
    string
  )
  {
    require((msg.sender==ad) || (msg.sender==Creator));
    return (Users[ad].Name, Users[ad].ID_Number, Users[ad].Contact);
  }
//Delete a car by its registration number
  function DeleteCar(string regno) IfCreator {
    for (uint256 i=0; i<cars.length; i++)
    {
      if (StringUtils.equal(cars[i].RegNo,regno)){
        delete cars[i];
        cars[i]=cars[cars.length - 1];
        cars.length -= 1;
        CarDeleted(regno);
        return;
      }
    }
    revert();
  }

//Function to propose a rental
  function ProposeRental
  (
    address to_user,
    string car_regno,
    uint deposit_amt,
    uint rent_amt
  )
  IfCreator
  {
    require(cars.length!=0);
    for (uint256 i=0; i<cars.length; i++)
    {
      if (StringUtils.equal(cars[i].RegNo,car_regno) && cars[i].Available==true){
        _proposal[to_user].CarRegNo=car_regno;
        _proposal[to_user].Deposit=deposit_amt;
        _proposal[to_user].Rent=rent_amt;
        _proposal[to_user].Approve=false;
        _proposal[to_user].Check=true;
        RentalProposed(to_user, car_regno, deposit_amt);
        return;
      }
    }
    revert();
  }
//Function to get rental proposal for a user
  function GetProposal(address user_ad) constant returns
  (
    string,
    uint,
    uint,
    bool
  )
  {
    require((msg.sender==user_ad) || (msg.sender==Creator));
    return
    (
      _proposal[user_ad].CarRegNo,
      _proposal[user_ad].Deposit,
      _proposal[user_ad].Rent,
      _proposal[user_ad].Approve
    );
  }
//Function to approve a proposal
  function ApproveProposal(address user_ad) {
    require(user_ad==msg.sender);
    require(Balances[user_ad] >=_proposal[user_ad].Deposit);
    require(_proposal[user_ad].Check==true);
    _proposal[user_ad].Approve = true;
    Balances[user_ad]-=_proposal[user_ad].Deposit;
    Deposits[user_ad]+=_proposal[user_ad].Deposit;
    ChangeOwnership(user_ad, _proposal[user_ad].CarRegNo);
    ProposalApproved(
        user_ad,
        _proposal[user_ad].CarRegNo,
        _proposal[user_ad].Deposit
    );
  }
//Function (internal) to change ownership of car
  function ChangeOwnership(address user_ad, string car_regno) internal {
    require(cars.length!=0);
    for (uint256 i=0; i<cars.length; i++)
    {
      if (StringUtils.equal(cars[i].RegNo,car_regno) && cars[i].Available==true){
        cars[i].CurrentOwner = user_ad;
        return;
      }
    }
  }
//Function to return a car
  function ReturnCar(address user_ad, string regno){
    require(msg.sender == user_ad);
    require(_proposal[user_ad].Check==true);
    uint amt = Deposits[user_ad];
    Deposits[user_ad]-=amt;
    Balances[user_ad]+=(amt-_proposal[user_ad].Rent);
    _proposal[user_ad].Check=false;
    CarReturned(user_ad, regno, Balances[user_ad]);
  }

}
