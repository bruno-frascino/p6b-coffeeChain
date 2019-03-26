pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'RoasterRole' to manage this role - add, remove, check
contract RoasterRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event RoasterAdded(address indexed account);
  event RoasterRemoved(address indexed account);

  // Define a struct 'Roasters' by inheriting from 'Roles' library, struct Role
  Roles.Role private roasters;

  // In the constructor make the address that deploys this contract the 1st Roaster
  constructor() public {
    _addRoaster(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyRoaster() {
    require(isRoaster(msg.sender));
    _;
  }

  // Define a function 'isRoaster' to check this role
  function isRoaster(address account) public view returns (bool) {
    return roasters.has(account);
  }

  // Define a function 'addRoaster' that adds this role
  function addRoaster(address account) public onlyRoaster {
    _addRoaster(account);
  }

  // Define a function 'renounceRoaster' to renounce this role
  function renounceRoaster() public {
    _removeRoaster(msg.sender);
  }

  // Define an internal function '_addRoaster' to add this role, called by 'addRoaster'
  function _addRoaster(address account) internal {
    roasters.add(account);
    emit RoasterAdded(account);
  }

  // Define an internal function '_removeRoaster' to remove this role, called by 'removeRoaster'
  function _removeRoaster(address account) internal {
    roasters.remove(account);
    emit RoasterRemoved(account);
  }
}