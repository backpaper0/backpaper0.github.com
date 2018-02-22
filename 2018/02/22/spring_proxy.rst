Springのproxyとfinalメソッド、それからnull
====================================================

.. raw:: html

   <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">SpringのRepositoryとComponentアノテ、動きに違いがあるのか、、<br>Repositoryだとフィールドがnullになってハマった</p>&mdash; こざけ (@s_kozake) <a href="https://twitter.com/s_kozake/status/964792731548631040?ref_src=twsrc%5Etfw">2018年2月17日</a></blockquote>
   <script async src="https://platform.twitter.com/widgets.js" charset="utf-8">{}</script>

.. raw:: html

   <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ようやく🍥Repositoryでフィールドの値がnullになる原因が分かった、、<br>メソッドをfinal指定してました<br>サブクラスベースのProxyではメソッドやクラスにfinalをつけてはいけないとあれほど_:(´ཀ`」 ∠):</p>&mdash; こざけ (@s_kozake) <a href="https://twitter.com/s_kozake/status/965462883864735744?ref_src=twsrc%5Etfw">2018年2月19日</a></blockquote>
   <script async src="https://platform.twitter.com/widgets.js" charset="utf-8">{}</script>

.. raw:: html

   <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ここら辺、どこか詳しい資料ありますか？<br>CGLIBを用いてサブクラスベースのProxyを実現している状況で、メソッドをfinalにした場合、内部でどのような状況になってnullのインスタンスを見るようになったかという<br>まあ、そもそもfinal切るなって話なのですが</p>&mdash; こざけ (@s_kozake) <a href="https://twitter.com/s_kozake/status/965717257379659777?ref_src=twsrc%5Etfw">2018年2月19日</a></blockquote>
   <script async src="https://platform.twitter.com/widgets.js" charset="utf-8">{}</script>

こざけさんがこんな感じでわちゃわちゃしていたので、詳しい資料はどこにあるか分からないけれど、なぜそうなったのか解説しようと思います。

なぜそうなるのか概ね理解していたけれど、理解していなかった点を調べる過程で私自身も学ぶことがあったので、正直こざけさんには調べるきっかけを作ってくれてありがとうございますという感じです！

@Repositoryとproxy
-----------------------

``@Repository`` をクラスに付けると、そのクラスのproxyが作られます。

proxyてなんやねんって話ですが、これは実行時に生成される該当クラスのサブクラスで、他のコンポーネントにインジェクションされるのはこのproxyのインスタンスです。
実際のクラスのインスタンスへはproxyのインスタンスを経由して委譲される仕組みになっています。

このproxyの仕組みには、コンポーネントの利用者がスコープを意識しなくてよくなるという利点があります。

どういうことか、順を追って見ていきましょう。

proxyという概念が無いDIコンテナ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DIコンテナにはスコープというものがあります。

これはコンポーネントのライフサイクルを表すもので、Webアプリで動くDIコンテナであれば「リクエストスコープ」や「セッションスコープ」を持っています。
「リクエストスコープ」はその名の通りHTTPリクエストの開始から終了までの間に有効となるスコープです。
「セッションスコープ」もその名の通りでセッションを開始してから破棄されるまでの間に有効となるスコープです。

では「セッションスコープのコンポーネント」から「リクエストスコープのコンポーネント」を使用することを考えてみましょう。
コードで書くとこんな感じ。

.. code-block:: java

   //※これはSpringではない架空のDIコンテナのコード

   @SessionScope
   public class Hoge {
   
       @Inject
       private Fuga fuga;
       
       public void action() {
           fuga.process();
       }
   }
   
   @RequestScope
   public class Fuga {
       //フィールドやメソッドの定義は省略
   }

この ``Hoge`` と ``Fuga`` を使った処理の流れは、

1. HTTPリクエストを受け取る
2. セッションを作成する
3. ``Hoge`` のインスタンスを作成する
4. ``Fuga`` のインスタンスを作成する
5. ``Hoge`` に ``Fuga`` をインジェクションする
6. ``Hoge`` の ``action`` メソッドを実行する
7. ``Fuga`` の ``process`` メソッドを実行する
8. HTTPリクエストが終了する
9. ``Fuga`` のインスタンスをDIコンテナから破棄する
10. HTTPレスポンスを返す

という感じ。

あんまり問題なさそうに見えますが、 ``Fuga`` の ``process`` メソッドが実行中に同じユーザーからもう一つHTTPリクエストが来たらどうなるでしょうか？

1. HTTPリクエストAを受け取る
2. セッションを作成する
3. ``Hoge`` のインスタンスを作成する
4. ``Fuga`` のインスタンスを作成する（リクエストAのスコープ）
5. ``Hoge`` に ``Fuga`` をインジェクションする
6. ``Hoge`` の ``action`` メソッドを実行する
7. ``Fuga`` の ``process`` メソッドを実行し始める
8. HTTPリクエストBを受け取る
9. ``Fuga`` のインスタンスを作成する（リクエストBのスコープ）
10. ``Hoge`` に ``Fuga`` をインジェクションする……！？

とまあ、こんな感じで ``Hoge`` にインジェクションされる ``Fuga`` がバッティングするわけです。

そういうわけでproxyの無いDIコンテナでは、あるスコープのコンポーネントには、それよりも小さいスコープ（ライフサイクルが短いと言い換えても良さそう）のコンポーネントをインジェクションできませんでした。
proxyが無くてこのような制約のあるDIコンテナとしてはSeasar2が挙げられます。

proxyがあるDIコンテナ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

先に述べた問題をproxyがどのように解決するのか見ていきましょう。

``Fuga`` のproxyをコードで書くとこんな感じになります。

.. code-block:: java

   //実際には実行時にクラスファイルが生成されるのでソースコードは存在しない
   //あくまでもproxyのイメージ
   public class FugaProxy extends Fuga {
       
       private Container container;
       
       public void process() {
           Fuga component = container.getComponent(Fuga.class);
           component.process();
       }
   }

コード上のコメントにも書きましたが、proxyは実際には実行時にクラスファイル（というかインメモリ上にバイトコードのデータ）として生成されるのが普通なので、ソースコードはありません。
コード例は雰囲気です。

コードを見てみると ``process`` メソッドが呼ばれるとDIコンテナからproxyではない実際の ``Foo`` インスタンスが取り出され、そのインスタンスの ``process`` メソッドが呼ばれています。

先ほどのproxyが無いDIコンテナで ``Fuga`` がバッティングしてしまったシナリオを、proxyがあるDIコンテナではどうなるか見てみましょう。

1. HTTPリクエストAを受け取る
2. セッションを作成する
3. ``Hoge`` のインスタンスを作成する
4. ``Fuga`` のインスタンスを作成する（リクエストAのスコープ）
5. ``Fuga`` のproxyを作成する
6. ``Hoge`` に ``Fuga`` のproxyをインジェクションする
7. ``Hoge`` の ``action`` メソッドを実行する
8. ``Fuga`` のproxyの ``process`` メソッドを実行し始める
9. ``Fuga`` のproxy内でDIコンテナから実際の ``Fuga`` インスタンス（リクエストAのスコープ）を取り出して ``process`` メソッドを実行し始める
10. HTTPリクエストBを受け取る
11. ``Fuga`` のインスタンスを作成する（リクエストBのスコープ）
12. ``Hoge`` の ``action`` メソッドを実行する
13. ``Fuga`` のproxyの ``process`` メソッドを実行し始める
14. ``Fuga`` のproxy内でDIコンテナから実際の ``Fuga`` インスタンス（リクエストBのスコープ）を取り出して ``process`` メソッドを実行し始める

このようにproxyを経由してDIコンテナから異なる ``Fuga`` インスタンスを取り出して ``process`` メソッドを実行できました。

以上のことからproxyがあるDIコンテナではスコープを意識することなくインジェクションを行えることが分かりました。

finalメソッドからフィールドを参照したらnullになった理由
---------------------------------------------------------------

当初の問題に戻りましょう。
「 ``@Respository`` を付けたクラスの ``final`` なメソッドを実行するとインジェクションされたはずのフィールドへアクセスしたときに ``NullPointerException`` が発生した」という問題です。

次のコードを見てください。

.. code-block:: java

   @Repository
   public class Foo {
   
       @Autowired
       private Bar bar;
   
       public String method1() {
           return String.format("%s%n%s%n", bar, getClass());
       }
   
       public final String method2() {
           return String.format("%s%n%s%n", bar, getClass());
       }
   }

``method1`` と ``method2`` はどちらもフィールド ``bar`` と自分自身のクラスを文字列にして返しています。
異なる点は ``method2`` は ``final`` であるということだけです。

``method1`` の実行結果はこちら。

.. code-block:: none
 
   com.example.demo.Bar@1db75e25
   class com.example.demo.Foo

``method2`` の実行結果はこちら。

.. code-block:: none

   null
   class com.example.demo.Foo$$EnhancerBySpringCGLIB$$a65476ff

当初の問題と同じように ``final`` な方の ``method2`` では ``bar`` が ``null`` になっていますね。

ただ、クラス名にも注目してください。
``method1`` では ``Foo`` となっていますが ``method2`` は ``Foo`` のproxyになっています。

ここで ``Foo`` のproxyがどうなっているのか、再び雰囲気でコードにしてみましょう。

.. code-block:: java

   //雰囲気
   public class Foo$$EnhancerBySpringCGLIB$$a65476ff extends Foo {
   
       Container container;
       
       @Override
       public String method1() {
           Foo component = container.getComponent(Foo.class);
           return component.method1();
       }

       //method2はfinalなのでoverrideできない
   }

ご覧の通り ``method1`` はコンテナから実際のインスタンスを取り出して委譲していますが、
``method2`` は ``final`` なため ``override`` できずに実際のインスタンスに委譲されることなく実行されてしまいます。

proxyは、コンテナから実際のインスタンスを取り出して委譲するものなので、proxyに対してコンポーネントをインジェクションする意味はありません。
実際、元のクラスでインジェクション対象となっているフィールドはproxyでは ``null`` になります。

以上が、proxyが作られるクラスに定義された ``final`` メソッドがインジェクション対象のフィールドを参照している場合に ``NullPointerException`` になる理由です。

コンストラクタインジェクションとproxy
-----------------------------------------------------------

さて、ここからが私も初めて知った事柄になります。
久しぶりにびっくりした。

次のようにコンストラクタインジェクションしているクラスを考えてみましょう。

.. code-block:: java

   @Repository
   public class Foo {
   
       private final Bar bar;
   
       public Foo(Bar bar) {
           this.bar = Objects.requireNonNull(bar);
       }
   
       public String method1() {
           return String.format("%s%n%s%n", bar, getClass());
       }
   
       public final String method2() {
           return String.format("%s%n%s%n", bar, getClass());
       }
   }

proxyの雰囲気コードはこんな感じ。

.. code-block:: java

   //雰囲気
   public class Foo$$EnhancerBySpringCGLIB$$a65476ff extends Foo {
   
       Container container;
       
       public Foo$$EnhancerBySpringCGLIB$$a65476ff(Bar bar) {
           super(bar);
       }
       
       @Override
       public String method1() {
           Foo component = container.getComponent(Foo.class);
           return component.method1();
       }

       //method2はfinalなのでoverrideできない
   }

この場合、生成されるproxyのコンストラクタ引数 ``bar`` には何が入るのでしょうか？

先に述べた通り、proxyのインジェクション対象フィールドにはインジェクションする意味はありません。
かと言って ``null`` を渡すとスーパークラスのコンストラクタで ``Objects.requireNonNull`` によって ``NullPointerException`` がスローされます。

それではSpringはproxyをインスタンス化するときに何を渡すのでしょうか？

色々とがんばってソースコードを追っかけた末に分かったのですが、コンストラクタを呼ばずにインスタンス化していました。
何を言っているのか分かりませんね？

proxyのインスタンス化にはObjenesisというライブラリの次のクラスが使われていました。
（実際には ``org.springframework.objenesis`` にrepackageされています）

* https://github.com/easymock/objenesis/blob/2.6/main/src/main/java/org/objenesis/instantiator/sun/SunReflectionFactoryInstantiator.java

クラスのJavadocに次の記載があります。

   Instantiates an object, WITHOUT calling it's constructor, using internal sun.reflect.ReflectionFactory

お、おう……！
って感じですが、JDKのinternalなクラスを使ってコンストラクタを呼ばずにインスタンス化していました。
だからフィールドが ``null`` だった、というわけですね。

コンストラクタ呼ばれないってどういうことだよ……と思いながら ``SunReflectionFactoryInstantiator`` を眺めていたら ``newConstructorForSerialization`` というメソッド名が出てきて、そういえばシリアライズされたオブジェクトをデシリアライズする時ってコンストラクタ呼ばれないんだっけ、とか雑な記憶で雑に思いました。
とか書いておくと詳しい人がコメントくれるはずです。
他力本願。

まとめ
---------------

* DIコンテナにはproxyを経由してスコープを意識せずに使える機能がある
* proxyは実行時にサブクラスを生成して実現するので ``final`` メソッドを使うとマズい
* SpringではproxyはJDKのinternalなクラスを使用してコンストラクタ呼び出し無しにインスタンス化される（その結果フィールドが ``null`` になる）

こんな感じで、割と真っ黒な黒魔術に辿り着いた感があって楽しかったです。
こざけさん、ありがとう！

ちなみに
~~~~~~~~~~~~~

.. raw:: html

   <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">警告みたいなの欲しいですねー</p>&mdash; opengl-8080 (@opengl_8080) <a href="https://twitter.com/opengl_8080/status/965788137967386624?ref_src=twsrc%5Etfw">2018年2月20日</a></blockquote>
   <script async src="https://platform.twitter.com/widgets.js" charset="utf-8">{}</script>

``INFO`` レベルですが、ログは出ているみたいです。

.. code-block:: none

   018-02-22 22:22:14.298  INFO 25770 --- [  restartedMain] o.s.aop.framework.CglibAopProxy          : Final method [public final java.lang.String com.example.demo.Foo.method2()] cannot get proxied via CGLIB: Calls to this method will NOT be routed to the target instance and might lead to NPEs against uninitialized fields in the proxy instance.

.. author:: default
.. categories:: none
.. tags:: Java
.. comments::
