「Javaによる関数型プログラミング」読んだ
============================================

さくらばさんに献本して頂きました。
ありがとうございます！

* `Javaによる関数型プログラミング――Java 8ラムダ式とStream <http://www.oreilly.co.jp/books/9784873117041/>`_

物理的に薄い本ですし、ラムダ式と関数型プログラミングへの入門として良い本だと思います。
チームの後輩に読んで欲しい。

関数型プログラミングへの入門に丁度いいということで、数年前にコップ本で入門を済ませていた私としては少々物足りない気がしました。
ただし7章は末尾再帰の最適化を行うという内容で、そこはJavaコンパイラはサポートしていない部分なので興味深く読みました。
恥ずかしながら、末尾再帰の最適化を自分で書くという発想は無かったので参考になります。

以下、気になった点を挙げます。
タイポも含む。

* 2〜3ページ。宣言的なコードとはどういうことかを、
  いきなりラムダ式を登場させるのではなくJava 7までの語彙で説明しているのが良いですね。

* 28ページの例2-7。
  これメソッド参照になっていないのでコンパイルエラーですね。

* 70ページ。
  
    JDKの新しい ClosableStream インターフェース

  とありますが、そのようなクラスはありません。

  リリース前にはあったようですが `be6ca7197e0e <http://hg.openjdk.java.net/jdk8/jdk8/jdk/rev/be6ca7197e0e>`_ あたりで削除されました。
  ちなみに ClosableStream じゃなくて Clos\ **e**\ ableStream でした。
  
* 89ページの例4-17。
  コードを引用します。

    .. code-block:: java

       try {
         final URL url = 
           new URL("http://ichart.finance.yahoo.com/table.csv?s=" + ticker);

         final BufferedReader reader = 
           new BufferedReader(new InputStreamReader(url.openStream()));
         final String data = reader.lines().skip(1).findFirst().get();
         final String[] dataItems = data.split(",");
         return new BigDecimal(dataItems[dataItems.length - 1]);      
       } catch(Exception ex) {
         throw new RuntimeException(ex);
       }
 
  これ、readerがcloseされていません。 
  readerをtry-with-resourcesで囲むべきと思います。

  .. code-block:: java
     :emphasize-lines: 5,6,10

     try {
       final URL url = 
         new URL("http://ichart.finance.yahoo.com/table.csv?s=" + ticker);

       try(final BufferedReader reader = 
           new BufferedReader(new InputStreamReader(url.openStream()))) {
         final String data = reader.lines().skip(1).findFirst().get();
         final String[] dataItems = data.split(",");
         return new BigDecimal(dataItems[dataItems.length - 1]);      
       }
     } catch(Exception ex) {
       throw new RuntimeException(ex);
     }

  * 参考： `StreamはAutoCloseableであると認識していないとアレな件 - mike-neckのブログ <http://mike-neck.hatenadiary.com/entry/2014/10/12/133434>`_

* 130〜135ページのインスタンス化の遅延。
  面白いアプローチですが最終的に出来上がったコードは少々分かりにくかったし、synchronizedを使っていたのでConcurrency Utilitiesでもうちょっと良い感じに書けるんじゃ？
  と思い色々考えた挙げ句、次のようなコードを書いてみましたがたいして分かりやすくなりませんでした_(:3｣∠)_

  .. code-block:: java

     import java.util.concurrent.ExecutionException;
     import java.util.concurrent.FutureTask;
     import java.util.concurrent.atomic.AtomicReference;
     
     public class HoderNaive {
     
         private final AtomicReference<FutureTask<Heavy>> heavy = new AtomicReference<>();
     
         public Heavy getHeavy() {
             if (heavy.compareAndSet(null, new FutureTask<>(Heavy::new))) {
                 heavy.get().run();
             }
             try {
                 return heavy.get().get();
             } catch (InterruptedException e) {
                 Thread.currentThread().interrupt();
                 throw new RuntimeException(e);
             } catch (ExecutionException e) {
                 throw new RuntimeException(e.getCause());
             }
         }
     }

* 161ページ。

    正しい5の階乗と、120の階乗の一部

  120ではなく20000の階乗ですね。

まとめ
--------------------------------------------------------------------------------

関数型プログラミングにまったく触れたことがない人や若手にJava 8を教える立場にある人にはおすすめです。

コップ本を読んだ程度には関数型プログラミングに触れたことがある人は7章だけ読みましょう。

.. author:: default
.. categories:: none
.. tags:: Java, BookReview
.. comments::
