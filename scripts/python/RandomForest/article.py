# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on March 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.
import codecs
import re
import mojimoji
from thesaurus import Thesaurus
from gensim import matutils

class Article:

    encodings = [
        "utf-8",
        "cp932",
        "euc-jp",
        "iso-2022-jp",
        "latin_1"
    ]

    tokenizer = Thesaurus('thesaurus.csv')

    def __init__(self,path):
        print(path)
        self.path = path
        self.contents = self.preprocess(self.get_contents(path))
      # self.contents = self.preprocess(self.get_title(path))
        self.tokens = [token.surface for token in self.tokenizer.tokenize(self.contents) if re.match("カスタム名詞|名詞,(固有|一般|サ変)", token.part_of_speech)]
      # print(self.tokens)

    def get_contents(self,path):
        exceptions = []
        for encoding in self.encodings:
            try:
                all = codecs.open(path, 'r', encoding).read()
                parts = re.split("(?i)<(body|frame)[^>]*>", all, 1)
                if len(parts) == 3:
                    head, void, body = parts
                else:
                    print('Cannot split ' + path)
                    body = all
                return re.sub("<[^>]+?>", "", re.sub(r"(?is)<(script|style|select|noscript)[^>]*>.*?</\1\s*>","", body))
            except UnicodeDecodeError:
                continue
        print('Cannot detect encoding of ' + path)
        print(exceptions)
        return None

    def get_title(self,path):
        return re.split('\/', path)[-1]

    def preprocess(self, text):
        text = re.sub("&[^;]+;",  " ", text)
        text = mojimoji.han_to_zen(text, digit=False)
      # text = re.sub('(\s|　|＃)+', " ", text)
        return text

    def dense(self, dictionary):
        values_set = set(dictionary.values())
        text   = [token for token in self.tokens if token in values_set]
        corpus = dictionary.doc2bow(text)
        return matutils.corpus2dense([corpus], len(dictionary)).T[0]
