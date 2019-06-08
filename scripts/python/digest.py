# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on August 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master
"""Doc2Vec による分散表現で文の間の距離を測って文章を要約する実験

   参考にした記事
     models.doc2vec – Deep learning with paragraph2vec
      ( https://radimrehurek.com/gensim/models/doc2vec.html )
     Doc2Vec Tutorial on the Lee Dataset
      ( https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/doc2vec-lee.ipynb )
     Doc2Vecの仕組みとgensimを使った文書類似度算出チュートリアル
       ( https://deepage.net/machine_learning/2017/01/08/doc2vec.html )
     自動要約アルゴリズムLexRankを用いたECサイトの商品価値の要約
       ( http://qiita.com/takumi_TKHS/items/4a56ac151c60da8bde4b )
"""
import sys
import glob
import numpy as np
from os import listdir, path
from gensim import models
from gensim.models.doc2vec import TaggedDocument
import pprint
from datetime import datetime
from scipy.spatial import distance
import mojimoji
import codecs

pp = pprint.PrettyPrinter(indent=4)

# 記事のパスリストから、記事コンテンツに変換し、
# 単語分割して、センテンスのジェネレーターを返す関数
def corpus_to_sentences(corpus):
    docs   = [read_document(x) for x in corpus]
    for idx, (doc, name) in enumerate(zip(docs, corpus)):
        if idx % 1 == 0:
            sys.stdout.write('\r前処理中 {}/{}'.format(idx, len(corpus)))
            yield doc_to_sentence(doc, name)

# 記事ファイルをダウンロードしたディレクトリから取得する
def corpus_files():
    path_pattern = '/home/samba/example/links/bookmarks.plaintext/**/*.txt'
    docs = [path for path in glob.glob(path_pattern, recursive=True)]
    return docs

# 記事コンテンツをパスから取得する
def read_document(path):
    with codecs.open(path, 'r', 'utf-8') as f:
        return f.read()

# 区切り文字を使って記事を単語リストに変換する
def split_into_words(text):
    return text.split('/')

# 記事コンテンツを単語に分割して、Doc2Vecの入力に使うTaggedDocumentに変換する
def doc_to_sentence(doc, name):
    words = split_into_words(doc)
    return TaggedDocument(words=words, tags=[name])

# LexRank による文の重みづけ
def lexrank(vector, threshold):

    N = len(vector)

    CosineMatrix = np.zeros([N, N])
    degree = np.zeros(N)
    L = np.zeros(N)

    # Computing Adjacency Matrix
    for i in range(N):
        for j in range(N):
            CosineMatrix[i,j] = 1 - distance.cosine(vector[i], vector[j])
            if CosineMatrix[i,j] > threshold:
                CosineMatrix[i,j] = 1
                degree[i] += 1
            else:
                CosineMatrix[i,j] = 0

    # Computing LexRank Score
    for i in range(N):
        for j in range(N):
            CosineMatrix[i,j] = CosineMatrix[i,j] / degree[i]

    L = PowerMethod(CosineMatrix, N, err_tol=10e-6)

    return L

# 文章を分散表現化
def path_to_vectors(path, threshold):
    with codecs.open(path, 'r', 'utf-8') as f:
        for index, line in enumerate(f):
            words = line.split('/')
            if len(words) >= threshold:
                yield (index, line, model.infer_vector(words))

# 固有値計算
def PowerMethod(CosineMatrix, N, err_tol):

    p_old = np.array([1.0/N]*N)
    err = 1

    while err > err_tol:
        err = 1
        p = np.dot(CosineMatrix.T, p_old)
        err = np.linalg.norm(p - p_old)
        p_old = p

    return p

# 前処理
corpus = corpus_files()
sentences = corpus_to_sentences(corpus)
#print(type(sentences))
sentences = list(sentences)

# 学習
laptime = datetime.now()
print('\n学習 size={} window={} min_count={} sample={}'.format(60, 5, 2, 0.001))
model = models.doc2vec.Doc2Vec(dm=0, vector_size=60, window=5, min_count=2, sample=0.001, epochs=50)
model.build_vocab(sentences)
print(datetime.now() - laptime)
#print(model.corpus_count)
model.train(sentences, total_examples=model.corpus_count, epochs=model.epochs)
print(datetime.now() - laptime)

'''
# モデルの書き出し
model.save('doc2vec.model')

# モデルの読み込み
model = models.Doc2Vec.load('doc2vec.model')
'''

# 200番目の記事に近い記事を10個選ぶ
print('similar articles of {}'.format(corpus[200]))
pp.pprint(model.docvecs.most_similar(corpus[200], topn=10))

# 0番目と100番目の記事の近さを測る
print('similarity between {} and {}'.format(corpus[0], corpus[100]))
print(model.docvecs.similarity(corpus[0], corpus[100]))

# 700番目の記事の各文の重みを計算する
print()
path = corpus[700]
vectors = list(path_to_vectors(path, 10))
L = lexrank([vector for index, line, vector in vectors], 0.1).tolist()
threshold = 0 if len(L) <= 15 else sorted(L, reverse=True)[15]

print(path)
for rank, (index, line, vector) in zip(L,vectors):
    if rank >= threshold:
        print((index,rank,mojimoji.zen_to_han(line.replace('/','').replace('\t',''), kana=False)))

