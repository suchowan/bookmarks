# -*- coding: utf-8 -*-
=begin
  Copyright (C) 2016-2017 Takashi SUGA

  You may use and/or modify this file according to the license
  described in the LICENSE.txt file included in this archive.

  Usage:

    ruby copy_url.rb (<root>) (<today>)

    root   : インターネットショートカットを階層的に配置したファイル群のルートディレクトリ名
    today  : 本日収集分のショートカットを配置したディレクトリ

=end

require 'pp'
require 'fileutils'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

root, filter, today = ARGV
today ||= 'today'
root  ||= 'bookmarks'
today  += '/'
root   += '/'

contents = {'category'=>[]}
IO.read(today + 'list.txt').each_line do |line|
  case line
  when /^  .*\((.+?)\)/
    contents['category'] += $1.split(/ *, */).map {|category| root + category[0...-1]}
  when /^$/
    pp contents
    contents['category'].each do |category|
      FileUtils.mkdir_p(category) unless FileTest.exist?(category)
      FileUtils.cp(contents['path'], category, :preserve=>true)
    end
    contents = {'category'=>[]}
  when /^http/
  else
    contents['path'] = today + line.chomp
  end
end

