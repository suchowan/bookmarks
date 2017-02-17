# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on February 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby list2dir.rb <list> <root>

    list : Path name of the internet shortcut list file
    root : Path name of the tree root directory

=end

require 'fileutils'
require './serial'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

def url(root, title, importance, timestamp, contents)
  title.sub!(/([^\/]+)$/, '★\1') if importance == '+'
  timestamp = timestamp.to_time
  path = root + title
  dir  = path.split('/')[0..-2].join('/')
  FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
  file = path +'.url'
  open(file, 'w') do |url|
    url.puts('[InternetShortcut]')
    contents.each do |content|
      url.puts content
    end
  end
  File::utime(timestamp, timestamp, file)
end

list, root = ARGV
root += '/'
title, importance, timestamp, contents = nil

IO.foreach(list) do |line|
  case line
  when /^([-+=])(.+?)\s+(.+)\s*/
    importance, date, title = $~[1..3]
    timestamp = When.when?(date)
    contents = []
  when /^Modified=(.+)$/
    contents << line.chomp
    timestamp = serial2date($1)
  when /^\s*$/
    url(root, title, importance, timestamp, contents) unless contents.empty?
    contents.clear
  else
    contents << line.chomp
  end
end
