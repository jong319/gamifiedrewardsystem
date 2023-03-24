// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.8.1/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.1/utils/cryptography/draft-EIP712.sol";

contract MoonBucks is ERC20, Ownable, EIP712 {
    mapping(bytes => uint256) public nonces;
    string private constant SIGNING_DOMAIN = "Moon Bucks Receipt";
    string private constant SIGNATURE_VERSION = "1";

    constructor()
        ERC20("Moon Bucks", "MB")
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {}

    function getSigner(
        uint256 reward,
        uint256 time,
        bytes memory _signature
    ) public view returns (address) {
        // EIP721 domain type
        string
            memory prompt = "Sign this receipt to verify your purchases and receive member rewards!";
        string memory name = "Moon Bucks Receipt";
        string memory version = "1";
        uint256 chainId = 97;
        address verifyingContract = address(this); // address(this);

        // stringified types
        string
            memory EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
        string
            memory MESSAGE_TYPE = "Message(string prompt,uint256 reward,uint time)";

        // hash to prevent signature collision
        bytes32 DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE)),
                keccak256(abi.encodePacked(name)),
                keccak256(abi.encodePacked(version)),
                chainId,
                verifyingContract
            )
        );

        bytes32 MESSAGE_VAR = keccak256(
            abi.encode(
                keccak256(abi.encodePacked(MESSAGE_TYPE)),
                keccak256(abi.encodePacked(prompt)),
                reward,
                time
            )
        );

        // hash typed data
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01", // backslash is needed to escape the character
                DOMAIN_SEPARATOR,
                MESSAGE_VAR
            )
        );

        // split signature
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_signature.length != 65) {
            return address(0);
        }
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            // verify
            address signer = ecrecover(hash, v, r, s);
            return signer;
        }
    }

    function mint(
        uint256 reward,
        uint256 time,
        bytes memory _signature
    ) public {
        require(nonces[_signature] == 0, "Reward Already Claimed!");
        require(
            msg.sender == getSigner(reward, time, _signature),
            "Require Signature Verification."
        );
        nonces[_signature] += 1;
        _mint(msg.sender, reward * 10**18);
    }
}
