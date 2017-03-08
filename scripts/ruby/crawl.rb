# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on February 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby crawl.rb <root> (<filter>)

    root   : Path name of the tree root directory
    filter : Path Matcing filter(default- computer.filter.txt)

=end

require 'open-uri'
require 'openssl'
require 'open_uri_redirections'
require 'fileutils'
require './serial'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

def crawl(path, timestamp, url)
  timestamp = timestamp.to_time
  path.sub!(/\/([^\/]+)$/, '.crawled/\1')
  path.sub!(/\.(url|website)$/i, url =~ /\.pdf(#.+)?$/i ? '.pdf' : '.html')
  dir = path.split('/')[0..-2].join('/')
  FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
  unless File.exist?(path)
    begin
      puts path
      open(url.sub(/#[^#]*$/,''), path =~ /\.pdf$/ ? 'rb' :  'r:utf-8' ,{:allow_redirections =>:all, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE}) do |source|
        open(path, path =~ /\.pdf$/ ? 'wb' :  'w:utf-8') do |crawled|
          crawled.write(source.read)
        end
      end
      File::utime(timestamp, timestamp, path)
    rescue => e
      STDERR.puts e
      File.delete(path) if File.exist?(path)
    end
  end
end

root, filter = ARGV
root += '/'
ex = []
IO.foreach(filter || 'computer.filter.txt') do |line|
  ex << line.chomp.gsub("/", "\\/")
end
filter = /^(#{ex.join('|')})/

Dir.glob(root + '**/*.*') do |path|
  next unless path =~ /^(.+)\.(url|website)$/i
  title     = $1.gsub(/%7f/i, '%7E').sub(root, '')
  next if filter && filter !~ title
  timestamp =
   begin
     File.stat(path).mtime.to_tm_pos
   rescue => e
     STDERR.puts e
     next
   end
  contents  = []
  url = nil
  IO.foreach(path) do |line|
    begin
      case line
      when /^URL=(.+)/, /^IconFile/
        contents << line
        url = $1 if $1
      when /^Modified=([0-9A-F]+)/i
        serial = $1
        serial = "200D7890BCA8D1016B" if serial == "208D47ED2189D0015C"
        contents << "Modified=#{serial}"
        timestamp = serial2date(serial)
      end
    rescue ArgumentError
    end
  end
  raise ArgementError, "#{path} is empty" if contents.empty?
  crawl(path, timestamp, url)
end
