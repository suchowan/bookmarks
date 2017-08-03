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

