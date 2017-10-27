# -*- coding: utf-8 -*-
=begin
  Copyright (C) 2016-2017 Takashi SUGA

  You may use and/or modify this file according to the license
  described in the LICENSE.txt file included in this archive.

  Usage:

    ruby pickup_keywords.rb (<root>) (<filter>) (<today>)

    root   : インターネットショートカットを階層的に配置したファイル群のルートディレクトリ名
    filter : リスト化するディレクトリのリスト(省略すると全ディレクトリをリスト化)
    today  : 本日収集分のショートカットを配置したディレクトリ

=end

require 'pp'
require 'json'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

root, filter, today = ARGV
today ||= 'today'
root  ||= 'bookmarks'
today  += '/'
root   += '/'
ex = []
IO.foreach(filter || 'computer.filter.txt') do |line|
  ex << line.chomp.gsub("/", "\\/")
end
filter = /^(#{ex.join('|')})/

KeywordHash = {}

# ディレクトリ名
Dir.glob(root + '**/') do |path|
  title = path.gsub(/%7f/i, '%7E').sub(root, '')
  next if filter && filter !~ title
  words = title.split('/')
  words.each_with_index do |word,index|
    (word =~ /^[a-z ・]+$/i ? word.split('・') : [word]).each do |item|
      KeywordHash[item] = words[0..index].join('/') + '/'
    end
  end
end

# キーワード・ファイル
Dir.glob(root + '**/*.*') do |path|
  next unless path =~ /^(.+)\.txt$/i
  title = $1.gsub(/%7f/i, '%7E').sub(root, '').sub(/\/[^\/]+$/,'/')
  next if filter && filter !~ title
  IO.foreach(path) do |line|
    words = line.chomp.split(',')
    case KeywordHash[words.first]
    when Array  ; KeywordHash[words.first] << title unless KeywordHash[words.first].include?(title)
    when String ; KeywordHash[words.first] = [KeywordHash[words.first], title] unless KeywordHash[words.first] == title
    else KeywordHash[words.first] = title
    end
    (1...words.length).each do |index|
      KeywordHash[words[index]] = words.first
    end
  end
end

open('keywords.json', 'w') do |json|
  json.write(JSON.generate(KeywordHash))
end

pickup_rex = /(#{KeywordHash.keys.sort_by {|keyword| -keyword.length}.map {|keyword|
  keyword =~ /^[a-z0-9 ]+$/i ? "(?<![a-zA-Z0-9])#{keyword}(?![a-zA-Z0-9])" : 
  keyword =~ /\+/            ? keyword.gsub('+', "\\\\+") :
  keyword
}.join('|')})/

# ショートカット・ファイル
open(today + 'list.txt', 'w') do |list|
  Dir.glob(today + '**/*.*') do |path|
    next unless path =~ /^(.+)\.(url|website)$/i
    pickuped = []
    (' ' + $1.sub(today, '').tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z') + ' ').scan(pickup_rex) do |match|
      pickuped << $1
    end
    list.puts path.sub(today, '')
    IO.read(path).each_line do |line|
      if line =~ /^url=(.+)$/i
        list.puts $1
        break
      end
    end
    pickuped.uniq.each do |key|
      dir = KeywordHash[key]
      next unless dir
      dir = KeywordHash[dir] if dir.kind_of?(String) && dir !~ /\/$/
      dir = [dir] if dir.kind_of?(String)
      list.puts "  #{key}(#{dir.join(',')})"
    end
    list.puts
  end
end
