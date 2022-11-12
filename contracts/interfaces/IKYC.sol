//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IKYC {
    function isAllowed(address _addr) external view returns (bool);
}
