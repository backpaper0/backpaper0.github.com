KotlinではじめるJAX-RS
========================

こっとりーん！（挨拶）

説明はもろもろすっ飛ばしてリソースクラスのコード掲載します。

.. sourcecode:: kotlin

   package app
   
   import javax.ws.rs.core.MediaType
   import javax.ws.rs.GET
   import javax.ws.rs.Path
   import javax.ws.rs.Produces
   import javax.ws.rs.QueryParam as q
   
   Path("hello")
   Produces(MediaType.TEXT_PLAIN)
   class Hello {
   
       GET fun get(q("name") name: String): String = "Hello, ${name}!"
   }

という感じで普通にJAX-RSできました。

というかnameがnull許容しないので@DefaultValueを付けるべきと今思いましたので気が向いたら直しておきます（やらないパターン）。

サンプルが簡易すぎてKotlinの良さが出ていないのが悲しいですね。

良かった点。

* Mavenで簡単にビルドできた
* MavenプロジェクトをIntellij IDEAで容易くインポートできた
* `たろーさん <https://twitter.com/ngsw_taro/>`_ とTwitterで絡めた

微妙な点。

* Intellij IDEAのKotlinプラグインのOrganize Importが弱い気がする
* Intellij IDEAのコードフォーマットが :kbd:`option + command + l` で両手使うのがやだ
* Intellij IDEAで :kbd:`command + w` でファイルが閉じてくれなかった

そんな感じです。
要するにIntellij IDEAに慣れていないだけ、と。

それと `テストクラス <https://github.com/backpaper0/sandbox/tree/master/kotlin-jaxrs-example/blob/master/src/test/java/app/HelloTest.java>`_ はJavaで書いていますが、これはアノテーション付きのstaticメソッドの書き方が分からなかったからです。
きっと誰かがKotlinに直してプルリクしてくれるに違いない(ﾁﾗｯ

本日のコードはGitHubにあります。
`Arquillian <http://arquillian.org/>`_ のwildfly-managedでテスト書いてます。
テスト実行すると多くのJARと `WildFly 8.1.0.Final <http://www.wildfly.org/>`_ をダウンロードするので時間のあるときにどうぞ。

* `kotlin-jaxrs-example <https://github.com/backpaper0/sandbox/tree/master/kotlin-jaxrs-example>`_

Kotlinの勉強会もあるみたいですよ。

* `第2回 かわいいKotlin勉強会 #jkug <http://www.zusaar.com/event/12417003>`_

.. author:: default
.. categories:: none
.. tags:: JAX-RS, Kotlin
.. comments::
