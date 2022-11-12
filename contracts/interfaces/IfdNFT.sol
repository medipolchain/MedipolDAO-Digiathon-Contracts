//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IfdNFT {
    function mint(
        uint256 neighborhoodId,
        uint256 parcelId,
        uint256 blockId,
        uint256 nonce,
        bytes memory signature
    ) external;

    function mintBatch(
        uint256[] calldata neighborhoodIds,
        uint256[] calldata parcelIds,
        uint256[] calldata blockIds,
        uint256[] calldata nonces,
        bytes[] memory signatures
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}
