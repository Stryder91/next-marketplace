// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address _marketplaceAddress) ERC721("Unik Bubble", "BBT") {
        contractAddress = _marketplaceAddress;
    }

    function createToken(string memory _tokenURI) public returns(uint) {
        _tokenIds.increment();
        uint _newItemId = _tokenIds.current();
        _mint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);
        setApprovalForAll(contractAddress, true);
        return _newItemId;
    }
}