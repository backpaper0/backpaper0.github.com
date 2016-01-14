セミコロンレスJava EEでTODOリストアプリケーション #semicolonlessjava
================================================================================

これは `セミコロンレスJava Advent Calendar <http://www.adventar.org/calendars/952>`_
の13日目です。

今回はセミコロンレスJava EEを使って簡単なTODOリストアプリケーションを作ってみました。

ソースコードは https://github.com/backpaper0/semicolonless-javaee-todolist-sample です。

使っているJava EEな技術は、

* JAX-RS
* JPA
* Java API for JSON Processing
* CDI/JTA

です。

このうちCDIとJTAはアノテーションを利用しただけなので特に解説の余地はありません。

Java API for JSON Processingもリソースクラスの引数にJsonObjectを利用したってだけなので解説するほどのものじゃないですね。

というわけで、JAX-RSとJPAの利用箇所について解説します。
なお分かりやすさのためここではセミコロンを書いて良い普通のJava言語でコード例を記載します。

セミコロンレスJAX-RS
--------------------------------------------------

JAX-RSのリソースメソッドはレスポンスにエンティティボディを含むものであれば通常は次のようなコードになります。

.. sourcecode:: java

   @GET
   @Produces("text/plain")
   public String hello(@QueryParam("name") String name) {
       return "Hello, " + name + "!";
   }

しかし ``return`` しようとするとセミコロンを書かざるを得ないのでこのコードは使えません。
セミコロンレスJavaでは(一部の特殊な状況を除いて) ``return`` するメソッドを実装できません。

そこで考えたのが ``@Suspended`` と ``AsyncResponse`` を利用する方法です。

``@Suspended`` と ``AsyncResponse`` はクライアントとの接続をsuspendしておき、 ``AsyncResponse.resume`` に値を渡すことでresumeするためのものですが、
これらを利用することで次のようなコードになりました。

.. sourcecode:: java

   @GET
   @Produces("text/plain")
   public void hello(@QueryParam("name") String name,
                     @Suspended AsyncResponse response) {
       if (response.resume("Hello, " + name + "!")) {
       }
   }

``AsyncResponse.resume`` は ``boolean`` を返すのでif文に押し込みやすいですね。

これでエンティティボディを返すリソースメソッドを定義できました。

セミコロンレスJPA
--------------------------------------------------

次にJPAです。

のっけからアレですが、セミコロンレスJPAではフィールドもgetterも定義できないのでエンティティクラスを作れません。
(JPA詳しくないので、もし作れる方法があれば教えてください)

なのでネイティブクエリを使いまくるという、それJDBCでええやんけ、的な感じのコードになっております。

それはともかく、 ``EntityManager`` を取ってきましょう。
普通は次のコードのようにフィールドインジェクションすると思います。

.. sourcecode:: java

   @PersistenceContext(unitName = "SampleUnit")
   private EntityManager em;

でも前述の通りセミコロンレスJavaではフィールドが定義できません。

なのでJNDI lookupしましょう。
JSR 338 JPA 2.1仕様の「7.2.1 Obtaining an Entity Manager in the Java EE Environment」を読むと、
アノテーションでJNDI名を定義してlookupできるっぽいのでこれを利用しました。

.. sourcecode:: java

   @PersistenceContext(name = "SampleEM", unitName = "SampleUnit")
   public class SampleResource {

       public void resourceMethod() throws NamingException {
           EntityManager em = InitialContext.doLookup("java:comp/env/SampleEM");
       }
   }

この例だと変数 ``em`` に代入していますが、セミコロンレスJavaでは変数宣言も出来ません。
なので次のように ``Stream`` を使うのが良いです。

.. sourcecode:: java

   if (Stream.of((EntityManager) InitialContext
                     .doLookup("java:comp/env/SampleEM"))
                     .peek(em -> { /* emを使った処理 */ })
                     .count() > 0) {}

あとは ``EntityManager.createNativeQuery`` でSQLを発行すればOKです。

まとめ
--------------------------------------------------

セミコロンレスJava EEで実用的なアプリケーションも作れる！(作らない)

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
