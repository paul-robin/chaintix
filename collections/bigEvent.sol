// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract bigEvent is ERC721Enumerable, Ownable {
    using Strings for uint256;

    struct Tier {
        string tierName;
        uint256 price;
        uint256 maxPrice;
        uint16 totalSupply;
        uint16 maxSupply;
        uint16 startingIndex;
        uint8 mintsPerAddress;
    }

    mapping(uint256 => mapping(address => uint256)) addressCountsPerTier;
    mapping(uint256 => Tier) tiers;

    uint256 public eventAddress;
    uint256 public ownerAddress;
    string public baseURI;
    string public baseExtension = ".json";
    bool public paused = false;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI, uint256 memory inputEventAddress, uint256 memory inputOwnerAddress) ERC721(_name, _symbol){
        tiers[0] = Tier({tierName: "std", price: 1 ether, maxPrice: 2 ether, totalSupply: 3, maxSupply: 4, startingIndex: 5, mintsPerAddress: 6});
        tiers[1] = Tier({tierName: "vip", price: 7 ether, maxPrice: 8 ether, totalSupply: 9, maxSupply: 10, startingIndex: 11, mintsPerAddress: 12});

        setBaseURI(_initBaseURI);
        eventAddress = inputEventAddress;
        ownerAddress = inputOwnerAddress;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint tier, uint256 _mintAmount) public payable {
        require(!paused, "Sale is not active.");
        require(tiers[tier].totalSupply + 1 <= tiers[tier].maxSupply, "Exceeded max limit of allowed token mints.");
        require(tiers[tier].price * _mintAmount <= msg.value, "Not enough ETH to mint. Change tier or mint amount.");
        require(addressCountsPerTier[tier][msg.sender] + _mintAmount <= tiers[tier].mintsPerAddress, "Max number of mints per address reached.");

        addressCountsPerTier[tier][msg.sender] = addressCountsPerTier[tier][msg.sender] + _mintAmount;
        uint16 tierTotalSuppy = tiers[tier].totalSupply;
        tiers[tier].totalSupply = tierTotalSuppy + _mintAmount;
        
        _safeMint(msg.sender, tiers[tier].startingIndex + tierTotalSuppy);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function transferFrom(address from, address to, uint tokenId) public override payable {
        uint8 tokenTier;
        if (tokenId >= 11){tokenTier = 1;}
        else if (tokenId >= 5){tokenTier = 0;}

        require(from != address(0x0), 'Invalid "from" address.');
        require(to != address(0x0), 'Invalid "to" address.');
        require(tokenId > 0, 'Invalid tokenId.');
        require(_isApprovedOrOwner(_msgSender(), tokenId), 'msgSender is not the owner of the token.');
        require(msg.value <= tiers[tokenTier].maxPrice, 'Resell price is too high.')

        _transfer(from, to, tokenId);

        uint256 eventSplitAmount = (msg.value / 200) * 3;
        uint256 ownerSplitAmount = msg.value / 200;
        uint256 transferAmount = msg.value - eventSplitAmount - ownerSplitAmount;

        payable(eventAddress).transfer(eventSplitAmount);
        payable(ownerAddress).transfer(ownerSplitAmount);
        payable(from).transfer(transferAmount);
    }

    //only owner
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setEventAddress(uint256 newEventAddress) public onlyOwner {
        require(newEventAddress != address(0));
        eventAddress = newEventAddress;
    }

    function setOwnerAddress(uint256 newOwnerAddress) public onlyOwner {
        require(newOwnerAddress != address(0));
        ownerAddress = newOwnerAddress;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}