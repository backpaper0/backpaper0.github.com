ボクシングとキャッシュ
================================================================================

Integerのキャッシュ
------------------------------------------------------------

``int`` がボクシングされると ``java.lang.Integer`` になりますが、このとき ``Integer.valueOf(int)`` が使われます。
このことは次のようなボクシングされるコードを書いてコンパイルしてからjavapすればよく分かります。

.. code-block:: java

   public class IntBoxingSample {
       public Integer boxing(int i) {
           return i;
       }
   }

javapしてみた結果は次の通り。

.. code-block:: none

   Compiled from "IntBoxingSample.java"
   public class IntBoxingSample {
     public IntBoxingSample();
       Code:
          0: aload_0
          1: invokespecial #1                  // Method java/lang/Object."<init>":()V
          4: return
   
     public java.lang.Integer boxing(int);
       Code:
          0: iload_1
          1: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          4: areturn
   }

で、この ``Integer.valueOf(int)`` ですが、 ``-128`` から ``127`` までの範囲はキャッシュされます。

このことは `言語仕様の5.1.7 <https://docs.oracle.com/javase/specs/jls/se8/html/jls-5.html#jls-5.1.7>`_ や
`Integer.valueOf(int)のJavadoc <https://docs.oracle.com/javase/jp/8/docs/api/java/lang/Integer.html#valueOf-int->`_ に書かれています。

でもって、OpenJDKのコードを見た感じ、 ``java.lang.Integer.IntegerCache.high`` というシステムプロパティでキャッシュする範囲を変更できそうです。

* `Integer.valueOf(int)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Integer.java#l829>`_
* `Integerインスタンスをキャッシュする範囲を決定しているstaticイニシャライザ <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Integer.java#l785>`_

というわけで次のようなコードを書いてコンパイルして普通に実行すると ``false`` と表示されますが、 ``-Djava.lang.Integer.IntegerCache.high=1000`` という風にシステムプロパティを設定して実行すると ``true`` と表示されます。

.. code-block:: java

   public class Sample {
       public static void main(String[] args) {
           Integer a = 1000;
           Integer b = 1000;
           System.out.println(a == b);
       }
   }

実行結果は次の通り。

.. code-block:: bash

   % java Sample
   false
   % java -Djava.lang.Integer.IntegerCache.high=1000 Sample
   true

他のプリミティブも見てみた
------------------------------------------------------------

``Byte`` 、 ``Short`` 、 ``Long`` は ``Integer`` と同じく ``-128`` から ``127`` までキャッシュされていました。
ただしキャッシュの範囲は変更できません。

* `Byte.valueOf(byte)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Byte.java#l101>`_ と
  `Byteのキャッシュ構築コード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Byte.java#l77>`_
* `Short.valueOf(short)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Short.java#l230>`_ と
  `Shortのキャッシュ構築コード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Short.java#l203>`_
* `Long.valueOf(long)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Long.java#l835>`_ と
  `Longのキャッシュ構築コード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Long.java#l806>`_

それから ``Character`` は ``0`` から ``127`` までキャッシュされていました。
ASCII文字コードの ``NUL`` から ``DEL`` ですね。

* `Character.valueOf(char)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Character.java#l4569>`_ と
  `Characterのキャッシュ構築コード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Character.java#l4541>`_

``Boolean`` は定数 ``TRUE`` と ``FALSE`` のどちらかを返すようになっています。

* `Boolean.valueOf(boolean)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Boolean.java#l149>`_

最後に ``Float`` と ``Double`` ですが、どちらもキャッシュせず常にインスタンス化するようになっていました。
浮動小数点数なので ``-128.0`` から ``127.0`` の間にも膨大な量のインスタンスを生成し得るので、まあ、そりゃキャッシュしないか、という感じ。

* `Float.valueOf(float)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Float.java#l432>`_
* `Double.valueOf(double)のコード <http://hg.openjdk.java.net/jdk8u/jdk8u/jdk/file/dc4322602480/src/share/classes/java/lang/Double.java#l518>`_

まとめ
------------------------------------------------------------

以上のように普段は意識しないような部分でキャッシュしておりパフォーマンス向上を図っていたりしています。
こういったJDKの努力に感謝しつつ、今後も意識せずにコーディングしようと思います。

.. author:: default
.. categories:: none
.. tags:: Java
.. comments::
