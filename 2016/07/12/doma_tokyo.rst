東京でDoma勉強会やったぞ！！！ #doma_tokyo
==================================================

`Doma <http://doma.readthedocs.io/>`_
作者の
`中村さん <https://twitter.com/nakamura_to>`_
、
Domaヘビーユーザーの
`がくぞさん <https://twitter.com/gakuzzzz>`_
と一緒にDoma勉強会を東京で開催してきました！！！

* `【7/9(土)】Doma勉強会 in 東京 - dots. [ドッツ] <http://eventdots.jp/event/592052>`_

スライド
--------------------------------------------------

私のスライドはこちら。
2本、話させて頂きました。
Domaの主要な機能を私なりに紹介した発表と、ドメインクラスで型最高！という発表です。

* `Domaの紹介 </ghosts/doma-intro.html>`_
* `ドメインクラスの話 </ghosts/doma-domainclass.html>`_

がくぞさんのスライドはこちら。
collect検索の活用方法、なるほど感すごかったです。
真似させてもらいます！

* `とあるDoma2の使い方 <http://gakuzzzz.github.io/slides/doma_practice/>`_

そして、中村さんのスライドはこちら。
Doma開発のスタンス、我々ユーザーとの向き合い方に感動しました！！

* `Domaの開発で大切にしている10のこと <http://qiita.com/nakamura-to/items/099cf72f5465d0323521>`_

「LTやってよ！」ってさらっと無茶振りしたのに見事に応えてくれた
`多田さん <https://twitter.com/suke_masa>`_
と
`やんくさん <https://twitter.com/yy_yank>`_
もありがとうございました！

* `Doma2とMVC1.0でJava EE Webアプリを作ろう！ <https://speakerdeck.com/masatoshitada/doma2tomvc1-dot-0dejava-ee-webapuriwozuo-rou>`_
* `Doma2 with Kotlin <http://www.slideshare.net/yyyank/doma2-with-kotlin>`_

他の方々のブログ、Togetterなど
--------------------------------------------------

* `「Doma勉強会 in 東京」に行ってきました。 - シュンツのつまづき日記 <http://d.hatena.ne.jp/gloryof/20160709/1468060613>`_
* `Doma勉強会 in 東京に行ってきた #doma_tokyo - Splash of waters - 2nd. Season <http://jappy.hatenablog.com/entry/2016/07/09/193939>`_
* `【7/9(土)】Doma勉強会 in 東京でLTしてきました #doma_tokyo - Javaプログラマーのはしくれダイアリー <http://yyyank.blogspot.jp/2016/07/79doma-in-lt-domatokyo_96.html>`_
* `【7/9(土)】Doma勉強会 in 東京 - Togetterまとめ <http://togetter.com/li/997896>`_

TLへのリアクション
--------------------------------------------------

内容については、他の方々のブログにお任せするとして、ここからは当日のTLから幾つかのツイートをピックアップして、リアクションしたいと思います。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">どこかにテンプレート的なものがあるらしい? &gt; build.gradle <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a></p>&mdash; 寝起き (@nashcft) <a href="https://twitter.com/nashcft/status/751644660729204737">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

これです！

* https://github.com/domaframework/simple-boilerplate


.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Dialectって主にページネーションの方言を吸収するのか。offsetやらlimitやら。 <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; 多田真敏(MasatoshiTada) (@suke_masa) <a href="https://twitter.com/suke_masa/status/751644728270004225">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

通常のSELECT文をページネーションするクエリや、
悲観排他するクエリに変換する際にRDBMSの方言を吸収するためのものですね。

ページネーションはH2なら `offset` と `limit` を使うけど、Oracleなら `rownum` を使うし、悲観排他はOracleなら `for update` を使うけど、SQLServerなら `with(updlock)` を使う、といった感じです。
この辺をDomaの中で吸収してくれるのが `Dialect` です。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ページネーションとかはSelectOptionsとかの話かな<a href="https://t.co/PETWtejqLi">https://t.co/PETWtejqLi</a><a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; やんく (@yy_yank) <a href="https://twitter.com/yy_yank/status/751645008592146432">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

そうです。
Domaは `SelectOptions` で `offset` と `limit` を指定する事ができます。
他にも悲観排他、それからカウント取得なんかの指定もできます。

* http://doma.readthedocs.io/ja/stable/query/select/#id11

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> NetBeansでは...らしい。（私はMavenでビルド定義して使ってる）</p>&mdash; Den (@den2sn) <a href="https://twitter.com/den2sn/status/751645057439019010">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

これは私の誤りのようです。
Mavenプロジェクトなのか、Gradleプロジェクトなのか、そういった違いにもよるのかも知れませんが、少なくともMavenプロジェクトだと何も不都合なく使えるようです。
NetBeans、ごめんなさい。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">アクセサいらんのか<a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; やんく (@yy_yank) <a href="https://twitter.com/yy_yank/status/751645347265409024">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Domaはエンティティのフィールドを直接見に行くのでアクセサメソッドは不要です。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">エンティティリスナーでcreate_user、create_dateを設定したいという場合には非常に便利そう。<br>共通項目クラスとかを用意する必要はありそうだけど。 <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; Junki Yamada（シュンツ） (@glory_of) <a href="https://twitter.com/glory_of/status/751646228098584578">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

仰る通り、共通項目だけを持つ基底クラスとなるエンティティを作る必要があります。
基底クラスがあればエンティティリスナーは1つで良いので、楽といえば楽です。

これは後日、サンプルを作ろうと思います。
(私のGitHubリポジトリを漁ったら既にあるかも知れませんが)

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Stream にした場合はページングはやってくれるのかな？ <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a></p>&mdash; いとうちひろ(Chihiro Ito) (@chiroito) <a href="https://twitter.com/chiroito/status/751647049364287489">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ページネーションは `SelectOptions` の `offset` と `limit` で指定します。
`Stream` 検索はあくまでも `ResultSet.next` してエンティティにマッピングする処理を `Stream` で表現しているだけです。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Streamを返す版はリソース忘れが無いようにそのままだとコンパイル時に警告を出してくれます。close処理を書いたら心を込めてアノテーションつけると警告を外せます。 <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a></p>&mdash; がくぞ (@gakuzzzz) <a href="https://twitter.com/gakuzzzz/status/751648364362510336">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

`Stream` を返すためではなく、他の事に心を込めような！！！

……と、冗談はさておき、元々はSpring Batchの `ItemReader` では `ResultSet.next` がメソッドをまたぐ必要があるため、それに対応しやすいように入れられた機能です。
通常は使う機会は無いと思います。

これも後日サンプルを書いてみようと思います。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">RomaをSpringで使う場合、Spring Bootしか選択肢ないのかな？<br>Boot以外では使えたりしないかな？<a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; Takafumi Iju (@ijufumi_0810) <a href="https://twitter.com/ijufumi_0810/status/751650514954137600">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Spring BootではないSpringでも使えます。
実装には `doma-spring-boot-autoconfigure <https://github.com/domaframework/doma-spring-boot/tree/master/doma-spring-boot-autoconfigure>`_
が参考になると思います。

Domaが必要とするのは `DataSource` だけですので、SpringでもJava EEでもJava SEでも、基本的にどこでも使えます。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ローカルトランザクション、Java SE環境で使えるのか<a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; やんく (@yy_yank) <a href="https://twitter.com/yy_yank/status/751650821838823424">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

使えます。
やってる事は単純で `Connection.setAutoCommit` と `Connection.commit` と `Connection.rollback` を組み合わせてトランザクションを行っているだけです。
あとは `ThreadLocal` を利用してトランザクションの期間中 `Connection` をスレッドに紐付けています。

`LocalTransactionDataSource` まわりのコードは小さいので、読んでみるのも楽しいですよ！

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">今って[at]Transactionalアノテーションサポートしてる？ <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a></p>&mdash; Ktz (@ktz_alias) <a href="https://twitter.com/ktz_alias/status/751651022318112768">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

`@Transactional` はJava EEやSpringといったコンテナの機能で、Domaはサポートしていません。
Domaの範囲からは逸脱すると私は考えます。

とはいえ、例えばGuiceのような軽量コンテナであってもインターセプタの機能を有しているので、
Domaのローカルトランザクションと組み合わせて宣言的トランザクション機能を自作することは可能です。

これも後日サンプルをGuiceとDomaで書いてみますね。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">こんな感じで検索すればSQLも引っ掛けられる（STS） <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a> <a href="https://t.co/r2US1mwupJ">pic.twitter.com/r2US1mwupJ</a></p>&mdash; Junki Yamada（シュンツ） (@glory_of) <a href="https://twitter.com/glory_of/status/751655497397264384">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

シュンツさん、ありがとうございます！！！

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">「エンティティをDAO内で定義したい」は比較的実装しやすいかもしれません。すでにドメインクラスはネストし<br>て定義できるようになっていますし。 <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; toshihiro nakamura (@nakamura_to) <a href="https://twitter.com/nakamura_to/status/751655785600393216">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ソッコーで実装されててわろた。

* https://github.com/domaframework/doma/pull/159

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">「主キー検索クエリは自動で組み立てたい」は実装自体は簡単。ポリシーとして整合性を保てるか？アノテーションの書き方をどうするか？などが問題になりそうです。<a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; toshihiro nakamura (@nakamura_to) <a href="https://twitter.com/nakamura_to/status/751656499378737152">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ですね、よくわかります。
(なのでわがまま言うつもりはありません)

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">社員ID,名前、住所、役職とか、これをstringではなく、ドメインクラスにしていくと、クラス数爆発しそう。線引きはどうするんだろ。 <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; まめぴか＠ (@mame_pika) <a href="https://twitter.com/mame_pika/status/751659291459719168">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

確かに、ドメインクラスを推進するとクラス数は多くなりますが、型の恩恵を受けられるメリットの方が大きいと私は判断しています。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ドメインクラスのgetValueをアプリケーションで呼ばない場合、プレゼンテーション層に値を渡す場合はどうすればいいんだろ？<br>toStringでvalueを返せば良いのかな？<a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a> <a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; Takafumi Iju (@ijufumi_0810) <a href="https://twitter.com/ijufumi_0810/status/751664414336569344">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

フレームワークや共通部品のような抽象的な層なら `getValue` へのアクセスを許可します。
テンプレートにドメインクラスを渡す場合はコンバータを書きます(例えばJAXBの `XmlAdapter <https://docs.oracle.com/javase/jp/8/docs/api/javax/xml/bind/annotation/adapters/XmlAdapter.html>`_ )。
その際、コンバータには `getValue` へのアクセスを許可します。

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">domaのコミュニティ素敵だなあ <a href="https://twitter.com/hashtag/doma_tokyo?src=hash">#doma_tokyo</a></p>&mdash; 寝起き (@nashcft) <a href="https://twitter.com/nashcft/status/751685884760592384">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ありがとうございます。
本当に嬉しいお言葉です。
イベントを開催して良かった。

蛇足：DDDとの対比(個人的な見解)
--------------------------------------------------

ドメインクラスという名前のせいか、DDDに関係するのかな？といったツイートを見かけた事がありますが、DomaはDDD用のフレームワークではありません。
しかし、DDDで語られる各要素がDomaで言えば何なのかを考える事はできます。

個人的には次のように考えています。

* Domaの「テーブルと1対1にマッピングするエンティティ」は、DDDの「エンティティ」に相当する
* Domaの「検索結果にマッピングするエンティティ」と「ドメインクラス」は、DDDの「値オブジェクト」に相当する

懇親会について
--------------------------------------------------

今回、懇親会の企画はしていたのですが、参加者を募集しませんでした。
これは、本当に私の我儘でして、中村さん、がくぞさんと私自身がたくさん話したい！と強く思っていたので、広く募集はせずにスタッフと最後まで残って会場の現状復帰に付き合ってくれた方々数名だけとさせて頂きました。

我儘を通した甲斐があって、楽しい夕食の時間を過ごさせて頂きました。

イベント会場であるdotsについて
--------------------------------------------------

.. raw:: html

    <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">dots. のイベントスペース、おしゃで綺麗で木の床があって受付にお姉さんがいてかなり良い！！！！！<a href="https://twitter.com/hashtag/eventdots?src=hash">#eventdots</a></p>&mdash; さらちむ (@syobochim) <a href="https://twitter.com/syobochim/status/751688326105542656">2016年7月9日</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ほんまそれ。

最高でした！
勉強会を開催したい方には、会場候補におすすめします！

* `dots. [ドッツ] - IT勉強会・セミナーなどのイベント情報サイト <http://eventdots.jp/>`_

謝辞
--------------------------------------------------

このイベントを開催しようと思ったきっかけは、春に東京へ遊びに行った際、一緒に晩御飯を食べてくれる人を募集したらがくぞさんが来てくださったところから始まりました。
がくぞさんが「一緒にやりましょう」と言ってくださったので中村さんにもお声がけする勇気が出ました。
がくぞさん、本当にありがとうございました！

同じく、その晩御飯の席に参加してくださっており、会場としてdotsを挙げてくださった
`とーますさん <https://twitter.com/grimrose>`_
にも感謝です！
dotsに関する事のサポートや、懇親会のお店の手配をしてくださり、ありがたかったです。
晩御飯、美味しかったー！

それから、運営の手伝いを買って出てくださった多田さん、やんくさん、ありがとうございました！
無茶振りのLTにも応えてくださり、イベントがより華やかになりました！

そして、中村さん、突然お声がけしたにも関わらず登壇を快く引き受けてくださってありがとうございました！
ずっと以前からお会いしたくて、でもきっかけが無くて、がくぞさんのおかげで勇気を出せて、お声がけして、ようやくお会いできました。
本当に、本当に嬉しかったです！！！

あと、友人(と表現させてください)の
しょぼちむ、
うがさん、
てんてんさん、
ちっひー、
はすぬまさん、
@suzukijさん、
Denさん、
まめぴー、来てくださってありがとうございました！
中村さんの前での発表はこれでもか！！！ってぐらい緊張していたけど、みんなが居ると思えばこそ最後まで発表できた気がします。

シュンツさん、来てくださってありがとうございました！
参加登録者を見て、密かに「お会いできる！」とワクワクしていました。
お会いできて嬉しかったです！

最後になりますが、参加してくださった皆さん、本当にありがとうございました！
皆さんのおかげでイベントが賑やかになり、楽しく過ごす事ができました。

本当に楽しい、夢のような1日でした。

みんなで撮った集合写真は、MBPのデスクトップを飾っています。

.. author:: default
.. categories:: none
.. tags:: Java, Doma, emotion
.. comments::
