セミコロンレスJava 8の新機能「enumにメソッド生やす」 #semicolonlessjava
================================================================================

これは
`セミコロンレスJava Advent Calendar 2015 <http://www.adventar.org/calendars/952>`_
の5日目です。

レガシーセミコロンレスJavaにおけるenumの制限
--------------------------------------------------

Java言語ではenumにメソッドを生やす事ができます。

.. sourcecode:: java

   //これはセミコロンを付けても良いありふれた普通のJavaコード
   public enum Hoge {
       FOO, BAR, BAZ;

       public void println() {
           System.out.println(name());
       }
   }

しかしメソッドを定義するためには一番最後に宣言した列挙定数(上記の例でいうと
``BAZ``
)の後ろにセミコロンをつける必要があります。

これは回避できない制約なのでセミコロンレスJavaではenumにメソッドは生やせませんでした。

セミコロンレスJava 8におけるenumの新機能
--------------------------------------------------

しかし、Java 8でインターフェースにデフォルトメソッドを持てるようになり、
その副次効果でセミコロンレスJava 8ではenumにメソッドを生やす事が出来るようになりました。

手順は簡単で、デフォルトメソッドを定義したインターフェースを用意してenumでそれをimplementsするだけです。

コード例を示します。

.. sourcecode:: java

   public enum Hoge implements Fuga {
      FOO, BAR, BAZ
   }
   
   public interface Fuga {
       default void println() {
           if (System.out.printf("%s%n", ((Hoge) this).name()) != null) {}
       }
   }

enumの列挙定数や他のメソッドにアクセスしたい場合はキャストすればOKです。

まとめ
--------------------------------------------------

* enumにメソッドを生やせるようになり、ますますセミコロンレスJavaが便利に！

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
