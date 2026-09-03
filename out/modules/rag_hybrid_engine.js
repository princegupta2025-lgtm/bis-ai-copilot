/**
 * BIS TRUST COPILOT — HYBRID RAG RETRIEVAL ENGINE
 * Combines Okapi BM25 Lexical Ranking + 384-D BGE Dense Semantic Vectors + RRF (Reciprocal Rank Fusion).
 * Standalone, zero external dependencies.
 */

// 1. OKAPI BM25 LEXICAL RETRIEVER
class OkapiBM25 {
  constructor(corpus, options = {}) {
    this.corpus = corpus || [];
    this.k1 = options.k1 || 1.2;
    this.b = options.b || 0.75;
    this.docCount = this.corpus.length;
    this.docLengths = [];
    this.avgDocLength = 0;
    this.invertedIndex = {};

    this._buildIndex();
  }

  _tokenize(text) {
    return String(text || '')
      .toLowerCase()
      .replace(/[^\w\s\:\-\/]/g, ' ')
      .split(/\s+/)
      .filter(t => t.length > 1);
  }

  _buildIndex() {
    let totalLength = 0;
    for (let i = 0; i < this.docCount; i++) {
      const doc = this.corpus[i];
      const text = `${doc.standardCode || ''} ${doc.standardTitle || ''} ${doc.clauseTitle || ''} ${doc.text || ''}`;
      const tokens = this._tokenize(text);
      this.docLengths.push(tokens.length);
      totalLength += tokens.length;

      const termFreqs = {};
      tokens.forEach(t => { termFreqs[t] = (termFreqs[t] || 0) + 1; });

      for (const [term, freq] of Object.entries(termFreqs)) {
        if (!this.invertedIndex[term]) this.invertedIndex[term] = [];
        this.invertedIndex[term].push({ docIndex: i, tf: freq });
      }
    }
    this.avgDocLength = totalLength / (this.docCount || 1);
  }

  search(query, topN = 10) {
    const queryTokens = this._tokenize(query);
    const scores = new Float64Array(this.docCount);

    for (const token of queryTokens) {
      const postings = this.invertedIndex[token];
      if (!postings) continue;

      const df = postings.length;
      const idf = Math.log(1 + (this.docCount - df + 0.5) / (df + 0.5));

      for (const post of postings) {
        const docLen = this.docLengths[post.docIndex];
        const tf = post.tf;
        const numerator = tf * (this.k1 + 1);
        const denominator = tf + this.k1 * (1 - this.b + this.b * (docLen / this.avgDocLength));
        scores[post.docIndex] += idf * (numerator / denominator);
      }
    }

    const ranked = [];
    for (let i = 0; i < this.docCount; i++) {
      if (scores[i] > 0) {
        ranked.push({ index: i, bm25Score: scores[i], chunk: this.corpus[i] });
      }
    }
    return ranked.sort((a, b) => b.bm25Score - a.bm25Score).slice(0, topN);
  }
}

// 2. DENSE COSINE SIMILARITY
function cosineSimilarity(vecA, vecB) {
  if (!vecA || !vecB || vecA.length !== vecB.length) return 0;
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
    normA += vecA[i] * vecA[i];
    normB += vecB[i] * vecB[i];
  }
  const denom = Math.sqrt(normA) * Math.sqrt(normB);
  return denom === 0 ? 0 : dotProduct / denom;
}

// 3. RECIPROCAL RANK FUSION (RRF)
function reciprocalRankFusion(bm25Ranked, denseRanked, k = 60, topN = 6) {
  const scoreMap = new Map();

  // Score from BM25 rankings
  bm25Ranked.forEach((item, rank) => {
    const id = item.chunk.id || `doc-${item.index}`;
    const score = 1 / (k + rank + 1);
    scoreMap.set(id, { chunk: item.chunk, rrfScore: score, bm25Rank: rank + 1, denseRank: 999 });
  });

  // Add Dense ranking scores
  denseRanked.forEach((item, rank) => {
    const id = item.chunk.id || `doc-${item.index}`;
    const rrfIncrement = 1 / (k + rank + 1);
    if (scoreMap.has(id)) {
      const entry = scoreMap.get(id);
      entry.rrfScore += rrfIncrement;
      entry.denseRank = rank + 1;
    } else {
      scoreMap.set(id, { chunk: item.chunk, rrfScore: rrfIncrement, bm25Rank: 999, denseRank: rank + 1 });
    }
  });

  return Array.from(scoreMap.values())
    .sort((a, b) => b.rrfScore - a.rrfScore)
    .slice(0, topN);
}

// Export for Node.js and Browser
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    OkapiBM25,
    cosineSimilarity,
    reciprocalRankFusion
  };
}
