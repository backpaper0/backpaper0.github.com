Spring Bootキャンプをやった #kanjava_sbc
================================================================================

`@making <https://twitter.com/making>`_ さんを講師にお迎えしてSpring Bootを土台にしてプログラミングを楽しむハンズオンを開催しました。

* `【脱初心者】Spring Bootキャンプ【ハンズオン】 - connpass <http://kanjava.connpass.com/event/11579/>`_
* `Spring Bootキャンプ ハンズオン資料 <http://spring-boot-camp.readthedocs.org/ja/latest/index.html>`_
* `はじめてのSpring Boot <http://bit.ly/hajiboot>`_

会場は楽天株式会社大阪支社のカフェテリアをお借り致しました。
`@bufferings <https://twitter.com/bufferings>`_ さん、ご協力ありがとうございました。

今回のハンズオンではカメラで撮った写真をSpring MVCに投げてOpenCVで画像変換をしました。
変換部分はJMSで非同期処理しクライアントとサーバー間はSTOMPというプロトコルをWebSocket上で利用して通信しました。

**Spring Bootの関係無さ感すごい！！！**

しかし、このように色々な技術を使ったWebサービスのハンズオンを特にややこしい設定もせず
約2時間半で進める事ができたのはいろいろと自動で設定を宜しくやってくれるSpring Bootがあってこそだと思いました。

楽しいハンズオンを行って頂いて@makingさんには本当に感謝です！！！

.. figure:: /images/spring-boot-camp.*
   :alt: ハンズオンの様子

ちなみに
--------------------------------------------------------------------------------

東京でも開催されるっぽいですよ！

.. raw:: html

   <blockquote class="twitter-tweet" lang="ja"><p>あ、Spring Bootキャンプ、3/25に東京でもやります。イベントページまだか・・・</p>&mdash; Toshiaki Maki (@making) <a href="https://twitter.com/making/status/574104291717177344">2015, 3月 7</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

おまけ
--------------------------------------------------------------------------------

Spring Boot + Jersey。
懇親会で話題に出たやつです。
前にちょこっとやりました。

* :doc:`/2015/01/14/spring_boot_jersey`

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot
.. comments::
