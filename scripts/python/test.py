# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on March 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master
import logging
import glob
import numpy as np
from collections import defaultdict, OrderedDict
from gensim import corpora
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from corpus import Corpus
from article import Article
from tree import DirTree

#logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

path_pattern = '/home/samba/example/links/bookmarks.crawled/**/*.html'
dir = '/home/samba/example/links/bookmarks.crawled/Computer/トピック/セマンティックウェブ'
test_ratio=0.1

class DataSet(object):

    def __init__(self, paths):
        self.articles = OrderedDict([(path,Article(path)) for path in paths])
        self.corpus   = Corpus.generate(self.articles)
        self.tree     = DirTree(paths)

class Single(object):

    def __init__(self, path):
        self.training = DataSet(glob.glob(path, recursive=True))
        self.init_titles()
        self.init_dictionary(self.training.corpus.texts)
        self.training.corpus.mm(self.dictionary)

    def init_dictionary(self, all_texts):
        frequency = defaultdict(int)
        for text in all_texts:
            for token in text:
                frequency[token] += 1
        all_texts = [[token for token in text if frequency[token] > 1] for text in all_texts]
        self.dictionary = corpora.Dictionary(all_texts)

    def init_titles(self):
        self.titles = defaultdict(list)
        for article in self.training.corpus.keys:
            self.titles[article.split('/')[-1]].append(article)

    def train(self, dir):
        patterns = []
        kinds    = []
        for i, article in enumerate(self.training.corpus.keys):
            labels = [self.training.tree.label(dir, title) for title in self.titles[article.split('/')[-1]]]
            kind   = [1 if label in labels else 0 for label in self.training.tree.labels(dir)]
            if 1 in kind:
                kinds.append(kind)
                patterns.append(self.training.corpus.dense[i])
        classifier = RandomForestClassifier()
        return classifier.fit(patterns, kinds)

    def classify(self, dir, classifier, article):
        predict = classifier.predict([article.dense(self.dictionary)])[0]
        pprint(article.path)
        pprint({self.training.tree.labels(dir)[i]:predict[i] for i in range(0,len(predict))})

class Double(Single):

    def __init__(self, path, test_ratio):
        training_paths, test_paths = train_test_split(glob.glob(path, recursive=True), test_size=test_ratio, random_state=2017)
        self.training = DataSet(training_paths)
        self.test     = DataSet(test_paths)
        self.init_titles()
        self.init_dictionary(self.training.corpus.texts + self.test.corpus.texts)
        self.training.corpus.mm(self.dictionary)
        self.test.corpus.mm(self.dictionary)

    def validate(self, dir, classifier):
        for path in self.test.tree.branches[dir]:
            predict = classifier.predict([self.test.corpus.dense[self.test.corpus.index[path]]])[0]
            pprint(path)
            pprint({self.training.tree.labels(dir)[i]:predict[i] for i in range(0,len(predict))})

if __name__ == '__main__':
  # data = Double(path_pattern, test_ratio)
  # classifier = data.train(dir)
  # data.validate(dir, classifier)
    data = Single(path_pattern)
    classifier = data.train(dir)
    data.classify(dir, classifier, list(data.training.articles.values())[0])

