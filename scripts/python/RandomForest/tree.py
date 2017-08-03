# -*- coding: utf-8 -*-
# This script was written by Takashi SUGA on March 2017
# You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master
from collections import defaultdict
import re

class DirTree:

    def __init__(self, paths):
        self.branches = defaultdict(list)
        for path in paths:
            branch = path.split('/')
            for i in range(1,len(branch)):
               self.branches['/'.join(branch[0:i])].append(path)
        self.dirs = defaultdict(list)
        for dir in self.branches.keys():
            self.dirs[re.sub('\/[^\/]+$', '', dir)].append(dir)
        self.leaves = defaultdict(list)
        for path in paths:
            self.leaves[re.sub('\/[^\/]+$', '', path)].append(path)

    def labels(self, dir):
        labels = [child[len(dir)+1:] for child in self.dirs[dir]]
        if len(self.leaves[dir]) > 0:
            labels.append('__others__')
        return labels

    def label(self, dir, path):
        for child in self.dirs[dir]:
            if path.startswith(child+'/'):
                return child[len(dir)+1:]
        if path.startswith(dir+'/'):
            return '__others__'
        else:
            return None
