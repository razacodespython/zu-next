import styles from '@/styles/Home.module.css'
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../Circuits/circuit/target/circuit.json';
import { useState } from 'react';
import { ethers } from 'ethers';

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

  const avlNetwork = {
    137: {
      chainId: `0x${Number(137).toString(16)}`,
      rpcUrls: ["https://polygon-rpc.com"],
      chainName: "Polygon Mainnet",
      nativeCurrency: {
        name: "MATIC",
        symbol: "MATIC",
        decimals: 18
      },
      blockExplorerUrls: ["https://polygonscan.com/"]
    },
    43114: {
      chainId: `0x${Number(43114).toString(16)}`,
      rpcUrls: ["https://api.avax.network/ext/bc/C/rpc"],
      chainName: "Avalanche C-Chain",
      nativeCurrency: {
        name: "Avalanche",
        symbol: "AVAX",
        decimals: 18
      },
      blockExplorerUrls: ["https://snowtrace.io/"]
    }
  };

  const switchNetwork = async (chainId) => {
    try {
      await window.ethereum.request({
        method: "wallet_addEthereumChain",
        params: [avlNetwork[`${chainId}`]]
      });
      setNetwork(avlNetwork[`${chainId}`].chainName);
      setChainId(chainId);
    } catch (error) {
      setMsg(error);
    }
  };

  function splitIntoPairs(str) {
    return str.match(/.{1,2}/g) || [];
  }
const NETWORK_ID = process.env.CHAIN_ID
const sendProof = async (message) => {
  console.log("generating proof")
  // document.getElementById("web3_message").textContent="Please sign the message ✍️";
  /*
  var msgParams = JSON.stringify({
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        Comment: [
            { name: 'event', type: 'string' },
            { name: 'description', type: 'string' }
        ],
    },
    primaryType: 'Comment',
    domain: {
        name: 'Zupass Tickets',
        version: '1',
        chainId: parseInt(NETWORK_ID),
        verifyingContract: COMMENT_VERIFIER_ADDRESS,
    },
    message: {
        event: event,
        description: description,
    },
  });
  
  var signature = await ethereum.request({
    method: "eth_signTypedData_v4",
    params: [accounts[0], msgParams],
  });

  var hashedMessage = ethers.utils.hashMessage(msgParams)  
  const hashedMessageArray = ethers.utils.arrayify(hashedMessage)

  var publicKey = ethers.utils.recoverPublicKey(hashedMessage, signature)
  //publicKey = publicKey.substring(4)

  let pub_key_x = publicKey.substring(0, 64);
  let pub_key_y = publicKey.substring(64);
  
  var sSignature = Array.from(ethers.utils.arrayify(signature))
  sSignature.pop()
*/

  const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
  await provider.send("eth_requestAccounts", []);
  const signer = provider.getSigner();
  console.log("Account:", await signer.getAddress());

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
  
  const input = {
    hash_path: ["0x000000000000000000000000bef34f2FCAe62dC3404c3d01AF65a7784c9c4A19","0x00000000000000000000000008966BfFa14A7d0d7751355C84273Bb2eaF20FC3"],
    index: "0",
    root: "0x18dd8c28fdcab0f84062e8c5a354e87672a58d0638d30367c2c1e3ed16eaf0ec",
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
  

  var tHashedMessage = Array.from(proof.publicInputs.values());

  //proof = "0x" + ethereumjs.Buffer.Buffer.from(proof.proof).toString('hex')

  /*
  var tHashedMessage = []
  for (let entry of proof.publicInputs.entries()) {
    tHashedMessage.push(entry)
  }
  */

  /*
  //splitIntoPairs(hashedMessage.substring(2))
  for(var i=0; i<tHashedMessage.length; i++)
  {
    tHashedMessage[i] = "0x00000000000000000000000000000000000000000000000000000000000000" + tHashedMessage[i]
  }
  */

  // var qrData = {
  //   proof: proof,
  //   publicParams: tHashedMessage,
  //   message: message
  // }
  // var qrDataStr = JSON.stringify(qrData);
  
  // console.log(qrData)
  // console.log(qrDataStr)

  // //qrcode.makeCode(qrDataStr);// qr is to big
  // var qrcode = new QRCode("qrcode",'placeholder')

  // await updateMetadata(proof, tHashedMessage, message)
  console.log("proof: "+proof.proof, "hashedmsg: "+ tHashedMessage, "message: "+message)
  /*
  const result = await my_contract.methods.sendProof(proof, tHashedMessage, title, text)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Executing...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success.";    })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
  */


}

  return (
    <>
     <h1>Hello world</h1>
     <h1>Connect with Ethers.JS</h1>
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
