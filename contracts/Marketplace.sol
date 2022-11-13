// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IfdNFT.sol";

contract Marketplace is Ownable {
    using ECDSA for bytes32;
    IfdNFT public fdNFT;
    IERC20 public eTRY;

    address public govermentWallet;
    uint256 public governanceFee;

    address public municipalityWallet;
    uint256 public municipalityFee;

    uint256 public constant DENOMINATOR = 10000;

    mapping(address => mapping(uint256 => bool)) public userNonces;

    constructor(
        address _eTRY,
        address _govermentWallet,
        address _municipalityWallet,
        uint256 _governanceFee,
        uint256 _municipalityFee
    ) {
        require(_eTRY != address(0), "etry address cannot be zero");
        require(
            _govermentWallet != address(0),
            "goverment wallet address cannot be zero"
        );
        require(
            _municipalityWallet != address(0),
            "municipality wallet address cannot be zero"
        );

        eTRY = IERC20(_eTRY);
        govermentWallet = _govermentWallet;
        municipalityWallet = _municipalityWallet;

        governanceFee = _governanceFee;
        municipalityFee = _municipalityFee;
    }

    function setFdNFT(address _fdNFT) external onlyOwner {
        require(_fdNFT != address(0), "fdNFT address cannot be zero");
        fdNFT = IfdNFT(_fdNFT);
    }

    function setETRY(address _etry) external onlyOwner {
        require(_etry != address(0), "etry address cannot be zero");
        eTRY = IERC20(_etry);
    }

    function mockBuy(
        address payable _seller,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price
    ) external {
        // require(
        //     eTRY.transferFrom(msg.sender, _seller, _price),
        //     "transferFrom failed"
        // );

        fdNFT.safeTransferFrom(_seller, msg.sender, _tokenId, _amount, "");

        // distributeTax(_price);
    }

    function distributeTax(uint256 price) internal returns (uint256) {
        uint256 governmentAmount = (price * governanceFee) / DENOMINATOR;
        uint256 municipalityAmount = (price * municipalityFee) / DENOMINATOR;

        payable(govermentWallet).transfer(governmentAmount);
        payable(municipalityWallet).transfer(municipalityAmount);

        return price - (governmentAmount + municipalityAmount);
    }

    function mockBuy(
        address payable _seller,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price,
        uint256 _nonce,
        bytes memory _signature
    ) external {
        uint256 earning = distributeTax(_price);
        require(
            eTRY.transferFrom(msg.sender, _seller, earning),
            "transferFrom failed"
        );

        fdNFT.safeTransferFrom(_seller, msg.sender, _tokenId, _amount, "");
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
