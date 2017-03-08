# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on March 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/masterimport pickle
from collections import defaultdict
from gensim import corpora, matutils

class Corpus:

    def __init__(self, articles):
        self.articles  = articles
        self.keys      = list(articles.keys())
        self.size      = len(articles.keys())

    def article(self, index):
        return self.articles[self.keys[index]]

    def mm(self, dictionary):
        values_set = set(dictionary.values())
        self.texts  = [[token for token in text if token in values_set] for text in self.texts]
      # print(self.texts[0])
        self.corpus = [dictionary.doc2bow(text) for text in self.texts]
        self.dense = matutils.corpus2dense(self.corpus, len(dictionary)).T

    def save(self, title):
        with open(title+".pickle", 'wb') as f:
            pickle.dump(self.articles, f)
        corpora.MmCorpus.serialize(title+".mm", self.corpus)

    @classmethod
    def load(cls, title):
        with open(title+".pickle", 'rb') as f:
            articles = pickle.load(f)
        corpus = cls(articles)
        corpus.corpus = corpora.MmCorpus(title+".mm")
        return corpus

    @classmethod
    def generate(cls, articles):
        corpus = cls(articles)
        corpus.texts = [articles[key].tokens for key in articles.keys()]
        corpus.index = {k:i for i, k in enumerate(articles.keys())}
        return corpus

