# -*- coding: utf-8 -*-
=begin
  Copyright (C) 2016-2017 Takashi SUGA

  You may use and/or modify this file according to the license
  described in the LICENSE.txt file included in this archive.

  Usage:

    ruby timestamp.rb <root>

    root   : インターネットショートカットを階層的に配置したファイル群のルートディレクトリ名

=end

require 'open-uri'
require 'openssl'
require 'open_uri_redirections'
require 'fileutils'
require 'when_exe'
require 'when_exe/core/extension'

Encoding.default_external = 'UTF-8'
Encoding.default_internal = 'UTF-8'

def crawl(shortcut_path, timestamp, url)
  shortcut_timestamp = timestamp.to_time
  source_timestamp = nil
  contents_path = shortcut_path.sub('/', '.timestamped/')
  contents_path.sub!(/\.(url|website)$/i, url =~ /\.pdf(#.+)?$/i ? '.pdf' : '.html')
  dir = contents_path.split('/')[0..-2].join('/')
  FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
  unless File.exist?(contents_path)
    begin
      puts contents_path
      open(url.sub(/#[^#]*$/,''), contents_path =~ /\.pdf$/ ? 'rb' :  'r:ascii-8bit' ,{:allow_redirections =>:all, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE}) do |source|
        open(contents_path, contents_path =~ /\.pdf$/ ? 'wb' :  'w:utf-8') do |crawled|
          contents = source.read
          /content="text\/html; *charset=(.+?)"|charset="(.+?)"/i =~ contents
          if $1
            encoding = $1
            contents.sub!(/content="text\/html; *charset=(.+?)"/i, 'content="text/html; charset=utf-8"')
          elsif $2
            encoding = $2
            contents.sub!(/charset="(.+?)"/i, 'charset="utf-8"')
          end
          contents.force_encoding(encoding)
          source_timestamp = get_source_timestamp(contents, url, shortcut_timestamp)
          timestamp = source_timestamp || shortcut_timestamp
          crawled.write(contents)
        end
      end
      p [shortcut_path, shortcut_timestamp, source_timestamp]
      File::utime(timestamp, timestamp, shortcut_path)
      File::utime(timestamp, timestamp, contents_path)
    rescue => e
      STDERR.puts e
      File.delete(contents_path) if File.exist?(contents_path)
    end
  end
end

def get_source_timestamp(contents, url, shortcut_timestamp)
  rexp, format = 
    case url
    when /qiita\.com/          ; [/<time datetime="(.+?)".+?"date(Published|Modified)" ?>/   , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /itmedia\.co\.jp/     ; [/<span id="update">(.+?) [^ ]+?<\/span>/                   , '%Y年%m月%d日 %H時%M分'   ]
    when /zdnet\.com/          ; [/<p class="author">.+?([^ ]+? [^ ]+?)<\/p>/m               , '%Y年%m月%d日 %H時%M分'   ]
    when /atmarkit\.co\.jp/    ; [/<span id="update">(.+?) [^ ]+?<\/span>/                   , '%Y年%m月%d日 %H時%M分'   ]
    when /nikkeibp\.co\.jp/    ; [/<span class="date">(.+?)<\/span>/                         , '%Y/%m/%d'                ]
    when /nikkei\.com/         ; [/<dd class="cmnc-publish">(.+?)<\/dd>/                     , '%Y/%m/%d %H:%M'          ]
    when /cnet\.com/           ; [/<meta name="DC.date.issued" content="(.+?)"/              , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /techcrunch\.com/     ; [/<meta name="sailthru.date" content="(.+?)"/               , '%Y-%m-%d %H:%M:%S'       ]
    when /hatenablog\.com/     ; [/<time pubdate datetime="(.+?)"/                           , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /impress\.co\.jp/     ; [/<meta name="creation_date" content="(.+?)"/               , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /impressbm\.co\.jp/   ; [/<span>(\d{4}年\d{1,2}月\d{1,2}日).{3}<\/span>/            , '%Y年%m月%d日'            ]
    when /ascii\.jp/           ; [/<p class="date">([^ ]+? [^ ]+?)..<\/p>/                   , '%Y年%m月%d日 %H時%M分'   ]
    when /wired\.jp/           ; [/<time datetime="(.+?)"/                                   , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /gigazine\.net/       ; [/<time datetime="(.+?)"/                                   , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /prtimes\.jp/         ; [/<time class="time .+?" datetime="(.+?)"/                  , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /roboteer-tokyo\.com/ ; [/<div class="date_top">Posted date:(.+?)<\/div>/           , '%Y.%m.%d'                ]
    when /robotstart\.info/    ; [/<span class="entry-date">(.+?)<\/span>/                   , '%Y年%m月%d日'            ]
    when /slideshare\.net/     ; [/<meta content="(.+?)".+?"slideshow_updated_at" ?\/>/      , '%Y-%m-%d %H:%M:%S %z'    ]
    when /eetimes\.jp/         ; [/<meta name="build" content="(.+?)">/                      , '%Y年%m月%d日 %H時%M分'   ]
    when /newswitch\.jp/       ; [/<meta name="pubdate" content=".....(.+?)">/               , '%d %B %Y %H:%M:%S %z'    ]
    when /news\.mynavi\.jp/    ; [/<meta name="date" content="(.+?)"/                        , '%Y-%m-%d'                ]
    when /bita\.jp/            ; [/<meta property="article:published_time" content="(.+?)"/  , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /hatena\.ne\.jp/      ; [/<span class="date">(.+?)<\/span>/                         , '%Y-%m-%d'                ]
    when /dotnsf\.blog\.jp/    ; [/<time datetime="(.+?)".+?"pubdate" ?>/                    , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /engadget\.com/       ; [/<meta name="pubdate" content=".....(.+?)">/               , '%d %B %Y %H:%M:%S %z'    ]
    when /www\.sbbit\.jp/      ; [/<div class="date">.+?LabelShowDate">(.+?)<\/span><\/div>/ , '%Y年%m月%d日'            ]
    when /ainow\.ai/           ; [/<meta property="article:modified_time" content="(.+?)"/   , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /livedoor\.com/       ; [/<time .+?datePublished.+? content="(.+?)" ?>/             , '%Y-%m-%d %H:%M:%S'       ]
    when /thebridge\.jp/       ; [/<meta property="article:modified_time" content="(.+?)"/   , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /wirelesswire\.jp/    ; [/Updated by <a.+?\/a> on (.+?)<\/p>/                       , '%m月 %d, %Y, %I:%M %p %z']
    when /gunosy\.com/         ; [/<li class="article_header_lead_date" content="(.+?)"/     , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /www\.sankeibiz\.jp/  ; [/<span id="__r_publish_date__">(.+?)<\/span>/              , '%Y.%m.%d %H:%M'          ]
    when /www\.gizmodo\.jp/    ; [/<meta property="article:modified_time" content="(.+?)"/   , '%Y-%m-%dT%H:%M:%S.000%z' ]
    when /codezine\.jp/        ; [/<meta name=".+?publishtime" content="(.+?)">/             , '%Y-%m-%dT%H:%M:%S%z'     ]
    when /asahi\.com/          ; [/<meta name="pubdate" content="(.+?)"/                     , '%Y-%m-%d %H:%M:%S%z'     ]
    when /www\.zaikei\.co\.jp/ ; [/<p class="fr">([^ ]+? [^ ]+?)<\/p>/                       , '%Y-%m-%d %H:%M:%S'       ]
    else
      return nil unless /(201[0-9])[-\/]?([0-9]{1,2})[-\/]?([0-9]{1,2})/ =~ url
      return DateTime.strptime("#{$1}-#{$2}-#{$3}T#{shortcut_timestamp.hour}:#{shortcut_timestamp.min}:#{shortcut_timestamp.sec}+09:00",
                               '%Y-%m-%dT%H:%M:%S%z').to_time
    end
  rexp =~ contents.encode('utf-8')
  return nil unless $1
  date = $1
  unless format =~ /%z/i
    date   += ' +09:00'
    format += ' %z'
  end
  DateTime.strptime(date, format).to_time
end

root, filter = ARGV
root ||= 'today'
root  += '/'
=begin
ex = []
IO.foreach(filter || 'computer.filter.txt') do |line|
  ex << line.chomp.gsub("/", "\\/")
end
filter = /^(#{ex.join('|')})/
=end

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
      end
    rescue ArgumentError
    end
  end
  raise ArgementError, "#{path} is empty" if contents.empty?
  crawl(path, timestamp, url)
end
