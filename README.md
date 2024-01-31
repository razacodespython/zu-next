# Scope
1. NFT contract with merkle root containing whitelist of addresses that are allowed to mint nft ticket
2. on Ethereum, merkle root is queried and verified with a storage proof
3. Merkle root, signed hash message and public key used as input for the circuit
4. Circuit generates proof
5. App stores proof in key value pair in .json [not done yet]
6. Verifier retrieves proof based on key [not done yet]
7. verifies proof [tbd onchain vs off chain]

# Todo

## QR Code @raza
Include a .json to store the proof with a corresponding 'key', like this[as an example]:

```
{
'x01':'10983274198023740982537423094857'
}
```
Key is converted in a QR code, insteda of proof. Proof too much data for a QR code.

When verifier scans QR code, it looks up the value for the key, and passes it to the verifier contract.

## Retrieve & Verify with storage proof @ahmed
Retrieval of merkle root on Scroll via L1-Ethereum is generating some issues. Engineers are looking at this. Ahmed to try again asap.

## Dynamic address retrieval from Merkle Tree @ahmed

Right now the address is retrieved from merkle tree by passing the index number for the leave.  
So it's hardcoded.
@Ahmed will adjust this so that the connect wallet's address is dynamically retrieved.


## Merkle Tree generation @tbd

Right now a pedersen hash is used to generate the Merkle Root with all the addresses as Noir uses this.  
This is a manual process, talking to engineers to generate a script for this. Python not suitable, need to check in Rust.

## Decentralised Storage @ahmed

Instead of using a database, we can opt to store data on arweave or filecoin, so data is still decentralised.
Data to be stored:
1. key value pair for QR code
2. ...
