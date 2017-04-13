Takashi SUGA's personal bookmarks for computer and other special interest items
===============================================================================

本データは[須賀隆](http://hosi.org:3000/TakashiSuga.ttl)のブックマークのうち下記で利用するために公開する部分を抜き出したものです。

## 機械学習関連 - compueter.url.txt, computer.keywords.txt

[機械学習関連情報の収集と分類(構想)](http://qiita.com/suchowan/items/459062590f7134dfc138)のⒹに相当するブックマークとキーワードです。

![こんなふうにして作ったもの](https://qiita-image-store.s3.amazonaws.com/0/144985/95d8f8f2-831c-19b8-7c67-de2973a7b0f6.png)

## その他 - sig.url.txt

http://hosi.org:4000/bookmarks が参照しているブックマークです。

# フォーマット

[ショートカット・ディレクトリとプレインテキストの変換](http://qiita.com/suchowan/items/6556756d2e816c7255b7#3-%E3%82%B7%E3%83%A7%E3%83%BC%E3%83%88%E3%82%AB%E3%83%83%E3%83%88%E3%83%87%E3%82%A3%E3%83%AC%E3%82%AF%E3%83%88%E3%83%AA%E3%83%97%E3%83%AC%E3%82%A4%E3%83%B3%E3%83%86%E3%82%AD%E3%82%B9%E3%83%88)で説明しているフォーマットです。

但し、下記に留意してください。

・important か否かの区別はなく、常に各項目の冒頭は“=”です。

・タイムスタンプの日付部分は原則として当該記事の公開日、時刻部分は当該記事の採集時刻です。ただし、2016年5月6日～9日に、別のフォーマットから本フォーマットへの一括変換作業を実施したため、それ以前のものは、必ずしもこの原則に従っていません。

・リンクの説明は原則として当該記事の[題号](https://ja.wikibooks.org/wiki/%E8%91%97%E4%BD%9C%E6%A8%A9%E6%B3%95%E7%AC%AC20%E6%9D%A1)(HTMLの&lt;title/&gt;要素)ですが、利用したファイルシステムの制約により文字の置き換えや省略をしている場合があります。

・URL要素以外は公開する上で意味がないので省略しています。

・木構造はかなりいい加減です。同じ記事が複数のカテゴリに該当すると主観的に判断した場合、複数箇所に配置しています。

・リンク先の内容の保証はしませんし、リンク切れのメンテナンスもしていません。

・本情報の更新は不定期です。

# スクリプト

ブックマークファイルを扱う Ruby スクリプトを GitHub の [scripts/ruby](https://github.com/suchowan/bookmarks/tree/master/scripts/ruby) に置きました。

## list2dir.rb

プレインテキストのブックマークリストをショートカット・ディレクトリに展開します。

## dir2list.rb

ショートカット・ディレクトリからプレインテキストのブックマークリストを生成します。

## collect.rb

[FESSサーバ](http://hosi.org:8090)の収集結果とショートカット・ディレクトリの差分情報をリスト化します。

HTML としているのはブラウザの履歴機能を利用するためです。

## crawl.rb

ショートカット・ディレクトリの実体ファイルを収集します。

## keyword2dir.rb

プレインテキストのキーワードリストをキーワード・ディレクトリに展開します。

## dir2keyword.rb

キーワード・ディレクトリからプレインテキストのキーワードリストを生成します。

## merge_keywords.rb

プレインテキストのキーワードリストをマージして同義語辞書を生成します。

## 使用例

scripts ディレクトリに入ってスクリプトを実行すると、下記の例のような変換・データ収集ができます。

 $ ruby list2dir.rb ../../bookmarks/computer.url.txt ../../trees/bookmarks

../../bookmarks/computer.url.txt にしたがって、../../trees/bookmarks 配下に実際のショートカットファイルを階層的に配置します。

 $ ruby list2dir.rb ../../bookmarks/sig.url.txt ../../trees/bookmarks

../../bookmarks/sig.url.txt にしたがって、../../trees/bookmarks 配下に実際のショートカットファイルを階層的に配置します。

 $ ruby dir2list.rb ../../trees/bookmarks computer.filter.txt > comp.txt

../../trees/bookmarks 配下の実際のショートカットファイルから computer.filter.txt で指定した階層のショートカットを抽出し、computer.url.txt 相当のファイルを生成します。

 $ ruby dir2list.rb ../../trees/bookmarks sig.filter.txt > comp.txt

../../trees/bookmarks 配下の実際のショートカットファイルから sig.filter.txt で指定した階層のショートカットを抽出し、sig.url.txt 相当のファイルを生成します。

 $ ruby cellect.rb 3 ../../bookmarks/computer.url.txt > cellected.html

hosi.org:8090 で提供している FESS サーバから最近3日分の収集結果を取り出し、../../bookmarks/computer.url.txt に登録されている(か、またはタイトルが16字以上一致する)エントリを除外してリスト化します。

 $ ruby cellect.rb 3 ../../bookmarks/computer.url.txt ../../bookmarks/excludes.url.txt > cellected.html

hosi.org:8090 で提供している FESS サーバから最近3日分の収集結果を取り出し、../../bookmarks/computer.url.txt と ../../bookmarks/excludes.url.txt のどちらかに登録されている(か、またはタイトルが16字以上一致する)エントリを除外してリスト化します。

 $ ruby crawl.rb  ../../trees/bookmarks computer.filter.txt

../../trees/bookmarks 配下の実際のショートカットファイルから computer.filter.txt で指定した階層のショートカットを抽出し、その実体を収集して ../../trees/bookmarks.crawled 配下に置きます。

 $ ruby keyword2dir.rb ../../bookmarks/computer.keywords.txt ../../trees/bookmarks

../../bookmarks/computer.keywords.txt にしたがって、../../trees/bookmarks 配下に実際のキーワードファイルを階層的に配置します。

 $ ruby dir2keyword.rb ../../trees/bookmarks computer.filter.txt > keywords.txt

../../trees/bookmarks 配下の実際のキーワードファイルから computer.filter.txt で指定した階層のキーワードを抽出し、computer.keywords.txt 相当のファイルを生成します。

 $ ruby merge_keywords.rb ../../bookmarks/computer.keywords.txt computer.filter.txt > synonyms.txt

../../bookmarks/computer.keywords.txt にしたがって、computer.filter.txt で指定した階層のキーワードを抽出し、同義語辞書を生成します。

# LICENCE

  ブックマークファイルは CC0 1.0 Universal、スクリプトは MIT Licence です。


