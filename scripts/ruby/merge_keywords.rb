# -*- coding: utf-8 -*-
=begin
  Copyright (C) 2016-2017 Takashi SUGA

  You may use and/or modify this file according to the license
  described in the LICENSE.txt file included in this archive.

  Usage:

    ruby merge_keywords.rb <list> <filter> > <keywords>

    list     : キーワードのリスト
    filter   : 抽出するディレクトリのリスト(省略すると全ディレクトリを抽出)
    keywords : 同義語辞書

=end

require 'fileutils'
require './serial'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

def keywords(synonyms, title, contents)
  title.split('/')[0...-1].each do |line|
    line.gsub!('・',',') unless line =~ /^[\p{katakana}・ー]+$/
    contents.concat(line.split(','))
  end
  contents.each do |line|
    items = line.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').split(',')
    items.each do |item|
      synonyms[item] |= items
      synonyms[item].sort!
    end
  end
end

list, filter = ARGV
if filter
  ex = []
  IO.foreach(filter) do |line|
    ex << line.chomp.gsub("/", "\\/")
  end
  filter = /^(#{ex.join('|')})/
end
title, contents = nil
synonyms = Hash.new {|h,k| h[k]=[]}

IO.foreach(list) do |line|
  case line
  when /^=(.+?)\s+(.+)\s*/
    date, title = $~[1..2]
    contents = []
  when /^\s*$/
    keywords(synonyms, title, contents) unless contents.empty? || (filter && filter !~ title)
    contents.clear
  else
    contents << line.chomp
  end
end

synonyms.values.uniq.each do |line|
  puts line.join(',')
end
