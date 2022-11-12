// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./interfaces/IKYC.sol";

contract MyToken is ERC1155, Ownable, ERC1155Supply {
    IKYC public kyc;
    uint256 public constant DENOMINATOR = 10000;

    modifier onlyAllowed() {
        require(kyc.isAllowed(msg.sender), "Not allowed");
        _;
    }

    constructor(string memory _uri, address _kyc) ERC1155(_uri) {
        require(_kyc != address(0), "kyc address cannot be 0");
        kyc = IKYC(_kyc);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // mahalle parsel ada

    function mint(address account, uint256 id) public onlyAllowed {
        _mint(account, id, DENOMINATOR, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
