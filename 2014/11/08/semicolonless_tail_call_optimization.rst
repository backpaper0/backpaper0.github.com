セミコロンレスJavaで末尾再帰の最適化
================================================================================

:doc:`前回 </2014/11/03/semicolonless_java_fibonacci_without_z_combinator>`
はセミコロンレスJavaで再帰ができる事が分かりました。

ただし再帰しすぎるとスタックオーバーフローでしにます。

再帰による `1 + 2 + ... + n` を見てみましょう。

.. code-block:: java

   public class SemicolonlessRecursion {

       public static void main(String[] args) {
           if (java.util.stream.Stream
               .of(Integer.parseInt(args[0]))
               .flatMap(n -> java.util.stream.Stream
               .<F<Integer, Integer>> of((f, m) -> m < 1 ? 0 : m + f.apply(f, m - 1))
               .map(sum -> sum.apply(sum, n)))
               .peek(System.out::println)
               .count() > 0) {
           }
       }

       interface F<P, R> extends java.util.function.BiFunction<F<P, R>, P, R> {}
   }

とっても分かりやすいコードですが `n` に `10000` 程度を与えただけでスタックオーバーフローになります。

この再帰を末尾再帰にして最適化を行うのが今回の目的です。

普通のJavaで末尾再帰最適化
--------------------------------------------------------------------------------

最初からセミコロンレスJavaで考えてもしんどいだけなので、
まずは普通のJavaで末尾再帰最適化版のコードを書いてみます。
実装するに当たって
`「Javaによる関数型プログラミング」 <http://www.oreilly.co.jp/books/9784873117041/>`_
の7章を参考にしました。

.. code-block:: java

   import java.util.Optional;
   import java.util.stream.Stream;
   
   public class TailCallOptimization {
   
       public static void main(String[] args) {
           int n = Integer.parseInt(args[0]);
   
           F sum = (f, p, r) -> p < 1 ? done(r) : call(() -> f.apply(f, p - 1, r + p));
   
           TailCall t = sum.apply(sum, n, 0);
   
           Integer result = Stream.iterate(t, TailCall::get)
                                  .map(TailCall::result)
                                  .filter(Optional::isPresent)
                                  .map(Optional::get)
                                  .findFirst()
                                  .get();
   
           System.out.println(result);
       }
   
       interface F {
   
           TailCall apply(F f, Integer p, Integer r);
       }
   
       static TailCall call(TailCall t) {
           return t;
       }
   
       static TailCall done(Integer result) {
           return new TailCall() {
   
               @Override
               public TailCall get() {
                   throw new UnsupportedOperationException();
               }
   
               @Override
               public Optional<Integer> result() {
                   return Optional.of(result);
               }
           };
       }
   
       interface TailCall {
   
           TailCall get();
   
           default Optional<Integer> result() {
               return Optional.empty();
           }
       }
   }

多少セミコロンレスJavaへの変換を意識していますが普通のJavaです。
これをセミコロンレスJavaにしていきます。

セミコロンレス化の布石
--------------------------------------------------------------------------------

Java 8時代におけるセミコロンレスJavaの鍵はラムダ式だと思っています。
値を返すメソッドの定義が出来ないセミコロンレスJavaですが、
ラムダ式を使う事でセミコロンレスに関数を定義する事が可能です。

.. code-block:: java

   //ふたつのintを足して返す関数を定義して2, 3に適用する
   if (java.util.stream.Stream
       .<java.util.function.BinaryOperator<Integer>> of((a, b) -> a + b)
       .map(add -> add.apply(2, 3))
       .peek(System.out::println)
       .count() > 0) {
   }

ラムダ式を使う為に必要となるのは関数型インターフェースです。
セミコロンレスJavaではインターフェースの定義は出来ますが、その中でメソッド定義が出来ません。
ただし、幸いにもJavaの標準APIには関数型インターフェースが豊富に用意されているので
それらをextendsすることで用途に特化した関数型インターフェースを手に入れる事ができます。

まず `TailCall` を関数型インターフェースにする事から始めましょう。
ここでの課題は `get()` と `result()` の一本化です。
今のままではどうしても匿名クラスを導入する必要があります。

`TailCall` と `Optional<Integer>` の `Pair` を返す `Supplier` とすることで
`TailCall` を関数型インターフェースにできました。

.. code-block:: java

   interface TailCall extends Supplier<Pair<TailCall, Optional<Integer>>>{}

これにより `done(Integer)` が返す値を匿名クラスではなくラムダ式で書けるようになりました。

.. code-block:: java

   static TailCall done(Integer result) {
       return () -> new Pair<>(null, Optional.of(result));
   }

また `call(TailCall)` は次のように変更します。

.. code-block:: java

   static TailCall call(Supplier<TailCall> t) {
       return () -> new Pair<>(t.get(), Optional.empty());
   }

こうすることで関数 `sum` は次のように書けます。

.. code-block:: java

   F sum = (f, p, r) -> p < 1 ? done(r) : call(() -> f.apply(f, p - 1, r + p));

それから結果を求める `Stream` 操作ですが、
普通の再帰版では `TailCall` の `get()` を呼び出すことで `Stream`
を構築していましたが `get()` が `Pair<TailCall, Optional<Integer>>` 
を返すようにしたので、
`Pair<TailCall, Optional<Integer>>` の `Stream` を構築するようにします。

.. code-block:: java

   Stream.iterate(new Pair<>(t, Optional.<Integer> empty()),
                  p -> p.getKey().get())
         .map(Pair::getValue)
         .filter(Optional::isPresent)
         .map(Optional::get)
         .findFirst()
         .get();

ここまでのコード全体を次に記載します。

.. code-block:: java

   import java.util.Optional;
   import java.util.function.Supplier;
   import java.util.stream.Stream;
   
   import javafx.util.Pair;
   
   public class TailCallOptimization {
   
       public static void main(String[] args) {
           int n = Integer.parseInt(args[0]);
   
           F sum = (f, p, r) -> p < 1 ? done(r) : call(() -> f.apply(f, p - 1, r + p));
   
           TailCall t = sum.apply(sum, n, 0);
   
           Integer result = Stream.iterate(new Pair<>(t, Optional.<Integer> empty()),
                                           p -> p.getKey().get()).map(Pair::getValue)
                                  .filter(Optional::isPresent)
                                  .map(Optional::get)
                                  .findFirst()
                                  .get();
   
           System.out.println(result);
       }
   
       interface F {
   
           TailCall apply(F f, Integer p, Integer r);
       }
   
       static TailCall call(Supplier<TailCall> t) {
           return () -> new Pair<>(t.get(), Optional.empty());
       }
   
       static TailCall done(Integer result) {
           return () -> new Pair<>(null, Optional.of(result));
       }
   
       interface TailCall extends Supplier<Pair<TailCall, Optional<Integer>>> {}
   }

そしてセミコロンレスへ……
--------------------------------------------------------------------------------

あとはちょっとずつまとめたりなんやかんやしてセミコロンレスJavaに変更していきます。

というわけでセミコロンレスJavaで末尾再帰最適化を行ったコードが次になります。

.. code-block:: java

   public class SemicolonlessTailCallOptimization {
   
       public static void main(String[] args) {
           if (java.util.stream.Stream
               .of(Integer.parseInt(args[0]))
               .flatMap(n -> java.util.stream.Stream
               .<F> of((f, pr) -> pr[0] < 1
                   ? () -> new javafx.util.Pair<>(null, java.util.Optional.of(pr[1]))
                   : () -> new javafx.util.Pair<>(f.apply(f, new int[] { pr[0] - 1, pr[1] + pr[0] }), java.util.Optional.empty()))
               .<TailCall> map(sum -> sum.apply(sum, new int[] { n, 0 })))
               .map(t -> java.util.stream.Stream
               .iterate(new javafx.util.Pair<>(t, java.util.Optional.<Integer> empty()), p -> p.getKey().get())
               .map(javafx.util.Pair::getValue)
               .filter(java.util.Optional::isPresent)
               .map(java.util.Optional::get)
               .findFirst()
               .get())
               .peek(System.out::println)
               .count() > 0) {
           }
       }
   
       interface F extends java.util.function.BiFunction<F, int[], TailCall> {}
   
       interface TailCall extends java.util.function.Supplier<javafx.util.Pair<TailCall, java.util.Optional<Integer>>> {}
   }

まとめ
--------------------------------------------------------------------------------

セミコロンレスJavaでも末尾再帰の最適化が出来る事が分かりました。
これによりセミコロンレスJavaがまた一歩、実用的な言語へと近づいたと思われます。

なお、今回は `javax.util.Pair` を使用しましたが、これが大変便利でした。
特にふたつの値を返す場合に今までは配列あたりを使用していたのでキャストが必須になっていましたが、
`Pair` があればキャストも不要でコードがすっきりしました。
また、ふたつ以上の値を返す場合は `Pair<T, Pair<U, V>>` などとすれば良いですね。

というわけでこれからもセミコロンレスJavaの可能性を探って行きたいと思います。

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
