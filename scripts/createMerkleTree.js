import MerkleTree from "merkletreejs";
import keccak256 from "keccak256";



export function createMerkleTree(
  ticketOwners
) {
  const leaves = ticketOwners.map((owner) => {
    return ethers.utils.solidityKeccak256(['address'], [owner]);
  });

  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

  return tree;
}
