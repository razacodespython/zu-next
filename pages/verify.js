import styles from '@/styles/Home.module.css'
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../circuit/target/circuit.json';

const NETWORK_ID = process.env.CHAIN_ID



export default function Home() {
  return (
    <>
     <h1>scanner person</h1>
    </>
  )
}
