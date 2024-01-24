use dep::std::ecdsa_secp256k1::verify_signature;
use dep::std;
use dep::std::scalar_mul;
use dep::std::hash;
use dep::ecrecover;

fn main(
  pub_key_x: [u8; 32],
  pub_key_y: [u8; 32],
  signature: [u8; 64],
  hashed_message: pub [u8; 32],
  root: Field, index: Field, hash_path: [Field; 2]
  ) -> pub Field
{
    let key = ecrecover::secp256k1::PubKey::from_xy(pub_key_x, pub_key_y);
    let leaf = key.to_eth_address();

    // Check if leaf is valid
    let computedRoot = std::merkle::compute_merkle_root(leaf, index, hash_path);

    assert (root == computedRoot);

    // Check if ECDSA signature is valid
    let valid_signature = verify_signature(pub_key_x, pub_key_y, signature, hashed_message);
    assert(valid_signature);


    // Nullify by hashing the public key with the message
    let mut nullifierFields:[Field; 64] = [
      0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0
    ];

    for i in 0..32 {
      nullifierFields[i] = pub_key_x[i] as Field;
    };

    for i in 32..64 {
      nullifierFields[i] = hashed_message[i-32] as Field;
    };

    let nullifier = std::hash::pedersen_hash(nullifierFields);

    nullifier
}