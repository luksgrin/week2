pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

// Got stuck while trying to make an `if` statement with the `path_index[n]`.
// It seems that signals only support mathematical operations (makes sense).
// So, I googled a solution and saw in this repo:
// https://github.com/appliedzkp/maci/blob/v1/circuits/circom/trees/incrementalMerkleTree.circom
// that the way to go was to use MultiMux. So, this user basically saved my life and showed me this amazing library.
// Cheers to them!

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    component Psdn = Poseidon(2);

    for (var i = n; i > 0; i--) {

        for (var j = 0; j < 2**(i - 1); j++) {

            Psdn.inputs[0] <== leaves[2*j];
            Psdn.inputs[1] <== leaves[(2*j) + 1];
            leaves[j] <== Psdn.out;

        }
    }

    root <== leaves[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    signal container[n + 1];

    component Psdn[n];
    component mux[n];

    container[0] <== leaf;

    for (var i = 0; i < n; i++) {

        mux[i] = MultiMux1(2);
        Psdn[i] = Poseidon(2);

        mux[i].c[0][0] <== container[i];
        mux[i].c[0][1] <== path_elements[i];

        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== container[i];

        mux[i].s <== path_index[i];

        Psdn[i].inputs[0] <== mux[i].out[0];
        Psdn[i].inputs[1] <== mux[i].out[1];

        container[i + 1] <== Psdn[i].out;

    }

    root <== container[n];

}
