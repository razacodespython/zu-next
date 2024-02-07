import styles from '@/styles/Home.module.css'
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../Circuits/target/circuit.json';
import { useState } from 'react';
import { ethers } from 'ethers';
import QRCode from 'react-qr-code';
import merkleData from '../public/merkleData.json';



export default function Home() {
  const [addi, setPublickey] = useState();
  const [network, setNetwork] = useState();
  const [chainId, setChainId] = useState();
  const [msg, setMsg] = useState();

  const [qrValue, setQrValue] = useState('');

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
    //this one works 👇
    // const input = {
    //   hash_path: ["0x000000000000000000000000bef34f2FCAe62dC3404c3d01AF65a7784c9c4A19","0x00000000000000000000000008966BfFa14A7d0d7751355C84273Bb2eaF20FC3"],
    //   index: "0",
    //   root: "0x18dd8c28fdcab0f84062e8c5a354e87672a58d0638d30367c2c1e3ed16eaf0ec",
    //   pub_key_x: Array.from(ethers.utils.arrayify("0x"+pub_key_x)),
    //   pub_key_y: Array.from(ethers.utils.arrayify("0x"+pub_key_y)),
    //   signature: sSignature,
    //   hashed_message: Array.from(ethers.utils.arrayify(hashedMessage))
    // };  

    // const input = {
    //   hash_path: ["0x000000000000000000000000AFe1E78912aD55D7aD0850E6868FDf54E3c9ba43","0x1c3e85801102cb419e47145809fac441e38f2cefca80f55d41ed7f341b4a879e"],
    //   index: "1",
    //   root: "0x133c28ec2626445df05a63391fd9e3c585da2c3149b7f187656c7d37325d9931",
    //   pub_key_x: Array.from(ethers.utils.arrayify("0x"+pub_key_x)),
    //   pub_key_y: Array.from(ethers.utils.arrayify("0x"+pub_key_y)),
    //   signature: sSignature,
    //   hashed_message: Array.from(ethers.utils.arrayify(hashedMessage))
    // };  

    console.log("got the input next step generating proof")
    console.log(input)
    // document.getElementById("web3_message").textContent="Generating proof... ⌛";
    var proof = await noir.generateFinalProof(input);

    console.log("proof generation done")
    // document.getElementById("web3_message").textContent="Generating proof... ✅";



    var publicInputs = Array.from(proof.publicInputs.values());
    var proofHex = "0x" + Buffer.from(proof.proof).toString('hex')

    const proofKey = proofHex.substring(0, 50);
    const proofObject = { [proofKey]: proofHex };

    // Use fetch API to send proof data to your API route
    fetch('/api/updateProof', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ proofData: proofObject }),
    })
    .then(response => response.json())
    .then(data => console.log(data))
    .catch((error) => console.error('Error:', error));


    const abi = [
      "function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool)"
    ]
    const verifierContract = new ethers.Contract("0x02801ed0D4A5dFd0bf82C074e1f40FBcb4a2e24F", abi, signer)

  //   const verificationResponse = await verifierContract.verify(proofHex, publicInputs)
  //   if(verificationResponse == true) {
  //     console.log("Verification successful!")
  //   }
  }

  const verifyProof = async (key, publicInputs) => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      // Fetch the proofHex by key from the API
      const response = await fetch('/api/verify', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ key }),
      });
  
      const { proofHex } = await response.json();
  
      // Proceed with verification using the fetched proofHex
      const abi = [
        "function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool)"
      ];
      const verifierContract = new ethers.Contract("0x02801ed0D4A5dFd0bf82C074e1f40FBcb4a2e24F", abi, signer);
  
      const verificationResponse = await verifierContract.verify(proofHex, publicInputs);
      if (verificationResponse === true) {
        console.log("Verification successful!");
        // Handle successful verification
      } else {
        console.log("Verification failed.");
        // Handle verification failure
      }
    } catch (error) {
      console.error('Error during verification:', error);
      // Handle errors (e.g., network error, proof not found, etc.)
    }
  };
  

  const fetchProofKeyAndGenerateQR = async () => {
    try {
      const response = await fetch('/api/getProofKey');
      const { key } = await response.json();
      setQrValue(key); // Set the fetched key as the QR code value
    } catch (error) {
      console.error('Failed to fetch the proof key:', error);
    }
  };

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
      {/* Button to generate QR code */}
      <button onClick={fetchProofKeyAndGenerateQR}>Generate QR Code</button>
      {qrValue && <QRCode value={qrValue} />} {/* Render QR code if qrValue is set */}
      <button onClick={() => verifyProof()}>Verify</button>

    </>
  )
}
