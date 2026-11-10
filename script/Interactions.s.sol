// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {PlanetNFT} from "../src/PlanetNFT.sol";

/**
 * @title MintPlanetNftInteraction
 * @author Abdelbasset10
 * @notice Mints a planet token on the most recently deployed PlanetNFT contract.
 * @dev Finds the contract with `DevOpsTools.get_most_recent_deployment`, which reads
 *      the `broadcast/` folder, so the deploy script must have been run with `--broadcast`
 *      on the same chain first.
 */
contract MintPlanetNftInteraction is Script {
    /// @notice The IPFS metadata URI used for the minted token.
    string public constant TOKEN_URI = "ipfs://bafkreifkhg5risa3xisuv75vyffpkxmwzcogbmp67cf5kdk5pmh4osj66i";

    /**
     * @notice Mints one token with `TOKEN_URI` on the given PlanetNFT contract.
     * @param nft The address of the PlanetNFT contract.
     */
    function mintNft(address nft) public {
        vm.startBroadcast();
        PlanetNFT(nft).mintNFT(TOKEN_URI);
        vm.stopBroadcast();
    }

    /// @notice Mints a token on the most recently deployed PlanetNFT on the current chain.
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("PlanetNFT", block.chainid);
        mintNft(mostRecentlyDeployed);
    }
}
