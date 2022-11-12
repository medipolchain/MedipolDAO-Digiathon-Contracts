//write kyc contracts
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract KYC is Ownable {
    mapping(address => bool) public allowed;

    function allowAddress(address _addr) external onlyOwner {
        allowed[_addr] = true;
    }

    function revokeAddress(address _addr) external onlyOwner {
        allowed[_addr] = false;
    }
}
