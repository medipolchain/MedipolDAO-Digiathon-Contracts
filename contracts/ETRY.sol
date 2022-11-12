// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IKYC.sol";

contract eTRY is ERC20, ERC20Burnable, Pausable, Ownable {
    IKYC public kyc;
    address public marketplace;

    constructor(address _marketplace, address _kyc) ERC20("E-TRY", "eTRY") {
        marketplace = _marketplace;
        kyc = IKYC(_kyc);
        _mint(msg.sender, 100000000000 * 10**decimals());
    }

    modifier onlyAllowed() {
        require(kyc.isAllowed(msg.sender), "Not allowed");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused onlyAllowed {
        super._beforeTokenTransfer(from, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        if (msg.sender != marketplace) _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
}
