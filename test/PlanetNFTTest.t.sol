// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {PlanetNFT} from "../src/PlanetNFT.sol";
import {DeployNFT} from "../script/DeployPlanetNFT.s.sol";
import {
    IERC721Errors
} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract PlanetNFTTest is Test {
    DeployNFT deployer;
    PlanetNFT nft;
    string public constant TOKEN_URI1 =
        "ipfs://bafkreifkhg5risa3xisuv75vyffpkxmwzcogbmp67cf5kdk5pmh4osj66i";
    string public constant TOKEN_URI2 =
        "ipfs://bafkreiho7iklkpozsqavqfjywklghhl3wj6tgfjuf7tvgsnkztbwwwfdhi";

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() external {
        deployer = new DeployNFT();
        nft = deployer.run();
    }

    function testTokenSymbolAndNameAreCorrect() public view {
        assert(
            keccak256(abi.encode(nft.TOKEN_SYMBOL())) ==
                keccak256(abi.encode(nft.symbol()))
        );
        assert(
            keccak256(abi.encode(nft.TOKEN_Name())) ==
                keccak256(abi.encode(nft.name()))
        );
    }

    function testMint() public {
        uint256 balanceOfUserBefore = nft.balanceOf(user1);
        vm.prank(user1);
        nft.mintNFT(TOKEN_URI1);
        uint256 balanceOfUserAfter = nft.balanceOf(user1);
        assertEq(balanceOfUserAfter, balanceOfUserBefore + 1);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.tokenURI(0), TOKEN_URI1);
    }

    function testTwoUsersMint() public {
        vm.prank(user1);
        nft.mintNFT(TOKEN_URI1);
        vm.prank(user2);
        nft.mintNFT(TOKEN_URI2);
        assertEq(nft.tokenURI(0), TOKEN_URI1);
        assertEq(nft.tokenURI(1), TOKEN_URI2);
    }

    function testCounterIncreasesAfterMint() public {
        uint256 counterBefore = nft.getTokenCounter();
        vm.prank(user1);
        nft.mintNFT(TOKEN_URI1);
        uint256 counterAfter = nft.getTokenCounter();
        assertEq(counterAfter, counterBefore + 1);
    }

    function testTokenUriRevertsIfNoExists() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                0
            )
        );
        nft.tokenURI(0);
    }

    function testRevertWithContractDoesntImplementonERC721Received() public {
        InvalidReceiverContract inv = new InvalidReceiverContract(nft);
        vm.expectRevert( abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidReceiver.selector,
                address(inv)
        ));
        inv.callNft();
    }

    function testContractImplementingReceiverGetsNft() public {
        ValidReceiverContract receiver = new ValidReceiverContract(nft);
        receiver.callNft();
        assertEq(nft.ownerOf(0), address(receiver));
        assertEq(nft.balanceOf(address(receiver)), 1);
        assertEq(nft.tokenURI(0), receiver.TOKEN_URI());
    }
}

contract InvalidReceiverContract {
    PlanetNFT nft;
    string public constant TOKEN_URI ="ipfs://bafkreifkhg5risa3xisuv75vyffpkxmwzcogbmp67cf5kdk5pmh4osj66i";

    constructor(PlanetNFT _nft){
        nft = _nft;
    }

   function callNft() public {
     nft.mintNFT(TOKEN_URI);
   }
}
contract ValidReceiverContract is IERC721Receiver {
    PlanetNFT nft;
    string public constant TOKEN_URI ="ipfs://bafkreiho7iklkpozsqavqfjywklghhl3wj6tgfjuf7tvgsnkztbwwwfdhi";

    constructor(PlanetNFT _nft){
        nft = _nft;
    }

   function callNft() public {
     nft.mintNFT(TOKEN_URI);
   }

   function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
     return IERC721Receiver.onERC721Received.selector;
   }
}
