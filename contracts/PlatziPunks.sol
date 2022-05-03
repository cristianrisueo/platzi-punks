// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
import "./PlatziPunksDNA.sol";

contract PlatziPunks is ERC721, ERC721Enumerable, PlatziPunksDNA {
    // Adds the library Counters to the contract
    using Counters for Counters.Counter;

    // Creates the var counter and maxSupply
    Counters.Counter private _idCounter;
    uint256 public maxSupply;

    // Token DNA
    mapping (uint256 => uint256) public tokenDNA;

    // The constructor gets the max supply of the tokens
    constructor(uint256 _maxSupply) ERC721("PlatziPunks", "PLPKS") {
        maxSupply = _maxSupply;
    }

    function mint() public {
        // Creates a new token (a var autoincrement)
        uint256 current = _idCounter.current();

        // Requires that the var. is less than the supply
        require(current < maxSupply, "No PlatziPunks left :(");
        
        // Assignates the token tokenDNA
        tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);

        // To and Token are the params of _safeMint
        _safeMint(msg.sender, current);
    }

    function _baseURI() internal view override returns(string memory) {
        return "https://avataaars.io/";
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
        string memory params;

        {
            params = string(
                abi.encodePacked(
                    "accessoriesType=",
                    getAccessoriesType(_dna),
                    "&clotheColor=",
                    getClotheColor(_dna),
                    "&clotheType=",
                    getClotheType(_dna),
                    "&eyeType=",
                    getEyeType(_dna),
                    "&eyebrowType=",
                    getEyeBrowType(_dna),
                    "&facialHairColor=",
                    getFacialHairColor(_dna),
                    "&facialHairType=",
                    getFacialHairType(_dna),
                    "&hairColor=",
                    getHairColor(_dna),
                    "&hatColor=",
                    getHatColor(_dna),
                    "&graphicType=",
                    getGraphicType(_dna),
                    "&mouthType=",
                    getMouthType(_dna),
                    "&skinColor=",
                    getSkinColor(_dna)
                )
            );
        }

        return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
    }

    function imageByDNA(uint256 _dna) public view returns (string memory) {
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI(_dna);

        return string(abi.encodePacked(baseURI, "?", paramsURI));
    }

    function tokenUri(uint256 tokenId) public view override returns(string memory) {
        // Requires that the token exists
        require(_exists(tokenId), "ERC721 Metadata: URI for non existing token");
        
        // Creates the json
        string memory jsonURI = Base64.encode(
            abi.encodePacked(
                '{ "name": "PlatziPunks #', tokenId,'", 
                "description": "Platzi Punks are randomized Avataaars stored on chain to teach DApp development on Platzi", 
                "image": "', image,
                '"}'
            )
        );

        // Concatenates the json with its header (www standard) and returns it as str.
        return string(abi.encodePacked("data:application/json;base64,", jsonURI));
    }

    // Override required
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Returns true for a ERC21 Enumerable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}