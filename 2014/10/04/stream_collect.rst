Streamのcollectメソッドを学ぶ
===================================

`Stream`_ にある数多くのメソッドの中でも分かり辛い感じがする
`collectメソッド`_ について学びます。



`collect` メソッドの概要
------------------------------

端的に述べると `collectメソッド`_ は `Stream<T>` を `R` に変換する操作です。

より詳しく述べると、
`Stream` の各要素( `T` )を中間コンテナ( `A` )に折り畳んだ後に最終的な結果( `R` )に変換する操作です。

括弧内のアルファベットは `Collector`_ が持つ3つの型変数に対応しています。

* `T` : Streamの要素の型
* `A` : **ミュータブル** な中間コンテナの型
* `R` : 最終的に返される結果の型

例えば `Stream<Character>` を単純に繋げて `String` にする場合は、
`Stream` の各 `Character` ( `T` )を `StringBuilder` ( `A` )に `append` した後に `String` ( `R` )に変換する、
という流れになります。

.. note::

   高パフォーマンスを得るため中間コンテナは **ミュータブル** となっています。
   詳細は `java.util.streamパッケージの「可変リダクション」`_ を参照ください。



`Collector` インターフェースの説明
----------------------------------------

`collectメソッド`_ は引数に `Collector`_ を取ります。
`Collector`_ は「関数を返す4つのメソッド」と「特性を返すメソッド」を持ったインターフェースです。

「特性」については後述するとして、まず「4つの関数」を説明します。

* `supplier`_ : 中間コンテナを生成する関数。
  順次処理のとき最初の1回だけ実行される。
  並列処理のときは複数回実行されることがある。

* `accumulator`_ : 中間コンテナへ値を折り畳む関数。
  `Stream` の要素の数だけ実行される。

* `combiner`_ : ふたつの中間コンテナをひとつにマージする関数。
  並列処理のときに実行されることがある。

* `finisher`_ : 中間コンテナから最終的な結果へ変換する。
  最後の1回だけ実行される。

.. note::

   日本語Javadocの説明文ではそれぞれ「サプライヤ」「アキュムレータ」「コンバイナ」「フィニッシャ」と表記されています。
   勉強会などで読み方を牽制し合わなくて済みますね！



文字を結合する `Collector` の例
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

例えば `Character` の `Stream` を `StringBuilder` へ折り畳んで最終的に
`String` に変換するという処理を考えてみます。

`Collector` が返す関数はそれぞれ次のような処理を行うようにします。

* `supplier`_ で `StringBuilder` のインスタンスを生成する
* `accumulator`_ で `StringBuilder` へ `Character` を `append` する
* `combiner`_ でふたつの `StringBuilder` をひとつにマージする
* `finisher`_ で `StringBuilder` を `toString` する

各関数のコードを記載します。

* `supplier`

  引数なしで `StringBuilder` のインスタンスを返します。

  .. code-block:: java

     () -> new StringBuilder()

  またはコンストラクタ参照でも良いです。

  .. code-block:: java

     StringBuilder::new

* `accumulator`

  `StringBuilder` と `Character` を受け取って
  `append` します。
  戻り値は `void` です。

  .. code-block:: java

     (sb, c) -> sb.append(c)

  またはメソッド参照でも良いです。

  .. code-block:: java

     StringBuilder::append

* `combiner`

  ふたつの `StringBuilder` を受け取ってひとつの
  `StringBuilder` にマージして返します。

  .. code-block:: java

     (sb1, sb2) -> sb1.append(sb2);

  またはメソッド参照でも良いです。

  .. code-block:: java

     StringBuilder::append

* `finisher`

  `StringBuilder` を受け取って `String` へ変換して返します。

  .. code-block:: java

     sb -> sb.toString()

  またはメソッド参照でも良いです。

  .. code-block:: java

     StringBuilder::toString

これら4つの関数をもとにして `Collector` インスタンスを生成します。
愚直に `Collector` インターフェースを実装したクラスを作っても良いのですが
`Collector` の `ofメソッド`_ を利用するのが楽です。

.. code-block:: java

   Collector<Character, StringBuilder, String> characterJoiner =
           Collector.of(() -> new StringBuilder(),     //supplier
                        (sb, c) -> sb.append(c),       //accumulator
                        (sb1, sb2) -> sb1.append(sb2), //combiner
                        sb -> sb.toString()));         //finisher

   //コンストラクタ参照・メソッド参照バージョン
   Collector<Character, StringBuilder, String> characterJoiner =
           Collector.of(StringBuilder::new,        //supplier
                        StringBuilder::append,     //accumulator
                        StringBuilder::append,     //combiner
                        StringBuilder::toString)); //finisher

この `Collector` を使って文字を連結してみます。

.. code-block:: java

   String s = Stream.of('h', 'e', 'l', 'l', 'o').collect(characterJoiner);
   System.out.println(s); //hello



`Collector` の特性
~~~~~~~~~~~~~~~~~~~~~~~~~

`Collector` はネストした列挙型 `Characteristics`_ を使用してみっつの特性を表すことができます。
各特性について説明します。

* `CONCURRENT` : ひとつの結果コンテナインスタンスに対して複数スレッドから `accumulator` を実行できる特性です。

  つまり次のような処理を行っても不整合が起こらなければ、この特性を持っていると言えます。

  .. code-block:: java

     A acc = supplier.get(); //中間コンテナ

     new Thread(() -> accumulator.accept(acc, t1)).start();

     new Thread(() -> accumulator.accept(acc, t2)).start();


* `IDENTITY_FINISH` : `finisher` が恒等関数であり、省略できる特性です。

  つまり `finisher` が次のような実装になる場合、この特性を持っていると言えます。

  .. code-block:: java

     Function<A, R> finisher = a -> (R) a;

* `UNORDERED` : 操作が要素の順序に依存しない特性です。

いずれの特性も性能向上のためのものと思われます。
ですので特性をひとつも持たないとしても致命的な問題は無さそうです。
むしろ自作 `Collector` がどの特性を持っているか分からない、いまいち自信が無いなどの場合は
`Characteristics` を設定しない方が良いかも知れませんね。

`Collector` インスタンスを生成する際に特性を与えたい場合は `of` メソッドの第5引数(可変長引数です)を使用します。

.. code-block:: java

   Collector<T, A, R> collector =
           Collector.of(supplier, accumulator, combiner, finisher,
                        Characteristics.CONCURRENT,
                        Characteristics.IDENTITY_FINISH,
                        Characteristics.UNORDERED);



中間コンテナの型変数について
----------------------------------------

`Collector` は自分で実装しても良いですが、よく使われそうな実装を返す
`static` メソッドを多数定義した `Collectors`_ というユーティリティクラスが提供されています。

`Collectors`_ のメソッド一覧を眺めて戻り値に注目するとほとんどが
`Collector<T, ?, R>` となっており、
中間コンテナの型がワイルドカードで宣言されていることが分かります。

冒頭でも書きましたが `Stream` の `collectメソッド`_ は `Stream<T>` を `R` に変換する操作です。
このときの `T` と `R` は `Collector<T, A, R>` のそれに対応します。
つまり `collectメソッド`_ を使うひと―― `Collector` の利用者――にとっては中間コンテナが何であるか意識する必要はないんですね。

このように利用者には不要な中間コンテナの型が見えており、
実際にはワイルドカードが宣言されているというのは少し残念であり、
`collectメソッド`_ をややこしく感じさせている一因かも知れないな、と思います。

というわけで `Collectors`_ の各メソッドでのワイルドカードは空気のように扱うことにしましょう。



まとめ、それと自分への宿題
---------------------------------

* 使う側としては中間コンテナの存在は無視る
* よく分からんかったら `Characteristics` は付与しない
* 何はともあれ `collectメソッド`_ 便利

こっから宿題。

* Scalaの `scan` みたいなやつを実装してみる。

  こんなやつです。

  .. code-block:: scala

     //これはScalaコード
     val xs = 1 to 5 toList
     xs.scan(0)(_ + _) //0, 1, 3, 6, 10, 15



.. _accumulator: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html#accumulator--
.. _Characteristics: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.Characteristics.html
.. _Collector: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html
.. _collectメソッド: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#collect-java.util.stream.Collector-
.. _combiner: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html#combiner--
.. _finisher: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html#finisher--
.. _java.util.streamパッケージの「可変リダクション」: http://docs.oracle.com/javase/jp/8/api/java/util/stream/package-summary.html#MutableReduction
.. _ofメソッド: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html#of-java.util.function.Supplier-java.util.function.BiConsumer-java.util.function.BinaryOperator-java.util.function.Function-java.util.stream.Collector.Characteristics...-
.. _Stream: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html
.. _supplier: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collector.html#supplier--
.. _Collectors: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Collectors.html



.. author:: default
.. categories:: none
.. tags:: Java, Stream API
.. comments::
