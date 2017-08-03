gensim の Doc2Vec を使ってみる
==============================

# まえがき

本記事は[Webページの要約(前処理)](http://qiita.com/suchowan/items/185446a194a127acb7b8)の続きです。

前回の記事で生成したプレーンテキストは [LexRank](http://qiita.com/search?q=LexRank)などを使って要約できるはずです。

LexRank は文の類似度を何らかの方法で計算し、その類似度に基づいた類似マトリクスの固有値を計算するものです。ここで用いる文の類似度は、各文を分散表現(ベクトル表現)で表し、文どうしのベクトルの内積を類似度とするのが一般的です。よって、課題の中心は文の分散表現(ベクトル表現)を求めることに帰着します。

幸い、過去に[機械学習関連情報をトピックモデルで分類する](http://qiita.com/suchowan/items/a4231d1c63c835ae88e2)の記事で利用した [gensim](https://radimrehurek.com/gensim/index.html) には [Doc2Vec](https://radimrehurek.com/gensim/models/doc2vec.html) モジュールがあるので、このモジュールを使って文のベクトル表現を求めることを考えました。ネットを検索したところズバリの

　[Doc2Vecの仕組みとgensimを使った文書類似度算出チュートリアル](https://deepage.net/machine_learning/2017/01/08/doc2vec.html)

という記事があったので、それに従ってチュートリアルをやってみたのが下記の記事です。

あまりうまくいかなかったので、いったん整理して公開し、みなさんのお知恵を拝借したいです。

# チュートリアル記事との差分

## JUMAN++ のインストール

JUMAN++ のインストールに関して注意点が２つありました。

・boost のバージョン

CentOS 7 で yum install boost-devel でインストールしたところ boost のバージョンが 1.53 になってしまいました。
boost のバージョンは 1.57 以上でなければならないようなので、

$ wget https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz

で直接ソースをとりよせて make することになりました。

・JUMAN を先にインストールしておく

JUMAN の環境なしで、全く素の環境に JUMAN++ をインストールしようとするとファイルが足りません。
JUMAN++ の前に JUMAN をインストールしなければなりませんでした。JUMAN を以前から使っていると気づきにくいのかもしれません。

## LabeledSentence が deprecated

LabeledSentence はすでに deprecated になっていて、TaggedDocument を使うべきとのこと
( https://stackoverflow.com/questions/41182372/what-is-the-difference-between-gensim-labeledsentence-and-taggeddocument )

このため、

```change_1.py
from gensim.models.doc2vec import TaggedDocument
　…
def doc_to_sentence(doc, name):
    words = split_into_words(doc)
    return TaggedDocument(words=words, tags=[name])
```
のように修正しました。

なお、split_into_words.py に関して、本記事の末尾もご覧ください。

# 前準備と学習

gensim の Doc2Vec が若干新しくなっているようなので、直接[オリジナルのチュートリアル](https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/doc2vec-lee.ipynb)を参照して前準備と学習を書き直してみます。

```change_2.py
corpus = corpus_files()
sentences = list(corpus_to_sentences(corpus))
model = models.doc2vec.Doc2Vec(dm=0, size=300, window=15, min_count=1, sample=1e-6, iter=50)
#model = models.doc2vec.Doc2Vec(dm=0, size=50, window=5, min_count=5, sample=0.001, iter=50)
model.build_vocab(sentences)
model.train(sentences, total_examples=model.corpus_count)
```
corpus_to_sentences() は generator を返すので、いったん list 化しておかないと train に渡す際に空になってしまいます。
また model.alpha による制御は不要で train の内部処理で自動的に実行されるようです。

# 計算結果の安定性

実際に動作させてみると計算結果[^1]が試行のたびに大きく異なります。
原因のひとつは…

## マルチスレッドで乱数使用

マルチスレッドで乱数使用しているため、当然結果は試行のたびに異なります。
試行のたびに同じ結果が得られるようにするには、 doc2vec.Doc2Vec() に、

・seed を指定し乱数系列を同じにする
・workers に 1 を指定してシングルスレッドで動くようにする

と引数を加え、さらに、環境変数 PYTHONHASHSEED に整数を設定して、
dictionary が毎回同じ動作をするよう指定する
$ export PYTHONHASHSEED=1 

というような設定が必要です。

ただ、このようにして強制的に結果を安定させても、無意味な同じ結果が毎回得られるだけでは何の解決にもなりません。

## パラメータチューニング

結果が試行のたびに異なるのは予想範囲内だったのですが、実用にならないほど大きく異なるのは予想していませんでした。

一方、change_2.py でコメントアウトした設定は gensim の API ドキュメントのデフォルト設定により近い設定ですが、こちらの設定では実用になりそうなかなり安定した結果が得られました。

今回サンプルデータとして用いたlivedoorのニュースコーパスは記事数が7376です。これは深層学習用の入力としては極めて少ない。
それに見合ったパラメータにしないと[機械学習関連情報をトピックモデルで分類する](http://qiita.com/suchowan/items/a4231d1c63c835ae88e2)の記事で遭遇したような過学習に陥る危険性大です。

そこで、いろいろパラメータを変えて試してみました。

```
 size=30  window=5  min_count=5 sample=1e-06 similarity=0.00455856036959
 size=30  window=5  min_count=5 sample=1e-06 similarity=0.11694597141
 size=30  window=5  min_count=5 sample=1e-06 similarity=0.00455856036959
 size=30  window=5  min_count=5 sample=1e-06 similarity=0.11694597141
 size=30  window=5  min_count=1 sample=0.001 similarity=0.203533835887
 size=30  window=5  min_count=1 sample=0.001 similarity=0.0568778378648
 size=30  window=5  min_count=1 sample=0.001 similarity=0.371243619894
 size=30  window=5  min_count=1 sample=0.001 similarity=0.426766233493
 size=30  window=5  min_count=1 sample=0.001 similarity=0.0630503422875
 size=30  window=5  min_count=1 sample=0.001 similarity=0.991242216992
 size=30  window=15 min_count=5 sample=0.001 similarity=0.955971033493
 size=30  window=15 min_count=5 sample=0.001 similarity=0.757559076547
 size=30  window=15 min_count=5 sample=0.001 similarity=0.947070037318
 size=30  window=5  min_count=5 sample=0.001 similarity=0.652621149416
 size=30  window=5  min_count=5 sample=0.001 similarity=0.948618570471
 size=30  window=5  min_count=5 sample=0.001 similarity=0.913108892467
 size=30  window=5  min_count=5 sample=0.001 similarity=0.923383332441
 size=30  window=5  min_count=5 sample=0.001 similarity=0.924401776779
 size=50  window=5  min_count=5 sample=0.001 similarity=0.795427517489
 size=50  window=5  min_count=5 sample=0.001 similarity=0.965550682187
 size=50  window=5  min_count=5 sample=0.001 similarity=0.962536489977
 size=50  window=5  min_count=5 sample=0.001 similarity=0.88420856083
 size=50  window=5  min_count=5 sample=0.001 similarity=0.97271249018
 size=300 window=5  min_count=5 sample=0.001 similarity=0.883629869438
 size=300 window=5  min_count=5 sample=0.001 similarity=0.992705994569
 size=300 window=5  min_count=5 sample=0.001 similarity=0.901168443902
 size=300 window=5  min_count=5 sample=0.001 similarity=0.988943363089
 size=300 window=5  min_count=5 sample=0.001 similarity=0.96558727992
 size=300 window=5  min_count=5 sample=0.001 similarity=0.993270177258
 size=300 window=5  min_count=5 sample=0.001 similarity=0.993654159632
 size=300 window=5  min_count=5 sample=0.001 similarity=0.986381854722
```

[API ドキュメント](https://radimrehurek.com/gensim/models/word2vec.html#gensim.models.word2vec.Word2Vec) によれば、sample=1e-6 はuseful range 外、また min_count=1 にすると頻度 1 の単語まで評価に用いることになってノイズが大きくなりすぎます。
これらはある程度パラメータチューニングの見通しがあります。

しかし Doc2Vec の API を見る限り LdaModel の perplexity にあたるようなものが見つからず、その他のパラメータの妥当性をプログラムで判断するのは困難に感じられます。
データ量が少ないのでベクトルの次元数を小さくすれば良いかというと必ずしもそうとも言い切れない。

TensorFlow などを直接使っていれば途中経過を可視化するなどが柔軟にできますが、gensim から呼ぶと処理全体がブラックボックスになってしまうのが気になるところです。

# まとめ(になっていない)

教師データのサンプル数がこれくらい、出現する単語の異なり語数がこれくらいなどというシチュエーションから、であればパラメータはこれくらいにチューニングするべきというような“土地鑑”がノウハウとしてわかっていないとうまくいかないという(悪い)実例になったのではないかと思います。

ちょうど[ベイズ最適化とグリッドサーチの比較](http://qiita.com/koji-murakami/items/b7887f1cef11ddc443a4)などの記事が掲載されていますが、そういった試みをすべきなのかな？
でもそのためにも“上手くいっている度合い”をあらわすメトリックが必要です。

と、ここまで調べたところで

```split_into_words.py
def split_into_words(text):
    result = Jumanpp().analysis(text)
    return [mrph.midasi for mrph in result.mrph_list()]
```

の処理の中の Jumanpp().analysis() が text が複数行からなる場合に、最初の１行しか処理しないで返ってきていることに気付きました。

結果、各投稿の最初の１行(URLを示す行)しか処理していなかった。これでは投稿の内容の類似性を判断できるはずがありません。まさかこんな基本的なところに問題があったとは…

ということで、この記事全体が没になって、調査は仕切り直しとなりました。

[^1]: model.docvecs.similarity('./text/livedoor-homme/livedoor-homme-4700669.txt', './text/movie-enter/movie-enter-5947726.txt') で記事の類似度を計算しています。

