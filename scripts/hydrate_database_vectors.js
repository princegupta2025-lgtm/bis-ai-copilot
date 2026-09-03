const fs = require('fs');
const path = require('path');

const vectorFile = path.join(__dirname, '..', 'data', 'bis_rag_embeddings.json');
const dbFile = path.join(__dirname, '..', 'js', 'database.js');

if (!fs.existsSync(vectorFile)) {
  console.error("bis_rag_embeddings.json does not exist.");
  process.exit(1);
}

const vectorData = JSON.parse(fs.readFileSync(vectorFile, 'utf8'));
const vectorsMap = {};

vectorData.chunks.forEach(chunk => {
  if (chunk.id && chunk.embedding) {
    // Round floats to 5 decimals to keep file size compact and precise
    vectorsMap[chunk.id] = chunk.embedding.map(v => Number(v.toFixed(5)));
  }
});

console.log(`Prepared ${Object.keys(vectorsMap).length} pre-computed BGE-small vectors.`);

let dbContent = fs.readFileSync(dbFile, 'utf8');

// Replace BIS_NEURAL_VECTOR_CACHE definition with pre-hydrated vector table
const cacheDeclaration = `const BIS_NEURAL_VECTOR_CACHE = {
  model: "BAAI/bge-small-en-v1.5",
  dimension: 384,
  vectors: ${JSON.stringify(vectorsMap)}
};`;

const regex = /const BIS_NEURAL_VECTOR_CACHE = \{[\s\S]*?vectors: \{[\s\S]*?\}\s*\};/;
if (regex.test(dbContent)) {
  dbContent = dbContent.replace(regex, cacheDeclaration);
  fs.writeFileSync(dbFile, dbContent, 'utf8');
  console.log(`Successfully inlined pre-computed BGE-small neural vectors into js/database.js!`);
} else {
  console.error("Could not find BIS_NEURAL_VECTOR_CACHE in database.js");
}
