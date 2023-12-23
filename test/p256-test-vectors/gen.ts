// P256 Vector Generation taken from Daimo and modified to disallow malleability
// https://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/generate_random_valid.ts (MIT License)

import crypto from "crypto";
import fs from "fs";
import { bytesToBigInt, toHex } from "viem";

// Generate random signatures for benchmarking gas usage.
// Representative of real-world usage.
async function main() {
  const vectors: {x: string, y: string, r: string, s: string, hash: string, valid: boolean, msg: string}[] = [];

  while (vectors.length < 1000) {
    const p256 = { name: "ECDSA", namedCurve: "P-256", hash: "SHA-256" };
    const key = await crypto.subtle.generateKey(p256, true, ["sign", "verify"]);
    const pubKeyDer = await crypto.subtle.exportKey("spki", key.publicKey);
    const pubKeyHex = Buffer.from(pubKeyDer).toString("hex");

    const msg: string = `deadbeef${vectors.length
      .toString(16)
      .padStart(4, "0")}`;
    const msgBuf = Buffer.from(msg, "hex");
    const msgHash = Buffer.from(await crypto.subtle.digest("SHA-256", msgBuf));
    const sigRaw = await crypto.subtle.sign(p256, key.privateKey, msgBuf);


    const pubKey = Buffer.from(pubKeyHex.substring(54), "hex");
    assert(pubKey.length === 64, "pubkey must be 64 bytes");
    const x = `${pubKey.subarray(0, 32).toString("hex")}`;
    const y = `${pubKey.subarray(32).toString("hex")}`;

    const r = bytesToBigInt(Buffer.from(sigRaw).subarray(0, 32));
    let s = bytesToBigInt(Buffer.from(sigRaw).subarray(32, 64));
    const n = BigInt(
      "0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551"
    );
    if (s > n / 2n) {
      s = n - s;
    }    

    vectors.push({
      x,
      y,
      r: toHex(r, {size: 32}).slice(2),
      s: toHex(s, {size: 32}).slice(2),
      hash: msgHash.toString("hex"),
      valid: true,
      msg,
    });
  }

  // Write to JSON
  const filepath = "./test/p256-test-vectors/vectors_random_valid.jsonl";
  console.log(`Writing ${vectors.length} vectors to ${filepath}`);
  const lines = vectors.map((v) => JSON.stringify(v));
  fs.writeFileSync(filepath, lines.join("\n"));
}

function assert(cond: boolean, msg: string) {
  if (!cond) throw new Error(msg);
}

main()
  .then(() => console.log("Done"))
  .catch((err) => console.error(err));