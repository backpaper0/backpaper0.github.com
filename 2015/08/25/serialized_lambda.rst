シリアライザブルなラムダ式
==================================================

ラムダ式は ``Serializable`` にできます。

.. code-block:: java

   //キャストしたり
   Supplier<String> s = (Supplier<String> & Serializable) () -> "x";

   //メソッドであれしたり
   <T extends Supplier<String> & Serializable> void consume(T supplier) { ... }

で、シリアライズできるぞー、と思ってこんなコード書いて、

.. code-block:: java

   import java.io.ByteArrayOutputStream;
   import java.io.IOException;
   import java.io.ObjectOutputStream;
   import java.io.Serializable;
   import java.util.function.Supplier;
   
   public class Sample {
   
       Supplier<String> get() {
           return (Supplier<String> & Serializable) () -> toString();
       }
       
       public static void main(String[] args) throws IOException {
       
           //↓シリアライザブルなサプライヤー
           Supplier<String> s = new Sample().get();
       
           //シリアライズしてみる
           ByteArrayOutputStream baos = new ByteArrayOutputStream();
           try (ObjectOutputStream out = new ObjectOutputStream(baos)) {
               out.writeObject(s);
           }
       }
   }

実行すると、

.. code-block:: none

   Exception in thread "main" java.io.NotSerializableException: Sample
       at java.io.ObjectOutputStream.writeObject0(ObjectOutputStream.java:1184)
       at java.io.ObjectOutputStream.writeArray(ObjectOutputStream.java:1378)
       at java.io.ObjectOutputStream.writeObject0(ObjectOutputStream.java:1174)
       at java.io.ObjectOutputStream.defaultWriteFields(ObjectOutputStream.java:1548)
       at java.io.ObjectOutputStream.writeSerialData(ObjectOutputStream.java:1509)
       at java.io.ObjectOutputStream.writeOrdinaryObject(ObjectOutputStream.java:1432)
       at java.io.ObjectOutputStream.writeObject0(ObjectOutputStream.java:1178)
       at java.io.ObjectOutputStream.writeObject(ObjectOutputStream.java:348)
       at Sample.main(Sample.java:17)

例外です！

これはラムダ式で ``Sample`` クラスの ``toString`` メソッドを呼んでいるため
``Sample`` がキャプチャされますが、 ``Sample`` はSerializableでないため例外が出ます。

.. code-block:: java

   Supplier<String> get() {
       return (Supplier<String> & Serializable) () -> toString();
   }

キャプチャというのはラムダ式内でラムダ式のスコープの外側の変数を参照した場合にラムダ式の実行環境に持ってくるっぽい感じのあれです。

キャプチャされているインスタンスは ``SerializedLambda`` から取ってこれます。
``SerializedLambda`` はprivate finalな ``writeReplace`` メソッドで取ってこれます。
取ってこれるからと言ってカジュアルに呼んで良いメソッドではないです。
``writeReplace`` については ``Serializable`` のJavadocに書いてあります。

こんな感じで ``SerializedLambda`` とキャプチャしたインスタンスを取ってこれました。

.. code-block:: java

   Supplier<String> s = new Sample().get();
   
   Method m = s.getClass().getDeclaredMethod("writeReplace");
   m.setAccessible(true);
   SerializedLambda sl = (SerializedLambda) m.invoke(s);
   for (int i = 0; i < sl.getCapturedArgCount(); i++) {
       System.out.println(sl.getCapturedArg(i));
   }

この辺りをもっといじくりまわすと面白い事ができそうな気がしなくもないですね！

関係ありそうな、そうでもないような参考リソース
--------------------------------------------------

* http://mike-neck.hatenadiary.com/entry/2015/08/21/034542
* https://docs.oracle.com/javase/jp/8/docs/api/java/lang/invoke/SerializedLambda.html
* https://docs.oracle.com/javase/jp/8/docs/api/java/io/Serializable.html

まとめもオチもない
--------------------------------------------------

とりあえず ``Sample`` クラスは ``Serializable`` をimplementsしましょう。 

.. author:: default
.. categories:: none
.. tags:: Java
.. comments::
