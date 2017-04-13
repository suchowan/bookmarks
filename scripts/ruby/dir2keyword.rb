# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on April 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby dir2keyword.rb <root> (<filter>) > <list>

    root   : インターネットショートカットを階層的に配置したファイル群のルートディレクトリ名
    filter : リスト化するディレクトリのリスト(省略すると全ディレクトリをリスト化)
    list   : キーワードのリスト

=end

require './serial'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

root, filter = ARGV
root += '/'
if filter
  ex = []
  IO.foreach(filter) do |line|
    ex << line.chomp.gsub("/", "\\/")
  end
  filter = /^(#{ex.join('|')})/
end

Dir.glob(root + '**/*.*') do |path|
  next unless path =~ /^(.+)\.txt$/i
  title     = $1.gsub(/%7f/i, '%7E').sub(root, '')
  next if filter && filter !~ title
  timestamp =
   begin
     File.stat(path).mtime.to_tm_pos.floor(SECOND)
   rescue => e
     STDERR.puts e
     next
   end
  contents  = []
  IO.foreach(path) do |line|
    contents << line
  end
  raise ArgementError, "#{path} is empty" if contents.empty?
  puts '=%s %s' % [timestamp.to_s.sub(/\+09:00:00$/,'+09:00'), title]
  puts contents
  puts
end
