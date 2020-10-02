セミコロンなどレスJavaでFizzBuzz #semicolonlessjava
================================================================================

これは `セミコロンレスJava Advent Calendar <http://www.adventar.org/calendars/952>`_
の9日目です。

セミコロンレスJava 8でFizzBuzz
--------------------------------------------------

セミコロンレスJava 8でFizzBuzzを書いてみましょう。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String[] args) {
           if (java.util.stream.Stream
                   .of(java.util.stream.IntStream.rangeClosed(1, 100)
                   .mapToObj(i -> i % 15 == 0 ? "FizzBuzz"
                                : i %  3 == 0 ? "Fizz"
                                : i %  5 == 0 ? "Buzz"
                                : String.valueOf(i))
                   .collect(java.util.stream.Collectors.joining(" ")))
                   .peek(fizzbuzz -> System.out.println(fizzbuzz))
                   .count() > 0) {}
       }
   }

Stream APIとラムダ式のおかげでかなり簡単に書けました。

可変長引数
--------------------------------------------------

よく見ると ``[`` と ``]`` は ``main`` メソッドの引数で1回ずつしか使っていません。
可変長引数にすると消せますね。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) {
           if (java.util.stream.Stream
                   .of(java.util.stream.IntStream.rangeClosed(1, 100)
                   .mapToObj(i -> i % 15 == 0 ? "FizzBuzz"
                                : i %  3 == 0 ? "Fizz"
                                : i %  5 == 0 ? "Buzz"
                                : String.valueOf(i))
                   .collect(java.util.stream.Collectors.joining(" ")))
                   .peek(fizzbuzz -> System.out.println(fizzbuzz))
                   .count() > 0) {}
       }
   }

条件演算子とOptional
--------------------------------------------------

セミコロンレスJava 8では ``Optional`` が使えます。
``Optional.getOrElse`` を使えば条件演算子の代替になります。

例えば次のコードは、

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   int i = ...
   String s = i % 2 == 0 ? "yes" : "no";

こう書けます。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   int i = ...
   String s = Optional.of(i).filter(a -> a % 2 == 0).map(a -> "yes").orElseGet(() -> "no");

``:`` と ``?`` を消せました。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) {
           if (java.util.stream.Stream
                   .of(java.util.stream.IntStream.rangeClosed(1, 100)
                   .mapToObj(i -> java.util.Optional.of(i))
                   .map(i -> i.filter(a -> a % 15 == 0).map(a -> "FizzBuzz")
            .orElseGet(() -> i.filter(a -> a %  3 == 0).map(a -> "Fizz")
            .orElseGet(() -> i.filter(a -> a %  5 == 0).map(a -> "Buzz")
            .orElseGet(() -> i.get().toString()))))
                   .collect(java.util.stream.Collectors.joining(" ")))
                   .peek(fizzbuzz -> System.out.println(fizzbuzz))
                   .count() > 0) {}
       }
   }

数値演算とBigInteger
--------------------------------------------------

``int`` を ``BigInteger`` にすると演算がメソッド呼び出しになります。


例えば次のコードは、

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   int i = ...
   boolean b = i % 2 == 0;

こう書けます。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   BigInteger i = ...
   boolean b = i.mod(new BigInteger("2")).equals(BigInteger.ZERO);

``%`` と ``=`` を消せました。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) {
           if (java.util.stream.Stream
                   .of(java.util.stream.IntStream.rangeClosed(1, 100)
                   .mapToObj(i -> java.util.Optional.of(
                           new java.math.BigInteger(String.valueOf(i))))
                   .map(i -> i.filter(a -> a.mod(new java.math.BigInteger("15"))
                           .equals(java.math.BigInteger.ZERO)).map(a -> "FizzBuzz")
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger("3"))
                           .equals(java.math.BigInteger.ZERO)).map(a -> "Fizz")
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger("5"))
                           .equals(java.math.BigInteger.ZERO)).map(a -> "Buzz")
            .orElseGet(() -> i.get().toString()))))
                   .collect(java.util.stream.Collectors.joining(" ")))
                   .peek(fizzbuzz -> System.out.println(fizzbuzz))
                   .count() > 0) {}
       }
   }

文字列リテラルとStringBuilder
--------------------------------------------------

文字列リテラルもなくしてしまいましょう。
``StringBuilder`` に ``char`` を足し込んでやれば文字列は構築できます。

ただし ``char`` リテラルを使うと ``'`` を入れ混んじゃうので、
``int`` をキャストしましょう。

例えば次のコードは、

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   String s = "hello";

こう書けます。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   String s = new StringBuilder().append((char) 0x68)
                                 .append((char) 0x65)
                                 .append((char) 0x6c)
                                 .append((char) 0x6c)
                                 .append((char) 0x6f)
                                 .toString();

``"`` を消せました。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) {
           if (java.util.stream.Stream
                   .of(java.util.stream.IntStream.rangeClosed(1, 100)
                   .mapToObj(i -> java.util.Optional.of(
                           new java.math.BigInteger(String.valueOf(i))))
                   .map(i -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(15)))
                           .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                                   .append((char) 0x46).append((char) 0x69)
                                   .append((char) 0x7a).append((char) 0x7a)
                                   .append((char) 0x42).append((char) 0x75)
                                   .append((char) 0x7a).append((char) 0x7a)
                                   .toString())
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(3)))
                           .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                                   .append((char) 0x46).append((char) 0x69)
                                   .append((char) 0x7a).append((char) 0x7a)
                                   .toString())
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(5)))
                           .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                                   .append((char) 0x42).append((char) 0x75)
                                   .append((char) 0x7a).append((char) 0x7a)
                                   .toString())
            .orElseGet(() -> i.get().toString()))))
                   .collect(java.util.stream.Collectors.joining(new StringBuilder()
                                   .append((char) 0x20).toString())))
                   .peek(fizzbuzz -> System.out.println(fizzbuzz))
                   .count() > 0) {}
       }
   }

1引数のメソッド呼び出し化
--------------------------------------------------

さて、最後は ``,`` です。
``IntStream.rangeClosed`` の呼び出し部分でしか使ってないですね。
がんばって消してみましょう。

この ``,`` を消すには1引数のメソッド呼び出しだけで1〜100のストリームを生成する必要があります。
でも、ざっとStream APIを眺めましたがそれを叶えてくるメソッドはなさそうでした。

仕方がないので ``AtomicInteger.incrementAndGet`` と ``IntStream.generate`` を組み合わせてストリームを構築して、
``IntStream.limit`` で上限を設定すれば1〜100の ``IntStream`` が手に入ります。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava

   //1〜100のIntStreamを構築する普通の方法
   IntStream.rangeClosed(1, 100);

   //AtomicIntegerを利用して1〜100のIntStreamを構築する方法
   AtomicInteger x = new AtomicInteger(0);
   IntStream.generate(() -> x.incrementAndGet()).limit(100);

``,`` が消えて最終的にこうなりました。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) {
           if (java.util.stream.Stream
               .of(new java.util.concurrent.atomic.AtomicInteger(0))
               .map(x -> java.util.stream.IntStream
                   .generate(() -> x.incrementAndGet())
                   .limit(100)
                   .mapToObj(i -> java.util.Optional.of(
                           new java.math.BigInteger(String.valueOf(i))))
                   .map(i -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(15)))
                       .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                           .append((char) 0x46).append((char) 0x69)
                           .append((char) 0x7a).append((char) 0x7a)
                           .append((char) 0x42).append((char) 0x75)
                           .append((char) 0x7a).append((char) 0x7a)
                           .toString())
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(3)))
                       .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                           .append((char) 0x46).append((char) 0x69)
                           .append((char) 0x7a).append((char) 0x7a)
                           .toString())
            .orElseGet(() -> i.filter(a -> a.mod(new java.math.BigInteger(String.valueOf(5)))
                       .equals(java.math.BigInteger.ZERO)).map(a -> new StringBuilder()
                           .append((char) 0x42).append((char) 0x75)
                           .append((char) 0x7a).append((char) 0x7a)
                           .toString())
                   .orElseGet(() -> i.get().toString()))))
               .collect(java.util.stream.Collectors.joining(new StringBuilder()
                   .append((char) 0x20).toString())))
               .peek(fizzbuzz -> System.out.println(fizzbuzz))
               .count() > 0) {}
       }
   }

これで使用している記号は ``{}().->`` だけになりました。

``{}`` はクラス定義やらメソッド定義に必要だし、
``().`` はメソッド呼び出しあたりに必要だし、
``->`` はラムダ式に必要なのでこれ以上の省略は難しそう感あります。

消せる方法が思いついたら教えてください。

というわけで、セミコロンなどレスJavaでFizzBuzzしてみた話でした。

追記：new演算子を消す
--------------------------------------------------

new演算子を使っているのは次の3つのクラスです。

* ``AtomicInteger``
* ``BigInteger``
* ``StringBuilder``

まず ``BigInteger`` ですが、
``BigInteger.valueOf`` という便利なファクトリーメソッドがありました。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava

   //これは
   new BigInteger("100");

   //これで良い！！
   BigInteger.valueOf(100);

次に ``StringBuilder`` ですが、
``String.valueOf`` と ``String.concat`` を併用すれば良い事に気が付きました。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava

   //これは
   String s = new StringBuilder()
       .append((char) 0x68)
       .append((char) 0x65)
       .append((char) 0x6c)
       .append((char) 0x6c)
       .append((char) 0x6f).toString();

   //これで良い！！
   String s = String.valueOf((char) 0x68)
      .concat(String.valueOf((char) 0x65))
      .concat(String.valueOf((char) 0x6c))
      .concat(String.valueOf((char) 0x6c))
      .concat(String.valueOf((char) 0x6f));

最後に ``AtomicInteger`` ですが、

.. raw:: html

   <blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/backpaper0">@backpaper0</a> <a href="https://twitter.com/nagise">@nagise</a> IntStream.generate(() -&gt; (int)(Math.random()*100)).distinct().limit(100).sorted()　これでどうでしょ？ツイートの長さ的に*使ってますけど，いい感じにしてください</p>&mdash; 卒研で死にそうなきつね (@bitter_fox) <a href="https://twitter.com/bitter_fox/status/674438084474200066">2015, 12月 9</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

素晴らしい！！！(いろんな意味で)

きつねさんのアイデアを元に、

* 数値演算子を使わなくて済むように ``Random.nextInt`` を使用
* new演算子を使わないためにstaticファクトリーメソッドがある ``SecureRandom`` を使用

といった事に気をつけて次のようなコードにしました。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava

   //これで1〜100のIntStreamが手に入る
   SecureRandom r = SecureRandom.getInstanceStrong();
   IntStream stream = IntStream.generate(() -> r.nextInt(101))
                               .distinct().limit(101)
                               .sorted().skip(1);

ちなみに、私が考えついたのは次のようなコードでした。

.. sourcecode:: java

   //これはセミコロンを書いて良い普通のJava
   Stream.of((ArrayList) Collectors.toList().supplier().get())
         .peek(list -> list.add(BigInteger.ONE))
         .map(list -> IntStream.generate(() ->
            Stream.of((BigInteger) list.get(0))
                  .peek(a -> list.remove(0))
                  .peek(a -> list.add(a.add(BigInteger.ONE)))
                  .findFirst().get().intValue()))
         .findFirst().get();

簡単に言うと ``ArrayList`` から値を取り出して返し、その値に1足して、また ``ArrayList`` に格納する、を繰り返しています。

``ArrayList`` の生成には ``Collectors.toList`` で返される ``Collector`` の ``supplier`` を利用しました。
ぶっちゃけ ``Collectors.toList`` の実装に依存しており美しくないですね。

また、記号を抑えるためにraw型を使用していますが、そのせいでキャストが多発しており、これも美しくないです。

その点、きつねさんが提案してくれた方法はコードが美しく、より狂気があふれており素晴らしい！！！

というわけで、セミコロンなどレスJavaで書いたFizzBuzzは次のようになりました。

.. sourcecode:: java

   public class SemicolonlessFizzBuzz {
   
       public static void main(String... args) throws Exception {
           if (java.util.stream.Stream
               .of(java.security.SecureRandom.getInstanceStrong())
               .map(r -> java.util.stream.IntStream
                   .generate(() -> r.nextInt(101))
                   .distinct().limit(101).sorted().skip(1)
                   .mapToObj(i -> java.util.Optional.of(java.math.BigInteger.valueOf(i)))
                   .map(i -> i.filter(a -> a.mod(java.math.BigInteger.valueOf(15))
                       .equals(java.math.BigInteger.ZERO)).map(a ->
                                       String.valueOf((char) 0x46)
                               .concat(String.valueOf((char) 0x69))
                               .concat(String.valueOf((char) 0x7a))
                               .concat(String.valueOf((char) 0x7a))
                               .concat(String.valueOf((char) 0x42))
                               .concat(String.valueOf((char) 0x75))
                               .concat(String.valueOf((char) 0x7a))
                               .concat(String.valueOf((char) 0x7a)))
            .orElseGet(() -> i.filter(a -> a.mod(java.math.BigInteger.valueOf(3))
                       .equals(java.math.BigInteger.ZERO)).map(a ->
                                       String.valueOf((char) 0x46)
                               .concat(String.valueOf((char) 0x69))
                               .concat(String.valueOf((char) 0x7a))
                               .concat(String.valueOf((char) 0x7a)))
            .orElseGet(() -> i.filter(a -> a.mod(java.math.BigInteger.valueOf(5))
                       .equals(java.math.BigInteger.ZERO)).map(a ->
                                       String.valueOf((char) 0x42)
                               .concat(String.valueOf((char) 0x75))
                               .concat(String.valueOf((char) 0x7a))
                               .concat(String.valueOf((char) 0x7a)))
                   .orElseGet(() -> i.get().toString()))))
               .collect(java.util.stream.Collectors.joining(String.valueOf((char) 0x20))))
               .peek(fizzbuzz -> System.out.println(fizzbuzz))
               .count() > 0) {}
       }
   }

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
