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
    mapping(uint256 => Property) public properties;

    struct Property {
        uint256 neighborhoodId;
        uint256 parcelId;
        uint256 blockId;
        uint256 floorId;
        uint256 apartmentId;
    }

    modifier onlyAllowed() {
        // require(kyc.isAllowed(msg.sender), "Not allowed");
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

    function mockMint() external {
        uint256 _id = _tokenIds.current();
        _tokenIds.increment();
        _mint(msg.sender, _id, DENOMINATOR, "");
    }

    function mint(
        uint256 neighborhoodId, // mahalle
        uint256 parcelId, // parsel
        uint256 blockId, // ada
        uint256 floorNo, // kat
        uint256 apartmentNo, // daire
        uint256 share,
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
                    floorNo,
                    apartmentNo,
                    share,
                    nonce
                ),
                signature,
                owner()
            ),
            "Invalid signature"
        );
        require(share <= DENOMINATOR, "Amount cannot be more than 100%");

        require(!nonceUsed[nonce], "Nonce already used");
        nonceUsed[nonce] = true;

        uint256 _id = _tokenIds.current();
        _tokenIds.increment();

        _mint(msg.sender, _id, share, "");

        properties[_id] = Property(
            neighborhoodId,
            parcelId,
            blockId,
            floorNo,
            apartmentNo
        );
    }

    function mintBatch(
        uint256[] memory neighborhoodIds, // mahalle
        uint256[] memory parcelIds, // parsel
        uint256[] memory blockIds, // ada
        uint256[] memory floorNo, // kat
        uint256[] memory apartmentNo, // daire
        uint256[] memory shares,
        uint256[] memory nonces,
        bytes[] memory signatures
    ) external onlyAllowed {
        uint256 len = neighborhoodIds.length;
        require(parcelIds.length == len, "parcelIds length must be equal");
        require(blockIds.length == len, "blockIds length must be equal");
        require(nonces.length == len, "nonces length must be equal");
        require(signatures.length == len, "signatures length must be equal");

        uint256[] memory ids = new uint256[](len);
        uint256 _id;
        for (uint256 i; i < len; ) {
            require(
                verify(
                    abi.encodePacked(
                        msg.sender,
                        neighborhoodIds[i],
                        parcelIds[i],
                        blockIds[i],
                        floorNo[i],
                        apartmentNo[i],
                        shares[i],
                        nonces[i]
                    ),
                    signatures[i],
                    owner()
                ),
                "Invalid signature"
            );
            require(nonceUsed[nonces[i]] == false, "Nonce already used");
            nonceUsed[nonces[i]] = true;

            _id = _tokenIds.current();
            _tokenIds.increment();
            ids[i] = _id;
            properties[_id] = Property(
                neighborhoodIds[i],
                parcelIds[i],
                blockIds[i],
                floorNo[i],
                apartmentNo[i]
            );

            unchecked {
                i++;
            }
        }
        _mintBatch(msg.sender, ids, shares, "");
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

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override onlyMarketplace {
        super._safeTransferFrom(from, to, id, amount, data);
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
