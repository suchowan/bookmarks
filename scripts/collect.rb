# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on February 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.

  Usage:

    ruby collect.rb (<period>) (<collected>) (<excluded>) > <new links>

    pediod    : Collection period / day (default : 1)
    collected : Path name of the collected internet shortcut list file (default : ../bookmarks/computer.url.txt)
    excluded  : Path name of the excluded internet shortcut list file (default : non)
    new links : Collected links (HTML format)
=end

require 'cgi'
require 'open-uri'
require 'openssl'
require 'fileutils'
require './serial'

include When

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

URL              = 'http://hosi.org:8090/search/next/?q=%s&pn=%d&num=20&ex_q=timestamp%%3A[now%%2Fd-%dd+TO+*]'
KEYS             = %w(人工知能 機械学習 AI)
SIMILARITY_LIMIT = 15

HTML = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>New Links</title>
</head>
<body>
%s
</body>
</html>
HTML

def match_length(str1, str2)
  len = [str1.length,str2.length].min
  (0...len).each do |i|
    return i unless str1[i] == str2[i]
  end
  return len
end

def similarity(title, list)
  index = (0...list.size).bsearch {|i| list[i] >= title }
  return 0 unless index
  ([index-1,0].max..index).map {|i|
    match_length(title,list[i])
  }.max
end

def crawled(list)
  return {} unless list
  links = {}
  title, importance, timestamp, contents = nil
  open(list, 'r', &:read).each_line do |line|
    case line.chomp
    when /^([-+=])(.+?)\s+(.+)\s*/
      importance, date, title = $~[1..3]
      timestamp = when?(date)
      contents = []
    when /^Modified=(.+)$/
      contents << line.chomp
      timestamp = serial2date($1)
    when /^\s*$/
      links[contents.first[/[a-z].+/]] = [title, timestamp.to_s.sub('+09:00','')] unless contents.empty?
      contents = []
    else
      contents << line.chomp
    end
  end
  links
end

def crawl(days, registered, exclude=true)
  titles = registered.values.map {|value| value.first}.sort
  links  = {}
  KEYS.each do |key|
    page = 0
    loop do
      fess  = URL % [CGI.escape(key), page, days]
      STDERR.puts '%s (%d)' % [key, page+1]
      sleep(1)
      count = 0
      open(fess, 'r:utf-8') do |source|
        url = contents = nil
        source.read.gsub("\n",'').scan(/data-uri="(.+?)"|data-order="(\d+?)">(.+?)<\/a>|([a-z]{3}\s+[a-z]{3}\s+\d{1,2}\s+\d{1,2}:\d{2}:\d{2}\s+JST\s+\d{4})/i) do
          case
          when $1
            url = $1
          when $2
            contents = [$3]
            count = $2.to_i
          when $4
            contents << DateTime::parse($4).to_s.sub('+09:00','')
            excluded = 
              registered.key?(url) ||
              url.index('https://ja.wikipedia.org/')     ||
              url.index('http://qa.itmedia.co.jp/')      ||
              url.index('http://www.itmedia.co.jp/qa')   ||
             (url.index('http://www.itmedia.co.jp/') &&  url.index('keyword')) ||
             (url.index('http://qiita.com/')         &&  url.index('tags'))    ||
             (url.index('http://qiita.com/')         && !url.index('item'))    ||
              url.index('http://kanae-ito-yui.blog.jp/') ||
              url.index('http://ncode.syosetu.com/')     ||
              similarity(contents.first, titles) > SIMILARITY_LIMIT
            if exclude == !excluded
              links[url] = contents
            end
          end
        end
      end
      if count < 19
        break
      else
        page += 1
      end
    end
  end
  links
end


registered = crawled(ARGV[1]||'../bookmarks/computer.url.txt').merge(crawled(ARGV[2]))

no = 0
puts HTML % (crawl((ARGV[0]||1).to_i, registered).sort_by {|k,v| v.first}.map { |article|
  no += 1
  "(#{'%03d' % no}) #{article[1][1]} <a href='#{article[0]}' target='_blank'>#{article[1][0]}</a>"
}.join("<br/>\n"))

