セミコロンレスJavaでフィボナッチ
================================================================================

概要：ネタでしかない

セミコロンレスJavaとは
--------------------------------------------------------------------------------

以下を参照ください。

* `Semicolonless Java公式Wiki <http://seesaawiki.jp/w/semicolonlessjava/>`_
* `Javaでセミコロンなしでプログラムを書く - プログラマーの脳みそ <http://d.hatena.ne.jp/Nagise/20100321/1269182606>`_
* `Semicolonless Java8 - プログラマーの脳みそ <http://d.hatena.ne.jp/Nagise/20131111/1384170146>`_
* `セミコロンレスJavaはJava8の夢を見るか？ - bitter_foxの日記 <http://d.hatena.ne.jp/bitter_fox/20141022/1413947357>`_
* `セミコロンレスJavaはJava8の夢を見るか？～変数編～ - bitter_foxの日記 <http://d.hatena.ne.jp/bitter_fox/20141022/1413955082>`_

ある項のフィボナッチ数を書き出す
--------------------------------------------------------------------------------

結論から行きましょう。

ある項のフィボナッチ数を書き出すプログラムですが、こんなコードになりました。
うわ横に長え。

.. sourcecode:: java

   public class SemicolonlessFibonacci {
   
       public static void main(String[] args) {
           if (java.util.stream.Stream.<java.util.function.Function<F, F>> of(f -> n -> n <= 1 ? n : f.apply(n - 2) + f.apply(n - 1))
               .map(f -> ((java.util.function.Function<G, F>) (x -> f.apply(y -> x.apply(x).apply(y)))).apply(x -> f.apply(y -> x.apply(x).apply(y))))
               .map(fib -> fib.apply(Integer.parseInt(args[0])))
               .peek(System.out::println).findFirst().orElse(0) == 0) {
           }
       }
   
       interface F extends java.util.function.Function<Integer, Integer> {}
   
       interface G extends java.util.function.Function<G, F> {}
   }

これを ``SemicolonlessFibonacci.java`` という名前で保存して
``javac SemicolonlessFibonacci.java`` でコンパイルし、
``java -cp . SemicolonlessFibonacci 10`` というふうに実行してください。

引数をいろいろ変えて試すと標準出力にフィボナッチ数が書き出されることがお分かり頂けると思います。

やりたかったこと
--------------------------------------------------------------------------------

今回、実現したかったことはステートレスな再帰です。

セミコロンレスJavaでは戻り値をもつメソッドを定義できない( ``return`` にはセミコロンが必須のため )
という制限のためミュータブルなオブジェクトを引数にしてそれを更新することでメソッドの呼び出し元に値を戻すしかありません。
たぶん。

.. sourcecode:: java

   //戻り値のあるメソッドはreturnでセミコロン必要
   public int get() {
       return 0;
   }

   //ミュータブルな引数で値を戻す
   public void set(List<String> holder) {
       if (holder.add("hoge")) {}
   }

セミコロンレスJava 8からはラムダ式を使えば戻り値をもつ処理を定義できるようになりました。

.. sourcecode:: java

   if (Stream.<IntBinaryOperator> of((n, m) -> n + m) //二つのintを足して返す関数を定義
             .map(f -> f.applyAsInt(2, 3))            //関数適用
             .peek(System.out::println)               //出力
             .findFirst().isPresent()) {
   }

ですが、自身を再帰呼び出しすることはできません。

.. sourcecode:: java

   //これはセミコロンJava……ていうかJava
   IntUnaryOperator sum = n -> n == 0 ? 0 : n + sum(n - 1);
                                              //~~~ コンパイルエラー

Zコンビネータ
--------------------------------------------------------------------------------

これらの問題を解決するのがZコンビネータです。

* `不動点コンビネータ - Wikipedia <http://ja.wikipedia.org/wiki/%E4%B8%8D%E5%8B%95%E7%82%B9%E3%82%B3%E3%83%B3%E3%83%93%E3%83%8D%E3%83%BC%E3%82%BF#Z.E3.82.B3.E3.83.B3.E3.83.93.E3.83.8D.E3.83.BC.E3.82.BF>`_

この辺は全然詳しくないんですがラムダ計算で再帰を行うことが出来るアレっぽいです。
きしださんのエントリも参考にさせて頂きました。

* `おとうさん、ぼくにもYコンビネータがわかりましたよ！ - きしだのはてな <http://d.hatena.ne.jp/nowokay/20090409>`_

再帰するにはYコンビネータというのもあるようですが正格評価戦略の言語ではスタックオーバーフローになるっぽいです。
ていうかなりました。

というわけでZコンビネータです。
その定義は次の通りです。

.. sourcecode:: none

   Z = λf. (λx. f (λy. x x y)) (λx. f (λy. x x y))

これをJavaで書くとこんな感じになりました。

.. sourcecode:: java

   static F z(Function<F, F> f) {
       Function<G, F> a = x -> f.apply(y -> x.apply(x).apply(y));
       G b = x -> f.apply(y -> x.apply(x).apply(y));
       return a.apply(b);
   }

   interface F extends Function<Integer, Integer> {}

   interface G extends Function<G, F> {}

このzメソッドを用いてフィボナッチ数を求める処理を再帰で書いたのが次になります。

.. sourcecode:: java

   Function<F, F> g = f -> n -> n <= 1 ? n : f.apply(n - 2) + f.apply(n - 1);
                                           //~~~~~~~~~~~~~~   ~~~~~~~~~~~~~~ この辺が再帰

   F fib = z(g);

   System.out.println(fib.apply(11)); //11番目のフィボナッチ数を出力する

あとはセミコロンを消す為になんやかんやいろいろやって一番最初のコードになりました。

まとめ
--------------------------------------------------------------------------------

Java 8時代になりセミコロンレスJavaでも再帰を使えるようになりました。
これによりセミコロンレスJava 8が秘めたる可能性を更に感じる事ができました。

今回は末尾再帰最適化まで考える力は残っていませんでしたが、
`「Javaによる関数型プログラミング」 <http://www.oreilly.co.jp/books/9784873117041/>`_
の7章を参考にすればなんとかなるかもしれません。
ならないかもしれません。

みなさんもセミコロンレスJavaをはじめてみませんか？
みませんね。
はい、ごめんなさい。

続き： :doc:`/2014/11/03/semicolonless_java_fibonacci_without_z_combinator`

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
