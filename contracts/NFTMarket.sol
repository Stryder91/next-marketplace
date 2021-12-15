// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    // même si c'est des MATIC, ça reste ether
    uint private listingPrice = 0.025 ether;
    mapping(uint => MarketItem) private idToMarketItem;
    
    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }
    event MarketItemCreated(
        uint indexed itemId,
        address nftContract,
        uint indexed tokenId,
        address payable seller,
        address payable owner,
        uint indexed price,
        bool sold
    );

    function getListingPrice() public view returns(uint) {
        return listingPrice;
    }

    function createMarketItem(
        address _nftContract,
        uint _tokenId,
        uint _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be positive");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            _nftContract,
            _tokenId,
            payable(msg.sender),
            // on ne le vend à personne pour l'instant 
            // mais l'arg. doit respecter le type
            payable(address(0)),
            _price,
            false
        );

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        emit MarketItemCreated(itemId, _nftContract, _tokenId, payable(msg.sender), payable(address(0)), _price, false);
    }

    function createMarketSale(
        address _nftContract,
        uint _itemId
    ) public payable nonReentrant {
        uint price = idToMarketItem[_itemId].price;
        uint tokenId = idToMarketItem[_itemId].tokenId;

        require(msg.value == price, "Don't try to steal the banks");

        idToMarketItem[_itemId].seller.transfer(msg.value);
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[_itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = itemCount - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                // uint currentId = idToMarketItem[i + 1].itemId;
                // MarketItem storage currentItem = idToMarketItem[currentId];
                // items[currentIndex] = currentItem;
                items[currentIndex] = idToMarketItem[i + 1];
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNfts() public view returns(MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;


        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                // MarketItem storage currentItem = idToMarketItem[currentId]
                // items[currentIndex] = currentItem
                items[currentIndex] = idToMarketItem[currentId];
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyCreations() public view returns(MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;


        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                items[currentIndex] = idToMarketItem[currentId];
                currentIndex += 1;
            }
        }
        return items;
    }
}
