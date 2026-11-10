// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title PlanetNFT
 * @author Abdelbasset10
 * @notice An ERC721 collection of planets whose metadata is stored on IPFS.
 * @dev Anyone can mint. Each token stores its own token URI, which should point
 *      to a JSON metadata file (e.g. `ipfs://<cid>`) that references the planet image.
 */
contract PlanetNFT is ERC721 {


    /**
     * @notice Emitted when a new planet token is minted.
     * @param to The address that received the token.
     * @param tokenId The id of the minted token.
     * @param tokenUri The metadata URI stored for the token.
     */
    event newTokenMinted(address to, uint256 tokenId, string tokenUri);

    /// @notice The name of the collection.
    string public constant TOKEN_Name = "Planets";
    /// @notice The symbol of the collection.
    string public constant TOKEN_SYMBOL = "PLNT";

    /// @dev The id of the next token to mint, which also equals the total number minted.
    uint256 private s_tokenCount;
    /// @dev Metadata URI of each minted token.
    mapping(uint256 tokenId => string tokenURI) private s_tokenToURI;
    /// @dev The last address that minted a token with a given URI.
    mapping(string tokenURI => address user) private s_tokenURItoUser;

    /// @notice Deploys the collection with the name "Planets" and the symbol "PLNT".
    constructor() ERC721(TOKEN_Name, TOKEN_SYMBOL) {
        s_tokenCount = 0;
    }

    /**
     * @notice Mints the next planet token to the caller.
     * @dev Uses `_safeMint`, so a contract caller must implement
     *      `IERC721Receiver.onERC721Received` or the call reverts with `ERC721InvalidReceiver`.
     * @param tokenuri The metadata URI for the new token (e.g. `ipfs://<cid>`).
     */
    function mintNFT(string memory tokenuri) public {
        s_tokenToURI[s_tokenCount] = tokenuri;
        s_tokenURItoUser[tokenuri] = msg.sender;
        _safeMint(msg.sender, s_tokenCount);
        emit newTokenMinted(msg.sender, s_tokenCount, tokenuri);
        s_tokenCount++;
    }

    /**
     * @notice Returns the metadata URI of a token.
     * @dev Reverts with `ERC721NonexistentToken` if the token has not been minted.
     * @param tokenId The id of the token.
     * @return The metadata URI stored for `tokenId`.
     */
    function tokenURI(uint256 tokenId) public override view returns(string memory)  {
        _requireOwned(tokenId);
        return s_tokenToURI[tokenId];
    }

    /**
     * @notice Returns how many tokens have been minted.
     * @return The token counter, which is also the id of the next token to mint.
     */
    function getTokenCounter() view public returns(uint256) {
        return s_tokenCount;
    }

    
}
