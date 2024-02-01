import styles from '@/styles/Home.module.css'
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../Circuits/target/circuit.json';
import { useState } from 'react';
import { ethers } from 'ethers';
import merkleData from '../public/merkleData.json';

export default function Home() {
  const [addi, setPublickey] = useState();
  const [network, setNetwork] = useState();
  const [chainId, setChainId] = useState();
  const [msg, setMsg] = useState();

  const connectButton = async () => {
    const { ethereum } = window;
    const provider = new ethers.providers.Web3Provider(ethereum);
    if (ethereum.isMetaMask) {
      const accounts = await provider.send("eth_requestAccounts", [])
      const { name, chainId } = await provider.getNetwork();
      setNetwork(name);
      setChainId(chainId);
      setPublickey(accounts[0]);
    } else {
      setMsg("Install MetaMask");
    }
  };

  
  function splitIntoPairs(str) {
    return str.match(/.{1,2}/g) || [];
  }

  const sendProof = async (message) => {
    console.log("generating proof")

    const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const signerAddress = await signer.getAddress()
    console.log("Account:", signerAddress);

    const signature = await signer.signMessage(message);
    var hashedMessage = ethers.utils.hashMessage(message)
    var publicKey = ethers.utils.recoverPublicKey(
      hashedMessage,
      signature)
    console.log(ethers.utils.computeAddress(publicKey))

    publicKey = publicKey.substring(4)

    let pub_key_x = publicKey.substring(0, 64);
    let pub_key_y = publicKey.substring(64);

    var sSignature = Array.from(ethers.utils.arrayify(signature))
    sSignature.pop()

    const backend = new BarretenbergBackend(circuit);
    const noir = new Noir(circuit, backend);

    let hashPath = []
    let index = ""
    for(let i = 0; i<merkleData.leaves.length; i++)
    {
      if(merkleData.leaves[i].value == signerAddress)
      {
        hashPath = merkleData.leaves[i].hashPath
        index = merkleData.leaves[i].index
      }
    }
    if(hashPath == [] || index == "")
    {
      alert("Error: could not locate your account on the attendant merkle tree")
    }

    const input = {
      hash_path: hashPath,
      index: index,
      root: merkleData.root,
      pub_key_x: Array.from(ethers.utils.arrayify("0x"+pub_key_x)),
      pub_key_y: Array.from(ethers.utils.arrayify("0x"+pub_key_y)),
      signature: sSignature,
      hashed_message: Array.from(ethers.utils.arrayify(hashedMessage))
    };  
    console.log("got the input next step generating proof")

    // document.getElementById("web3_message").textContent="Generating proof... ⌛";
    var proof = await noir.generateFinalProof(input);

    console.log("proof generation done")
    // document.getElementById("web3_message").textContent="Generating proof... ✅";

    var publicInputs = Array.from(proof.publicInputs.values());
    var proofHex = "0x" + Buffer.from(proof.proof).toString('hex')
    const abi = [
      "function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool)"
    ]
    const verifierContract = new ethers.Contract("0x02801ed0D4A5dFd0bf82C074e1f40FBcb4a2e24F", abi, signer)
    const verificationResponse = await verifierContract.verify(proofHex, publicInputs)
    if(verificationResponse == true) {
      console.log("Verification successful!")
    }
  }

  return (
    <>
     <h1>Hello world</h1>
      <button onClick={connectButton}>Connect Wallet</button>
      <br />
      <p>Address: {addi}</p>
      <p>Network: {network}</p>
      <p>Chain ID : {chainId}</p>
      {msg && <p>{msg}</p>}
      <button onClick={() => sendProof("Ethticket")}>Get proof</button>
    </>
  )
}
