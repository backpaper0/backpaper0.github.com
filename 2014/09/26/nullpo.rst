ぬるぽ
===========

あなたとぬるぽ。

拡張forループ
----------------

.. code-block:: java

   int[] xs = null;
   for (int x : xs) {
   }

配列・リストが `null` なら拡張forループでぬるぽっ！

アンボクシング
--------------------

.. code-block:: java

   Integer x = null;
   int y = x;

プリミティブラッパーをプリミティブにアンボクシングするときにぬるぽっ！

普通に数字の足し算とかしててぬるぽが出たらこれを疑います。

throw
-----------

.. code-block:: java

   UnsupportedOperationException e = null;
   throw e;

`null` を `throw` したら投げられる例外はぬるぽっ！

String switch
----------------

.. code-block:: java

   String x = null;
   switch (x) {
   }

`String` のswitch文でぬるぽっ！

try with resources
--------------------

.. code-block:: java

   try (AutoCloseable x = null) {
   }

try with resourcesで `AutoCloseable` が `null` なら `close` するときにぬるぽっ！には **ならない** 。

`close` の前に `null` チェックするようにコンパイルされます。

コンストラクタ
----------------

.. code-block:: java

   new Hoge(a -> a.x.length());

何の変哲も無いコンストラクタですが、ぬるぽっ！になるケースがあります。

.. code-block:: java

    class Hoge {

        final String x;

        public Hoge(Consumer<Hoge> c) {
            c.accept(this);
            this.x = "hoge";
        }
    }

フィールド `x` はfinalなのにぬるぽになるというアレです。
コンストラクタ終わってないインスタンスはメソッドに渡さないでおきましょー。

メソッド実行
----------------

.. code-block:: java

   Hoge x = null;
   x.foobar();

ぬるぽっ！ **にはならないケースがあります** 。

これ。

.. code-block:: java

    class Hoge {

        static void foobar() {
        }
    }

まあ実際はこんなコードに出会うことは無いでしょう。

無いでしょう。

本日のコード
------------------

* `NullPo.java <https://github.com/backpaper0/sandbox/blob/master/garakuta/src/test/java/NullPo.java>`_

.. author:: default
.. categories:: none
.. tags:: Java
.. comments::
