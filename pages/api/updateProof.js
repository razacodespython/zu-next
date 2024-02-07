// pages/api/updateProof.js
import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  if (req.method === 'POST') {
    // Get proof data from request body
    const { proofData } = req.body;

    // Define the path to the proof.json file in the public folder
    const filePath = path.join(process.cwd(), 'public', 'proof.json');

    // Write the proof data to proof.json
    fs.writeFile(filePath, JSON.stringify(proofData, null, 2), 'utf8', (err) => {
      if (err) {
        return res.status(500).json({ message: 'Error writing file', error: err });
      }
      return res.status(200).json({ message: 'File updated successfully' });
    });
  } else {
    // Handle any non-POST requests
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
