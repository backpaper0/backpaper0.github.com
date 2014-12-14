Kotlinでstaticメソッドが定義できるようになったのでJAX-RSリベンジ
================================================================================

ことりん〜(挨拶)

これは `Kotlin Advent Calendar 2014 <http://www.adventar.org/calendars/477>`_
の14日目です。

夏の終わりに
:doc:`関西Kotlin勉強会 </2014/09/14/kotlinkansai>`
を開催し、私はKotlinでJAX-RSをやるという発表をしました。
JAX-RSにいくつかあるリクエストパラメータの受け取りかたのうち
「Stringの引数をひとつだけ受け取る”valueOf”という名前のstaticファクトリメソッドを持つクラス」
が実現できませんでした。
そのときのKotlinのバージョン(M7)ではstaticメソッドが定義できなかったからです。

* http://backpaper0.github.io/ghosts/kotlin-jaxrs.html#/16

しかしバージョンM9からplatformStaticアノテーションを使用してstaticメソッドを定義できるようになったようです。

* `Kotlin M9まとめ - 算譜王におれはなる!!!! <http://taro.hatenablog.jp/entry/2014/10/17/213252>`_

というわけでリベンジしました。
次のような感じで書けます。

.. code-block:: kotlin

   package app
   
   import kotlin.platform.platformStatic
   
   public class ValueObj private (val value: String) {
     class object {
       platformStatic fun valueOf(value: String) = ValueObj(value)
     }
   }

Kotlinの思想がどうあれJava言語、または既存のJavaライブラリとの共存を考慮するとstaticメソッドの
定義は必要だろうなーと思っていたのでこの機能追加は良いと思います。

個人的にはstaticファクトリメソッドを持つバリューオブジェクトを多用するので大変助かります。

おしまい。

今日のコード
--------------------------------------------------------------------------------

* https://github.com/backpaper0/sandbox の `kotlin-staticmethod-example` ディレクトリ

.. author:: default
.. categories:: none
.. tags:: Kotlin, JAX-RS
.. comments::
