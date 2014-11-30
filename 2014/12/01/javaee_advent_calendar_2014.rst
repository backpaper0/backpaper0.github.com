JAX-RSを始める #javaee
================================================================================

これは `Java EE Advent Calendar 2014 <http://qiita.com/advent-calendar/2014/javaee>`_
の1日目です。

今回は参照実装である `Jersey <https://jersey.java.net/>`_
を使ってJAX-RSを始めるための環境構築などをだらだら書こうと思います。

ビルドツール
--------------------------------------------------------------------------------

昨今はGradleが人気のような雰囲気漂っていますが、
`Maven <http://maven.apache.org/>`_ を使いましょう。

JerseyはMavenのprofileという機能を使っていてGradleではその辺のサポートがないっぽいのでたぶんしんどいです。

* 参考： `JAX-RSをGradleでアレしたい - 日々常々 <http://d.hatena.ne.jp/irof/20130505/p1>`_

Mavenのインストールはバイナリを任意の場所にダウンロードして `bin` ディレクトリにパスを通せばおkです。

ビルドファイルの準備
--------------------------------------------------------------------------------

まず、 `mvn archetype:generate` してください。
それから出来たpom.xmlを編集します。

次のdependencyManagement要素を追加してください。

.. code-block:: xml

   <dependencyManagement>
     <dependencies>
       <dependency>
         <groupId>org.glassfish.jersey</groupId>
         <artifactId>jersey-bom</artifactId>
         <version>2.13</version>
         <scope>import</scope>
         <type>pom</type>
       </dependency>
     </dependencies>
   </dependencyManagement>

それからjersey-bomのpom.xmlを見ながら好きなものを選んでdependency要素に追加します。
とはいえJerseyはサーバ側のAPI、クライアント側のAPI、MVC拡張など多数のJARに別れて提供されているので
何を追加すれば良いのか最初は分からないと思います。

今回はサーバ側のコードを書きたいので、 `jersey-server` を追加します。
また、Jerseyは `Grizzly <https://grizzly.java.net/>`_ や `Jetty <http://eclipse.org/jetty/>`_
などのコンテナ上で動きますが、今回は `JDK付属のHttpServer <https://docs.oracle.com/javase/8/docs/jre/api/net/httpserver/spec/com/sun/net/httpserver/HttpServer.html>`_
で動かしたいので `jersey-container-jdk-http` を追加します。
どんなコンテナが使えるかは http://repo1.maven.org/maven2/org/glassfish/jersey/containers/ を参照ください。
最後にJUnitでサクッと走らせてテストするため `jersey-test-framework-provider-jdk-http` を追加します。

.. code-block:: xml

   <dependencies>
     <dependency>
       <groupId>org.glassfish.jersey.core</groupId>
       <artifactId>jersey-server</artifactId>
     </dependency>
     <dependency>
       <groupId>org.glassfish.jersey.containers</groupId>
       <artifactId>jersey-container-jdk-http</artifactId>
     </dependency>
     <dependency>
       <groupId>org.glassfish.jersey.test-framework.providers</groupId>
       <artifactId>jersey-test-framework-provider-jdk-http</artifactId>
       <scope>test</scope>
     </dependency>
   </dependencies>

とまあ、こんな感じで良いでしょう。

でもこんなことチンタラやってられないと思うので https://github.com/backpaper0/sandbox をcloneして
`jersey-blank` ディレクトリ内の `pom.xml` をご利用ください。
私も大抵、自分が過去に書いたビルドファイルをコピります。

コードを書く
--------------------------------------------------------------------------------

まあ、この辺は適当に、足し算する簡単なやつで。

`src/main/java/app/Calc.java` を作ります。

.. code-block:: java

   package app;
   
   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.QueryParam;
   import javax.ws.rs.core.MediaType;
   
   @Path("calc")
   public class Calc {
   
       @Path("add")
       @GET
       @Produces(MediaType.TEXT_PLAIN)
       public int add(@QueryParam("a") int a, @QueryParam("b") int b) {
           return a + b;
       }
   }

で、JUnitテストです。
`src/test/java/app/CalcTest.java` を作ります。

.. code-block:: java

   package app;
   
   import static org.hamcrest.CoreMatchers.*;
   import static org.junit.Assert.*;
   
   import javax.ws.rs.core.Application;
   
   import org.glassfish.jersey.server.ResourceConfig;
   import org.glassfish.jersey.test.JerseyTest;
   import org.junit.Test;
   
   public class CalcTest extends JerseyTest {
   
       @Test
       public void test() throws Exception {
           int c = target("calc/add").queryParam("a", 2)
                                     .queryParam("b", 3)
                                     .request()
                                     .get(int.class);
           assertThat(c, is(5));
       }

       @Override
       protected Application configure() {
           return new ResourceConfig(Calc.class);
       }
   }

test-frameworkを使うととても簡単にJUnitテストを書ける事が分かると思います。

テスト走らせる
--------------------------------------------------------------------------------

IDEから実行するかMavenで。

.. code-block:: sh

   mvn test

簡単ですね！

.. code-block:: none

   -------------------------------------------------------
    T E S T S
   -------------------------------------------------------
   Running app.CalcTest
   11 30, 2014 10:55:12 午後 org.glassfish.jersey.test.jdkhttp.JdkHttpServerTestContainerFactory$JdkHttpServerTestContainer <init>
   情報: Creating JdkHttpServerTestContainer configured at the base URI http://localhost:9998/
   Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 5.109 sec
   
   Results :
   
   Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

まとめ
--------------------------------------------------------------------------------

というわけでJerseyを使用したJAX-RSの導入部分、如何でしたでしょうか？
簡単ですよね？
特にJava EEの一部なのにアプリケーションサーバがなくても簡単に使えるのが良いですよね！ね！

最後に、手前味噌ですがJAX-RSの参考資料を挙げておきます。

* :doc:`/2013/05/02/jaxrs`
* :doc:`/2013/07/07/devkan_jaxrs`

はー、これらの資料もJAX-RS 2.0にアップデートしないといけないなー（しろめ

簡単ですが、以上。

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS
.. comments::
