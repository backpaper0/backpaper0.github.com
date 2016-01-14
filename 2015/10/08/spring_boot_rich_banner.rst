Spring Bootでカラフルなバナーを表示してみた   
==================================================

.. raw:: html

   <blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">gradle build&#10;java -jar build/libs/spring-boot-rich-banner-sample.jar&#10;ではじぶーと&#10;<a href="https://t.co/Z0kQb1fUGR">https://t.co/Z0kQb1fUGR</a> <a href="http://t.co/8wWuHiJwM6">pic.twitter.com/8wWuHiJwM6</a></p>&mdash; うらがみ (@backpaper0) <a href="https://twitter.com/backpaper0/status/651745561658265601">2015, 10月 7</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

というわけでカラフルなバナーを表示するBannerクラスを書いてみました。

どうやってんのか
--------------------------------------------------

ターミナルの背景色を変更してスペースを2つ出力、を繰り返して絵を描いています。
スペースを2つ出力することで正方形になって良い感じにドット絵っぽくなります。

背景色を変えるには

.. sourcecode:: none

   ESC + '[48;05;' + 色のインデックス + 'm'

で出来ます。

次のGroovyコマンドを試してみてください。

.. sourcecode:: sh

   groovy -e "System.out.write(0x1b);println('[48;05;20mHello, World!')"

背景色を元に戻すには

.. sourcecode:: none

   ESC + '[0m'

です。

それから、元画像はターミナルで出力できる色だけで構成されているわけではないので、
元画像から1ピクセルずつ色を読み込んでターミナルで出力できる256色の中から近い色を探して出力しています。

2つの色がどの程度近いかはカラーコードを三次元の座標に見立てて2つの色間の距離を求めて一番近いものを選んでいます。

.. sourcecode:: java

   int r = ((rgb1 >> 16) & 0xff) - ((rgb2 >> 16) & 0xff);
   int g = ((rgb1 >> 8) & 0xff) - ((rgb2 >> 8) & 0xff);
   int b = (rgb1 & 0xff) - (rgb2 & 0xff);
   return (int) Math.sqrt(r * r + g * g + b * b);

概ねこんな感じです。

いろいろブート
--------------------------------------------------

うらがみブート。

.. image:: /images/uragami-boot.png

いろふブート。

.. image:: /images/irof-boot.png

ちむブートﾍﾟﾛﾍﾟﾛ（＾ω＾）

.. image:: /images/syobochim-boot-peropero.png

こざブート✌️( ・ㅂ・)و🍺 

.. image:: /images/kozaboot.png

ブートくしーさん。

.. image:: /images/bootksy.png

やんくブート:q!

.. image:: /images/yank-boot_q.png

ソースコード
--------------------------------------------------

* https://github.com/backpaper0/spring-boot-rich-banner-sample

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot
.. comments::
