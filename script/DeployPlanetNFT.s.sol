// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {PlanetNFT} from "../src/PlanetNFT.sol";

/**
 * @title DeployNFT
 * @author Abdelbasset10
 * @notice Deploys the PlanetNFT contract.
 */
contract DeployNFT is Script {

    /**
     * @notice Deploys a new PlanetNFT contract.
     * @return The deployed PlanetNFT contract.
     */
    function run() external returns(PlanetNFT) {
        vm.startBroadcast();
        PlanetNFT nft = new PlanetNFT();
        vm.stopBroadcast();
        return nft;
    }

}