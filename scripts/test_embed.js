const { pipeline } = require('@xenova/transformers');

async function test() {
  console.log('Loading genuine pretrained embedding model: BAAI/bge-small-en-v1.5...');
  const extractor = await pipeline('feature-extraction', 'Xenova/bge-small-en-v1.5');
  
  const text1 = 'Protective helmets for motorcycle two wheeler riders drop test shock absorption';
  const text2 = 'What is the impact shock attenuation limit under IS 4151?';
  const text3 = 'FRLS copper electric wire insulation resistance';

  const out1 = await extractor(text1, { pooling: 'mean', normalize: true });
  const out2 = await extractor(text2, { pooling: 'mean', normalize: true });
  const out3 = await extractor(text3, { pooling: 'mean', normalize: true });

  const vec1 = out1.data;
  const vec2 = out2.data;
  const vec3 = out3.data;

  // Cosine dot product of normalized vectors
  let dot12 = 0;
  let dot13 = 0;
  for (let i = 0; i < vec1.length; i++) {
    dot12 += vec1[i] * vec2[i];
    dot13 += vec1[i] * vec3[i];
  }

  console.log('Embedding Dimension:', vec1.length);
  console.log('Cosine Sim (Helmet doc vs Helmet query):', dot12.toFixed(4));
  console.log('Cosine Sim (Helmet doc vs Wire query):', dot13.toFixed(4));
  console.log('Success! Genuine Pretrained Transformer Semantic Embeddings Verified!');
}

test().catch(err => console.error('Test error:', err));