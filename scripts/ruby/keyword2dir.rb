# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on April 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby keyword2dir.rb <list> <root>

    list : キーワードのリスト
    root : キーワードを階層的に配置するファイル群のルートディレクトリ名

=end

require 'fileutils'
require './serial'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

def url(root, title, timestamp, contents)
  timestamp = timestamp.to_time
  path = root + title
  dir  = path.split('/')[0..-2].join('/')
  FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
  file = path +'.txt'
  open(file, 'w') do |url|
    contents.each do |content|
      url.puts content
    end
  end
  File::utime(timestamp, timestamp, file)
end

list, root = ARGV
root += '/'
title, timestamp, contents = nil

IO.foreach(list) do |line|
  case line
  when /^=(.+?)\s+(.+)\s*/
    date, title = $~[1..2]
    timestamp = When.when?(date)
    contents = []
  when /^\s*$/
    url(root, title, timestamp, contents) unless contents.empty?
    contents.clear
  else
    contents << line.chomp
  end
end
