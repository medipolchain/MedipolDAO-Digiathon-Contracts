// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IKYC.sol";

contract MyToken is ERC1155, Ownable, ERC1155Supply {
    IKYC public kyc;
    uint256 public constant DENOMINATOR = 10000;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    modifier onlyAllowed() {
        require(kyc.isAllowed(msg.sender), "Not allowed");
        _;
    }

    constructor(string memory _uri, address _kyc) ERC1155(_uri) {
        require(_kyc != address(0), "kyc address cannot be 0");
        kyc = IKYC(_kyc);
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    // mahalle parsel ada

    function mint(address account) external onlyAllowed {
        uint256 _id = _tokenIds.current();
        _tokenIds.increment();

        _mint(account, _id, DENOMINATOR, "");
    }

    function mintBatch(address to, uint256 amount) external onlyOwner {
        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        uint256 _id;
        for (uint256 i; i < amount; ) {
            _id = _tokenIds.current();
            _tokenIds.increment();
            ids[i] = _id;
            amounts[i] = DENOMINATOR;
            unchecked {
                i++;
            }
        }
        _mintBatch(to, ids, amounts, "");
    }

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
