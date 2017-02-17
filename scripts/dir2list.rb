# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on February 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby dir2list.rb <root> (<filter>) > <list>

    root   : Path name of the tree root directory
    filter : Path Matcing filter
    list   : Path name of the internet shortcut list file
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
  next unless path =~ /^(.+)\.(url|website)$/i
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
    begin
      case line
      when /^URL/ #, /^IconFile/
        contents << line
      when /^Modified=([0-9A-F]+)/i
        timestamp = (serial2date(serial) + (PT1S * 0.5)).floor(SECOND)
      end
    rescue ArgumentError
    end
  end
  raise ArgementError, "#{path} is empty" if contents.empty?
  important = title.sub!(/\/★/, '/')
  puts '=%s %s' % [timestamp.to_s, title]
  puts contents
  puts
end
