DevLOVE関西「開発スターターキット」におけるJAX-RSの簡単な解説
===============================================================

どうも、GlassFishとJAX-RSを（・∀・）ｲｲﾖｲｲﾖｰと言っていた2番テーブルTAのうらがみです。

* `DevLOVE関西「開発スターターキット」`_

というわけで参加されたみなさん、お疲れ様でした。
いいよいいよと言いまくってた手前、今回のJAX-RSを利用していたソースコードをかるーく解説しておこうと思います。

まずはDevKanApplication.javaです。

.. sourcecode:: java

   @ApplicationPath("/services")
   public class DevKanApplication extends Application {
   }

Applicationを継承して@ApplicationPathで注釈していますが、このクラスがあればGlassFishさんが
「お、これはJAX-RSの出番やな( ｰ`дｰ´)ｷﾘｯ」
という感じで認識してくれます。
なお@ApplicationPathに設定している /services が基点となるパスになります。

次いでCalculator.javaです。

.. sourcecode:: java

   @Path("/calc")
   @Produces(MediaType.TEXT_PLAIN)
   public class Calculator {
   
       @GET
       @Path("add")
       public String add(@QueryParam("a")int a, @QueryParam("b")int b){
           return "2";
       }
   }

アノテーションがもりもり書かれていますが、これらはHTTPリクエスト/レスポンスに対応しています。
足し算のHTTPリクエスト/レスポンスはこんな感じになりますよー、っていうのを何となく書き出します。

リクエストはこんな感じ。

.. sourcecode:: none

   GET /devkan-calc/services/calc/add?a=2&b=3 HTTP/1.1

レスポンスはこんな感じ。

.. sourcecode:: none

   HTTP/1.1 200 OK
   Content-Type: text/plain
   Content-Length: 1

   2

見比べるとよく分かりますが、

* メソッドに書かれた@GETはリクエストメソッドに、
* クラスとメソッドに書かれた@Pathはリクエストのパスに、
* メソッドのパラメータに書かれた@QueryParamはリクエストのクエリパラメータに、
* クラスに書かれた@ProducesはレスポンスのContent-Typeに、
  
それぞれ対応しています。
ついでに言うと、戻り値はレスポンスのエンティティボディに対応していますね。
HTTPを知っていればJAX-RSは使えるよー、という感じですね。

以上、JAX-RSの簡単な解説おわり。

WARを覗く
-------------

jar -tf build/libs/devkan-calc.war と打ってWARの中身を覗いてみましょう。
WARファイルの中身、WEB-INFディレクトリの下にあるのは DevKanApplication.class と Calculator.class だけです。
フレームワークのJARファイルはおろか、web.xmlすらありません。

JAX-RSはJava EEの一部であり、Java EEのアプリケーションサーバであるGlassFishにデプロイする場合はフレームワークのJARファイルは不要です。

また、最近ではサーブレットの登録にもweb.xmlは必須ではありません。
@WebServletというアノテーションで登録するか、ServletContextのaddServletメソッドで動的に登録できます。

この辺りはまた別の機会に詳しく紹介するとして(やらないフラグ)、大事なのは「JAX-RSなら2クラスでWebアプリ作れるですよ(｀・ω・´)ｼｬｷｰﾝ」ということです。
お手軽ですね。

JAX-RSをもっと知りたい場合は
---------------------------------

`@btnrougeさん`_ のブログ `Programming Studio`_ を読むと良いでしょう。
JAX-RSのタグが付けられたエントリをざくざく読んで行けばもりもり知識がつくと思います。

それと、手前味噌ですが、私もJAX-RSを一通り紹介するエントリを書きました。

* :doc:`/2013/05/02/jaxrs`

ただし対象バージョンはちょっと古いです。
エントリは1.1。
最新は2.0。
そのうちエントリも2.0にアップデートしたいです(やらないフラグ)。

書籍なら「JavaによるRESTfulシステム構築」(ISBN:978-4873114675)が良いですかねー。
日本語訳が2010年に出版された書籍で、こちらも内容はJAX-RS 1系ですが今でも通用する情報が載っているとは思います。

そんな感じで、JAX-RSの回し者、うらがみでした(・∀・)

.. _Programming Studio: http://www.coppermine.jp/docs/programming/
.. _DevLOVE関西「開発スターターキット」: http://devlove-kansai.doorkeeper.jp/events/4363
.. _@btnrougeさん: https://twitter.com/btnrouge

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS
.. comments::
