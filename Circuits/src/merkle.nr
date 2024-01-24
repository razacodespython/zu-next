use dep::std::ecdsa_secp256k1::verify_signature;
use dep::std;
use dep::std::scalar_mul;
use dep::std::hash;

fn main(index : Field,
  leafLeft: Field,
  leafRight: Field
) {
    let root = std::merkle::compute_merkle_root(leafLeft, index, [leafRight]);
    std::println(root);
}