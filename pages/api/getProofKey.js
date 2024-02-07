// pages/api/getProofKey.js
import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  if (req.method === 'GET') {
    const filePath = path.join(process.cwd(), 'public', 'proof.json');

    fs.readFile(filePath, (err, data) => {
      if (err) {
        return res.status(500).json({ message: 'Error reading proof file' });
      }
      const proofData = JSON.parse(data);
      const proofKey = Object.keys(proofData)[0]; // Assuming the key you want is the first key in the JSON object
      res.status(200).json({ key: proofKey });
    });
  } else {
    res.setHeader('Allow', ['GET']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
