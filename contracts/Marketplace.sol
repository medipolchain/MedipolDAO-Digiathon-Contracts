// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/IfdNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Marketplace is Ownable {
    using ECDSA for bytes32;
    IfdNFT public fdNFT;
    IERC20 public eTRY;

    mapping(address => mapping(uint256 => bool)) public userNonces;

    constructor(address _eTRY) {
        require(_eTRY != address(0), "etry address cannot be zero");
        eTRY = IERC20(_eTRY);
    }

    function setFdNFT(address _fdNFT) external onlyOwner {
        require(_fdNFT != address(0), "fdNFT address cannot be zero");
        fdNFT = IfdNFT(_fdNFT);
    }

    function setETRY(address _etry) external onlyOwner {
        require(_etry != address(0), "etry address cannot be zero");
        eTRY = IERC20(_etry);
    }

    // Add min price
    function buy(
        address payable _seller,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price,
        uint256 _nonce,
        bytes memory _signature
    ) external {
        require(_seller != address(0), "seller address cannot be zero");
        require(_amount > 0, "amount cannot be zero");
        require(_price > 0, "price cannot be zero");
        require(_nonce > 0, "nonce cannot be zero");

        require(
            verify(
                abi.encodePacked(_seller, _tokenId, _amount, _price, _nonce),
                _signature,
                _seller
            ),
            "invalid signature"
        );
        require(
            userNonces[_seller][_nonce] == false,
            "nonce already used for this token"
        );

        userNonces[_seller][_nonce] = true;

        require(
            eTRY.transferFrom(msg.sender, _seller, _price),
            "transferFrom failed"
        );

        fdNFT.safeTransferFrom(_seller, msg.sender, _tokenId, _amount, "");
        userNonces[_seller][_nonce] = true;
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
