# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on March 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master
import re
import mojimoji

class Thesaurus:

    def __init__(self,path):
        map = dict()
        with open(path, 'r') as thesaurus:
            for line in thesaurus.readlines():
                words = [mojimoji.han_to_zen(word, digit=False) for word in re.split(',', line.strip())]
                for word in words:
                    if word in map:
                        print('Word duplicated: ' + word)
                        raise
                    map[word] = words[0]
        self.words = map
        self.re    = re.compile("|".join(sorted(map.keys(), key=lambda x: -len(x))))

    def tokenize(self,sentence):
        for token in re.finditer(self.re, sentence):
            yield(Token(self.words[token.group()]))

class Token:

    def __init__(self, surface):
        self.surface = surface
        self.part_of_speech = "カスタム名詞"
