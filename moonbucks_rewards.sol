// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MoonBucksRewards is ERC721, ERC721Enumerable, Ownable {

    uint256 public constant MAX_SUPPLY = 1000;
    mapping (address => uint256) public nonces;
    using Counters for Counters.Counter;
    IERC20 public tokenAddress;
    string public baseURI = "ipfs://bafybeieknfbhuuhbkisrdw7dm7bnl35ffio2nrspdo5hxxt37xudiarv74/";

    Counters.Counter private _tokenIdCounter;

    constructor(address _tokenAddress) ERC721("MoonBucksRewards", "MBR") {
        tokenAddress = IERC20(_tokenAddress);
    }

    function safeMint() public {
        require(tokenAddress.balanceOf(msg.sender) > 99*10**18, "Not enough MoonBucks earned!");
        require(nonces[msg.sender] == 0, "Reward Already Claimed!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        nonces[msg.sender] += 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function changeBaseURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

        function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}