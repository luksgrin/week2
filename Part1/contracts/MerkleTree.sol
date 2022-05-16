//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint256[8] memory container;

        for (uint i = 3; i > 0; i--) {

            for (uint j = 0; j < 2**i; j++) {

                // Add zero leaves when on 3rd level
                if (i == 3) {
                    hashes.push(0);
                    container[j] = hashes[hashes.length - 1];
                // Start computing pair hashes
                } else {
                    container[j] = PoseidonT3.poseidon([
                        container[2*j],
                        container[(2*j) + 1]
                    ]);
                    // Append to hashes array
                    hashes.push(container[j]);
                }
            }
        }

        // Compute merkle root form the last 2 hashes
        root = PoseidonT3.poseidon([
            hashes[hashes.length - 2],
            hashes[hashes.length - 1]
        ]);

    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree

        require(index < 8, "Merkle Tree has no empty spots left");

        uint256 _hshidx = index;

        hashes[_hshidx] = hashedLeaf;

        for (uint i = 2; i > 0 ; i--) {

            if ((_hshidx%2) == 0) {
                hashes[_hshidx/2 + (2**3)] = PoseidonT3.poseidon([
                    hashes[_hshidx],
                    hashes[_hshidx + 1]
                    ]);
            } else {
                hashes[_hshidx/2 + (2**3)] = PoseidonT3.poseidon([
                    hashes[_hshidx - 1],
                    hashes[_hshidx]
                    ]);
            }

            _hshidx = _hshidx/2 + (2**3);
        }

        root = PoseidonT3.poseidon([
            hashes[hashes.length - 2],
            hashes[hashes.length - 1]
        ]);

        index += 1;

        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool r = verifyProof(a, b, c, input);
        bool s = (input[0] == root);

        if (r && s){
            return true;
        } else {
            return false;
        }

    }
}