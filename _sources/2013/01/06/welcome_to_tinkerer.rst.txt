Welcome to Tinkerer
===================

あけおめ！

そんなアレで\ `はてなダイアリー <http://d.hatena.ne.jp/backpaper0/>`_\ から乗り換える何かを模索中なのです。
`Tinkerer <http://tinkerer.me/>`_\ というSphinxでブログが書ける拡張を見つけたので何となく使ってみようかと。
このエントリではインストールからbackpaper0.github.comでの公開までの手順を適当に書きます。
なお、エントリのタイトルは\ `ウェルカム・トゥ・オクトプレス <http://shizone.github.com/blog/2012/12/15/uerukamutouokutopuresu/>`_\ をパクったです。


Tinkererをインストールする
---------------------------------

easy_installで一発ですよ奥さん。

.. sourcecode:: sh

    easy_install -U Tinkerer

セットアップする
----------------------------

適当にディレクトリ作ってからtinker -sします。

.. sourcecode:: sh

    mkdir blog
    cd blog
    tinker -s

conf.pyが作成されるのでブログの名前とか設定します。

記事を書く
----------------------

エントリ作ります。

.. sourcecode:: sh

    tinker -p "Welcome to Tinkerer"

日付を表すディレクトリに続きエントリのrstファイルが作成されますのでこれを編集します。

ビルドする
------------------------

.. sourcecode:: sh

    tinker -b

blog/htmlディレクトリにもろもろ出力されます。

公開する
---------------------

blog/html以下をbackpaper0.github.comにプッシュします。
まあぶっちゃけこれからやることなのでこの記事書いてる段階ではそれで良いのか分かりませんが。

まとめ
-----------------------

* rstで書けるから嬉しい
* Sphinx好きなので嬉しい
* なんか探すときはgrep出来るから嬉しい
* Tinkerer簡単そうで嬉しい

という感じでしばらく使ってみようと思います。

.. author:: default
.. categories:: none
.. tags:: Sphinx,Tinkerer
.. comments::
