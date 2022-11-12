// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IKYC.sol";

contract fdNFT is ERC1155, Ownable, ERC1155Supply {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    IKYC public kyc;
    address public marketplace;
    uint256 public constant DENOMINATOR = 10000;

    mapping(uint256 => bool) public nonceUsed;

    modifier onlyAllowed() {
        require(kyc.isAllowed(msg.sender), "Not allowed");
        _;
    }

    modifier onlyMarketplace() {
        require(msg.sender == marketplace, "Not allowed");
        _;
    }

    constructor(
        string memory _uri,
        address _kyc,
        address _marketplace
    ) ERC1155(_uri) {
        require(_kyc != address(0), "kyc address cannot be 0");
        require(_marketplace != address(0), "marketplace address cannot be 0");
        kyc = IKYC(_kyc);
        marketplace = _marketplace;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    function mint(
        uint256 neighborhoodId, // mahalle
        uint256 parcelId, // parsel
        uint256 blockId, // ada
        uint256 nonce,
        bytes memory signature
    ) external onlyAllowed {
        require(
            verify(
                abi.encodePacked(
                    msg.sender, // to get user based unique signatures
                    neighborhoodId,
                    parcelId,
                    blockId,
                    nonce
                ),
                signature,
                owner()
            ),
            "Invalid signature"
        );
        nonceUsed[nonce] = true;

        uint256 _id = _tokenIds.current();
        _tokenIds.increment();

        _mint(msg.sender, _id, DENOMINATOR, "");
    }

    function mintBatch(
        uint256[] calldata neighborhoodIds, // mahalle
        uint256[] calldata parcelIds, // parsel
        uint256[] calldata blockIds, // ada
        uint256[] calldata nonces,
        bytes[] memory signatures
    ) external onlyAllowed {
        uint256 amount = neighborhoodIds.length;
        require(amount == parcelIds.length, "parcelIds length must be equal");
        require(amount == blockIds.length, "blockIds length must be equal");
        require(amount == nonces.length, "nonces length must be equal");
        require(amount == signatures.length, "signatures length must be equal");

        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        uint256 _id;
        for (uint256 i; i < amount; ) {
            require(
                verify(
                    abi.encodePacked(
                        msg.sender,
                        neighborhoodIds[i],
                        parcelIds[i],
                        blockIds[i],
                        nonces[i]
                    ),
                    signatures[i],
                    owner()
                ),
                "Invalid signature"
            );
            nonceUsed[nonces[i]] = true;

            _id = _tokenIds.current();
            _tokenIds.increment();
            ids[i] = _id;
            amounts[i] = DENOMINATOR;
            unchecked {
                i++;
            }
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function emergencyTransfer(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(
            ids.length == amounts.length,
            "ids and amounts length must be equal"
        );
        safeBatchTransferFrom(from, to, ids, amounts, "");
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override onlyMarketplace {
        super._safeTransferFrom(from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override onlyMarketplace {
        super._safeBatchTransferFrom(from, to, ids, amounts, data);
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

    function verify(
        bytes memory messageHash,
        bytes memory signature,
        address signer
    ) public pure returns (bool) {
        return
            keccak256(messageHash).toEthSignedMessageHash().recover(
                signature
            ) == signer;
    }
}
