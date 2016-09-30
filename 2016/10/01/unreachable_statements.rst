セミコロンレスJavaで戻り値のあるメソッドを定義する(ただし返ってこない)の解説
==================================================================================

.. raw:: html

   <blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">セミコロンレスJavaで戻り値のあるメソッドを定義する(ただし返ってこない) <a href="https://t.co/OQfRPvQWlN">https://t.co/OQfRPvQWlN</a></p>&mdash; うらがみ⛄ (@backpaper0) <a href="https://twitter.com/backpaper0/status/702826568838610944">2016年2月25日</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

これがなぜコンパイルを通るのか？という疑問を見かけたので解説してみます。

到達不能文
------------------------------

例えば ``while(false) { ... }`` とした時、この ``while`` ブロック内の文は絶対に実行されません。
このように絶対に実行されない文を **到達不能** と表現し、到達不能な文がある場合はコンパイルエラーになります。

次のような内容で ``Sample1.java`` を作成して ``javac`` してみてください。

.. code-block:: java

   public class Sample1 {
       public void whileSample() {
           while(false) {
               System.out.println("到達不能！");
           }
       }
   }

次のようなエラーになります。

.. code-block:: none

   Sample1.java:3: エラー: この文に制御が移ることはありません
           while(false) {
                        ^
   エラー1個

``for`` 文でも同じ事ができます。

.. code-block:: java

   public class Sample2 {
       public void forSample() {
           for(;false;) {
               System.out.println("到達不能！");
           }
       }
   }

.. code-block:: none

   Sample2.java:3: エラー: この文に制御が移ることはありません
           for(;false;) {
                        ^
   エラー1個

``try`` 文はエラーメッセージは違いますが、次のようコードは到達不能な文を含むのでコンパイルエラーになります。

.. code-block:: java

   public class Sample3 {
       public void trySample() {
           try {
               System.out.println("到達可能");
           } catch(RuntimeException e) {
               System.out.println("到達可能");
           } catch(IllegalArgumentException e) {
               System.out.println("到達不能！");
           }
       }
   }

.. code-block:: none

   Sample3.java:7: エラー: 例外IllegalArgumentExceptionはすでに捕捉されています
           } catch(IllegalArgumentException e) {
             ^
   エラー1個

特別扱いの ``if``
------------------------------

ここまで ``while`` 、 ``for`` 、 ``try`` の到達不能な文を含むコードがコンパイルエラーになる例を見てきました。
``if`` 文でも同じような事ができるかと思いきや、次のコードはコンパイルできてしまいます。

.. code-block:: java

   public class Sample4 {
       public void ifSample() {
           if(false) {
               System.out.println("到達不能！");
           }
       }
   }

到達不能な文を含んだ ``if`` 文はどのようにコンパイルされたのか、 ``javap -c Sample4`` して確認してみましょう。

.. code-block:: none

   Compiled from "Sample4.java"
   public class Sample4 {
     public Sample4();
       Code:
          0: aload_0
          1: invokespecial #1                  // Method java/lang/Object."<init>":()V
          4: return
   
     public void ifSample();
       Code:
          0: return
   }

ご覧の通り、 ``if`` 文が綺麗さっぱり消えていますね。

では、 ``if`` の条件式を ``true`` に変えてコンパイルして ``javap`` してみましょう。
（クラス名などは少し変えてあります）

.. code-block:: none

   Compiled from "Sample5.java"
   public class Sample5 {
     public Sample5();
       Code:
          0: aload_0
          1: invokespecial #1                  // Method java/lang/Object."<init>":()V
          4: return
   
     public void ifSample();
       Code:
          0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
          3: ldc           #3                  // String 到達可能
          5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
          8: return
   }

``if`` 文の中身はありますが、条件を評価している部分がなくなりました。 

``if`` がこのように特別扱いになっているのは、次のようなコードを書けるようにするためです。

.. code-block:: java

   static final boolean DEBUG = true;

   void sample() {
       if(DEBUG) { System.out.println("logging"); }
   }

先述の特徴があるので、定数 ``DEBUG`` が ``true`` ならロギングされるけども、
``false`` ならロギングのコードがクラスファイルからも消える、という感じです。

``return`` を書かずに戻り値のあるメソッドを定義する
------------------------------------------------------------

``return`` 文にはどうしてもセミコロンを書く必要があります。
それが故にセミコロンレスJavaでは戻り値のあるメソッドを定義することはできないと考えられていました。

私も「どのようにすればセミコロンを省略して ``return`` が書けるのか」と考えては挫折を繰り返してきましたが、
あるとき「セミコロンを省略して ``return`` が書けないなら、そもそも ``return`` を書かなければ良いのでは」と発想の転換をしてみました。

前半で述べた通り、到達不能な文を含むとコンパイルエラーになります。
逆に考えると、無限ループは到達可能なのでコンパイルを通るし、無限ループの後ろは到達不能なので何を書いてもコンパイルエラーになる、ということですね。

.. code-block:: java

   while(true) {
       //到達可能
   }
   //到達不能

これにより冒頭に記載したツイートの通り、セミコロンを書かずに戻り値のあるメソッドを定義できました。

.. code-block:: java

   public class Semicolonless {
   
       String get() {
           while (true) {
           }
       }
   }

ちなみにセミコロンはともかく、 ``return`` を書かずに戻り値のあるメソッドを定義する方法としては例外を投げるというのもあります。
（例えば ``Thread.destroy()`` ）

戻り値のあるメソッドに ``return`` 文なんて要らんかったんや！！！

まとめ
------------------------------

* 一見不可能に思えることでも考え方を変えることで解決する場合がある
* とはいえ解決したところで役に立たないものもある

参考
------------------------------

* `前半に記載した到達不能コードたち <https://github.com/backpaper0/sandbox/tree/master/unreachable-statements>`_
* `Java Language Specification 14.21. Unreachable Statements <https://docs.oracle.com/javase/specs/jls/se8/html/jls-14.html#jls-14.21>`_
* `戻ってくるようになりました <https://twitter.com/backpaper0/status/705763807964991488>`_

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
