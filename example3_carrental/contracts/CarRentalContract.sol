pragma solidity ^0.4.13;
//Import the string utils library
import "./stringUtils.sol";

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
    bool Approve;
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
  event RentalProposed(address user, string regno, uint deposit);

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
//Function to get back a cars model, regno and
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
      }
    }
  }

//Function to propose a rental
  function ProposeRental(address to_user, string car_regno, uint deposit_amt)
  IfCreator
  {
    _proposal[to_user].CarRegNo=car_regno;
    _proposal[to_user].Deposit=deposit_amt;
    _proposal[to_user].Approve=false;
    RentalProposed(to_user, car_regno, deposit_amt);
  }
//Function to get rental proposal for a user
  function GetProposal(address user_ad) constant returns
  (
    string,
    uint,
    bool
  )
  {
    require((msg.sender==user_ad) || (msg.sender==Creator));
    return
    (
      _proposal[user_ad].CarRegNo,
      _proposal[user_ad].Deposit,
      _proposal[user_ad].Approve
    );
  }
//Function to approve a proposal

}
