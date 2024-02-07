// pages/api/getProofHexByKey.js
import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  if (req.method === 'POST') {
    const { key } = req.body;

    const filePath = path.join(process.cwd(), 'public', 'proof.json');
    fs.readFile(filePath, (err, data) => {
      if (err) {
        return res.status(500).json({ message: 'Error reading proof file' });
      }
      const proofs = JSON.parse(data);
      const proofHex = proofs[key]; // Get the proofHex by key
      if (proofHex) {
        res.status(200).json({ proofHex });
      } else {
        res.status(404).json({ message: 'Proof not found for the given key' });
      }
    });
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
