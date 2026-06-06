import { readFile, writeFile } from "node:fs/promises";

const [, , iconsetDir, outFile] = process.argv;
if (!iconsetDir || !outFile) {
  throw new Error("Usage: node make_icns.mjs <iconset-dir> <out.icns>");
}

const entries = [
  ["icp4", "icon_16x16.png"],
  ["icp5", "icon_32x32.png"],
  ["icp6", "icon_32x32@2x.png"],
  ["ic07", "icon_128x128.png"],
  ["ic08", "icon_256x256.png"],
  ["ic09", "icon_512x512.png"],
  ["ic10", "icon_512x512@2x.png"]
];

function u32(value) {
  const buffer = Buffer.alloc(4);
  buffer.writeUInt32BE(value, 0);
  return buffer;
}

const chunks = [];
for (const [type, file] of entries) {
  const png = await readFile(`${iconsetDir}/${file}`);
  chunks.push(Buffer.concat([Buffer.from(type, "ascii"), u32(png.length + 8), png]));
}

const totalLength = chunks.reduce((sum, chunk) => sum + chunk.length, 8);
await writeFile(outFile, Buffer.concat([Buffer.from("icns", "ascii"), u32(totalLength), ...chunks]));
