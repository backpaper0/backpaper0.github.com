Spring Bootをやってみた
================================================================================

`しょぼちむがSpring Bootのハンズオンのレポートを書いていた <http://syobochim.hatenablog.com/entry/2015/01/10/195802>`_
のでそれを参考に手を動かしてみました。
ブログ通りに写経していったら普通に動いたので楽ちんでした。

ただし私の知識がアレで
`Twitter Application Management <https://apps.twitter.com/>`_
のSettingsタブにある
"Allow this application to be used to Sign in with Twitter"
にチェックを入れる必要があるっぽいのに気付かなくてそこだけちょっとつまずいた。
Twitterﾌﾟﾖｸﾞﾔﾐﾝｸﾞしてないのバレる！

HttpServletRequestとHttpSessionをなくす
--------------------------------------------------------------------------------

さて、出来上がったアプリケーションでは
HttpServletRequest
と
HttpSession
を使っている箇所があったのでそれらを使わないように変更します。

.. note::

   HttpServletRequest
   と
   HttpSession
   はサーブレットのAPIでありSpringのAPIではありません。
   なるべく低レベルのAPIを直接使用しない方がコードがシンプルになるし
   ユニットテストが書きやすくて嬉しい、というのが個人的な考えです。

まずは HttpServletRequest を消します。
Twitterの認証から戻ってくるときに
oauth_verifier
というリクエストパラメータを受け取っている所に使われています。
これをTwitterControllerのdoTweetメソッドと同じやり方で受け取るように変更します。

.. code-block:: java

   @RequestMapping("accessToken")
   public String accessToken(Model model,
           @RequestParam(value = "oauth_verifier", required = true) String verifier)
           throws TwitterException {

次いでHttpSessionを消します。
認証の際に必要となるリクエストトークンとアクセストークンを保持するために
HttpSession
が使用されているようです。
今回はそれらを格納するセッションスコープのクラスを作ってコントローラーにインジェクションする方法をとります。

まずこれがトークンを格納するセッションスコープのクラス。

.. code-block:: java

   package jp.co.bizreach.spring_boot_sample;
   
   import java.io.Serializable;
   
   import org.springframework.context.annotation.Scope;
   import org.springframework.context.annotation.ScopedProxyMode;
   import org.springframework.stereotype.Component;
   import org.springframework.web.context.WebApplicationContext;
   
   import twitter4j.auth.AccessToken;
   import twitter4j.auth.RequestToken;
   
   @Component
   @Scope(proxyMode = ScopedProxyMode.TARGET_CLASS,
           value = WebApplicationContext.SCOPE_SESSION)
   public class TwitterAuth implements Serializable {
   
       private AccessToken accessToken;
   
       private RequestToken requestToken;
   
       public AccessToken getAccessToken() {
           return accessToken;
       }
   
       public void setAccessToken(AccessToken accessToken) {
           this.accessToken = accessToken;
       }
   
       public RequestToken getRequestToken() {
           return requestToken;
       }
   
       public void setRequestToken(RequestToken requestToken) {
           this.requestToken = requestToken;
       }
   }

TwitterAuthController と TwitterController には次のようにフィールドにインジェクションします。

.. code-block:: java

   @Autowired
   private TwitterAuth auth;

あとはこのフィールドを使ってトークンを格納したり取り出したりすればオッケーです。

これでサーブレットAPIをなくすことが出来ました！

pom.xmlを作る
--------------------------------------------------------------------------------

しょぼちむのブログより

  今回はサンプルアプリを作ってくれていて、基本的にはそれを動かしてみるって感じだったけど、pomファイルの作成のところからやってみたかったかも。

作成しましょう！

サンプルはmvn archetype:generateで空のプロジェクトを作ったあとに
pom.xmlを編集してdependencyを追加したように見えます。

適当なディレクトリでmvn archetype:generateを実行します。

.. code-block:: sh

   mvn archetype:generate

すると色んな雛形が一覧でずらーっと出てくるので使いたいものを番号で指定します。

今回はデフォルトの `maven-archetype-quickstart <http://repo1.maven.org/maven2/org/apache/maven/archetypes/maven-archetype-quickstart/>`_ を使用しますので数字は何も入力せず次に進みます。

maven-archetype-quickstart
のバージョンを尋ねられます。
既に最新が選択されているのでここも何も入力せず次に進みます。

ここから groupId、artifactId、version、そしてアプリケーションの
package
を尋ねられます。
適宜入力してそのまま進むと次のようなログが出て空のプロジェクトが作成されます。

.. code-block:: none

   [INFO] ----------------------------------------------------------------------------
   [INFO] Using following parameters for creating project from Old (1.x) Archetype: maven-archetype-quickstart:1.1
   [INFO] ----------------------------------------------------------------------------
   [INFO] Parameter: basedir, Value: /Users/backpaper0/src/temp
   [INFO] Parameter: package, Value: app
   [INFO] Parameter: groupId, Value: sample
   [INFO] Parameter: artifactId, Value: spring-boot-sample
   [INFO] Parameter: packageName, Value: app
   [INFO] Parameter: version, Value: 1.0-SNAPSHOT
   [INFO] ********************* End of debug info from resources from generated POM ***********************
   [INFO] project created from Old (1.x) Archetype in dir: /Users/backpaper0/src/temp/spring-boot-sample
   [INFO] ------------------------------------------------------------------------
   [INFO] BUILD SUCCESS
   [INFO] ------------------------------------------------------------------------
   [INFO] Total time: 55.560 s
   [INFO] Finished at: 2015-01-12T12:38:58+09:00
   [INFO] Final Memory: 14M/95M
   [INFO] ------------------------------------------------------------------------

作成されたファイルは次のような感じ。

*  ./pom.xml
*  ./src/main/java/app/App.java
*  ./src/test/java/app/AppTest.java

pom.xmlとHello, world!するだけのクラス(App.java)とassertTrue(true)するだけのテストクラス(AppTest.java)です。

App.java
と
AppTest.java
は要らないので消します。

それからpom.xmlを編集します。

mvn archetype:generateした直後の状態は次のような感じです。

.. code-block:: xml

   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
     <modelVersion>4.0.0</modelVersion>
   
     <groupId>sample</groupId>
     <artifactId>spring-boot-sample</artifactId>
     <version>1.0-SNAPSHOT</version>
     <packaging>jar</packaging>
   
     <name>spring-boot-sample</name>
     <url>http://maven.apache.org</url>
   
     <properties>
       <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
     </properties>
   
     <dependencies>
       <dependency>
         <groupId>junit</groupId>
         <artifactId>junit</artifactId>
         <version>3.8.1</version>
         <scope>test</scope>
       </dependency>
     </dependencies>
   </project>

これに
`リファレンスの10.1.1 Maven installation <http://docs.spring.io/spring-boot/docs/1.2.1.RELEASE/reference/htmlsingle/#getting-started-maven-installation>`_
を参考にして parent要素と dependency要素を追加しました。
あとついでにJUnitのバージョンを4.12に上げました。
それとmaven-compiler-pluginの設定を追加してJava 8でビルドされるようにしました。
んでもって、spring-boot-maven-pluginの設定を追加してスタンドアロンJARを作れるようにしました。

.. code-block:: xml

   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
     <modelVersion>4.0.0</modelVersion>
   
     <groupId>sample</groupId>
     <artifactId>spring-boot-sample</artifactId>
     <version>1.0-SNAPSHOT</version>
     <packaging>jar</packaging>
   
     <name>spring-boot-sample</name>
     <url>http://maven.apache.org</url>
   
     <properties>
       <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
     </properties>
   
     <parent>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-parent</artifactId>
       <version>1.2.1.RELEASE</version>
     </parent>
   
     <dependencies>
       <dependency>
         <groupId>org.twitter4j</groupId>
         <artifactId>twitter4j-core</artifactId>
         <version>4.0.2</version>
       </dependency>
       <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
       </dependency>
       <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-test</artifactId>
         <scope>test</scope>
       </dependency>
       <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-thymeleaf</artifactId>
       </dependency>
       <dependency>
         <groupId>junit</groupId>
         <artifactId>junit</artifactId>
         <version>4.12</version>
         <scope>test</scope>
       </dependency>
     </dependencies>
   
     <build>
       <plugins>
         <plugin>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-maven-plugin</artifactId>
         </plugin>
         <plugin>
           <groupId>org.apache.maven.plugins</groupId>
           <artifactId>maven-compiler-plugin</artifactId>
           <version>3.1</version>
           <configuration>
             <source>1.8</source>
             <target>1.8</target>
             <encoding>${project.build.sourceEncoding}</encoding>
           </configuration>
         </plugin>
       </plugins>
     </build>
   
   </project>

これで概ねハンズオンのpom.xmlに近くなったと思います。

今後の予定
--------------------------------------------------------------------------------

リファレンスには
`10.1.2 Gradle installation <http://docs.spring.io/spring-boot/docs/1.2.1.RELEASE/reference/htmlsingle/#getting-started-gradle-installation>`_
というのがあったのでGradle化してみたいですね。

それと
`spring-boot-starter-jersey <http://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-jersey/>`_
というのがあるっぽいのでSpring MVCをJAX-RSに置き換えるというのもやってみたいです。

……やらない雰囲気が漂っていますが気にしない方向で！

まとめ
--------------------------------------------------------------------------------

ひとのブログを写経しただけっていう他力本願がひどいブログ初めでした。

今年もよろしくお願い致します。

今日のコード
--------------------------------------------------------------------------------

* https://github.com/backpaper0/spring_boot_sample

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot, Maven
.. comments::
