pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'IntermediaryRole' to manage this role - add, remove, check
contract IntermediaryRole{
    using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event IntermediaryAdded(address indexed account);
  event IntermediaryRemoved(address indexed account);

  // Define a struct 'intermediary' by inheriting from 'Roles' library, struct Role
  Roles.Role private intermediaries;

  // Define a modifier that checks to see if msg.sender has the appropriate role
  constructor() public {
    _addIntermediary(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyIntermediary() {
    require(isIntermediary(msg.sender), 'Account is not an Intermediary');
    _;
  }

  // Define a function 'isIntermediary' to check this role
  function isIntermediary(address account) public view returns (bool) {
    return intermediaries.has(account);
  }

// Define a function 'addIntermediary' that adds this role
  function addIntermediary(address account) public {
    _addIntermediary(account);
  }

  // Define a function 'renounceIntermediary' to renounce this role
  function renounceIntermediary() public {
    _removeIntermediary(msg.sender);
  }

  // Define an internal function '_addIntermediary' to add this role, called by 'addIntermediary'
  function _addIntermediary(address account) internal {
    intermediaries.add(account);
    emit IntermediaryAdded(account);
  }

  // Define an internal function '_removeIntermediary' to remove this role, called by 'removeIntermediary'
  function _removeIntermediary(address account) internal {
    intermediaries.remove(account);
    emit IntermediaryRemoved(account);
  }

}