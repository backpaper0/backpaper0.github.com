Gradleプラグインを書いて公開しちゃった
==================================================

きっかけ
--------------------------------------------------

JAX-RSでWebフォントなどの静的リソースを返すリソースメソッドを書いたんですが、
ETagを使ってキャッシュをアレして転送量を節約したくなりました。

で、ETagにはMD5ハッシュ値を使ってたんですが毎回ハッシュ値を計算するのはあほくさいので、
ビルド時に計算してファイルに保存しておく事にしました。

その際にGradleプラグインを書いて、
どうせならと思って https://plugins.gradle.org/ で公開する事にしました。

Gradleプラグインを書く
--------------------------------------------------

次の公式ドキュメント(の日本語訳)を参考にすればオッケー！

* `第58章 カスタムタスクの作成 <http://gradle.monochromeroad.com/docs/userguide/custom_tasks.html>`_
* `第59章 カスタムプラグインの作成 <http://gradle.monochromeroad.com/docs/userguide/custom_plugins.html>`_

Gradleプラグインを公開する
--------------------------------------------------

`How do I add my plugin to the plugin portal? <https://plugins.gradle.org/docs/submit>`_
の通りに進めていけばオッケー！

ざっくり書くと、
まず `アカウントを作って <https://plugins.gradle.org/user/register>`_ 、
自分のページでAPI Keyを作って、
それを `~/.gradle/gradle.properties` に書いて、
`build.gradle` へ `Plugin Publishing Plugin <https://plugins.gradle.org/docs/publish-plugin>`_
の設定を書いて、
``gradle publishPlugins`` で公開します。

Gradleプラグインを書くときに知ってて良かったこと
--------------------------------------------------

知ってて良かったことっていうかGroovyの文法なんですけど、
次のようなことを知ってたらわりとスムーズにプラグインを書けました。

* アクセサメソッドはフィールドアクセスのように書ける。

  * 例えば ``foo.getBar()`` は ``foo.bar`` と書ける。
  * そして ``foo.setBar(baz)`` は ``foo.bar = baz`` と書ける。

* メソッド呼び出しで最後の引数がクロージャだと括弧の外に出せる。
  つまり ``foo(bar, { x -> ... })`` は ``foo(bar) { x -> ... }`` と書けて組み込みの構文のようにできる。

* 引数がMapなら ``foo(bar: "...", baz: 123)`` みたいに書ける。

* 展開演算子。
  ``['hoge', 'foo', 'x'].collect { it.length() }``
  を
  ``['hoge', 'foo', 'x']*.length()``
  と書ける。

* ``leftShift`` という名前のメソッドは ``<<`` と書ける。
  タスクを定義するときの ``task hoge << { ... }`` は
  `Task.leftShiftメソッド <https://docs.gradle.org/current/javadoc/org/gradle/api/Task.html#leftShift(groovy.lang.Closure)>`_
  です。

Gradleプラグインを書くにあたって参考にしたもの
--------------------------------------------------

最初に挙げた公式ドキュメントの日本語訳はもちろん参考にしましたが、
他に
`GradleのAPIドキュメント <https://docs.gradle.org/current/javadoc/>`_
が参考になりました。

特に次のクラスのドキュメントをよく読んだ気がします。

* `Project <https://docs.gradle.org/current/javadoc/org/gradle/api/Project.html>`_
* `TaskContainer <https://docs.gradle.org/current/javadoc/org/gradle/api/tasks/TaskContainer.html>`_
* `Task <https://docs.gradle.org/current/javadoc/org/gradle/api/Task.html>`_

それから `Gradleのソースコード <https://github.com/gradle/gradle>`_
も参考になりました。
特に
`JavaPlugin <https://github.com/gradle/gradle/blob/master/subprojects/plugins/src/main/groovy/org/gradle/api/plugins/JavaPlugin.java>`_
や
`WarPlugin <https://github.com/gradle/gradle/blob/master/subprojects/plugins/src/main/groovy/org/gradle/api/plugins/WarPlugin.java>`_
を参考にしました。

まとめ
--------------------------------------------------

Gradleプラグインは書くのも公開するのもお手軽っぽいので、
これを読んで良いなと思ったらチャレンジしてみてくれさい！

ちなみに、こちらが私が書いたプラグインですどうぞ！

* `gradle hash plugin <https://github.com/backpaper0/gradle-hash-plugin>`_

.. author:: default
.. categories:: none
.. tags:: Gradle
.. comments::
