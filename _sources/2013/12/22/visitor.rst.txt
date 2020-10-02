Visitorパターンについて考えた
================================

というお話。縦に長いです。コードが。

ポリもーなんとかでなんとかする
----------------------------------------

例えば数値を表すNumNode、足し算を表すAddNode、それらのインターフェースとなるNodeがあるとします。
で、計算を実装する場合Nodeにcalcメソッドとか定義してNumNodeとAddNodeで実装します。

.. sourcecode:: java

   package visitor;
   
   public interface Node1 {
   
       int calc();
   }
   
   class NumNode1 implements Node1 {
   
       public final int value;
   
       public NumNode1(int value) {
           this.value = value;
       }
   
       @Override public int calc() {
           return value;
       }
   }
   
   class AddNode1 implements Node1 {
   
       public final Node1 left;
       public final Node1 right;
   
       public AddNode1(Node1 left, Node1 right) {
           this.left = left;
           this.right = right;
       }
   
       @Override public int calc() {
           return left.calc() + right.calc();
       }
   }

こいつで2 + 3 + 4を計算する場合は次のように使います。

.. sourcecode:: java

   package visitor;
   
   import static org.hamcrest.CoreMatchers.*;
   import static org.hamcrest.MatcherAssert.*;
   import org.junit.Test;
   
   public class Node1Test {
   
       @Test public void testCalc() throws Exception {
           Node1 node1 = new NumNode1(2);
           Node1 node2 = new NumNode1(3);
           Node1 node3 = new AddNode1(node1, node2);
           Node1 node4 = new NumNode1(4);
           Node1 node5 = new AddNode1(node3, node4);
           int actual = node5.calc();
           int expected = 2 + 3 + 4;
           assertThat(actual, is(expected));
       }
   }

さて、今度は組み立てたNodeをWriterへ書き出したくなったとします。
Nodeへprintメソッドを追加します。

.. sourcecode:: java

   package visitor;
   
   import java.io.IOException;
   import java.io.Writer;
   
   public interface Node2 {
   
       int calc();
   
       void print(Writer out) throws IOException;
   }
   
   class NumNode2 implements Node2 {
   
       public final int value;
   
       public NumNode2(int value) {
           this.value = value;
       }
   
       @Override public int calc() {
           return value;
       }
   
       @Override public void print(Writer out) throws IOException {
           out.write(String.valueOf(value));
       }
   }
   
   class AddNode2 implements Node2 {
   
       public final Node2 left;
       public final Node2 right;
   
       public AddNode2(Node2 left, Node2 right) {
           this.left = left;
           this.right = right;
       }
   
       @Override public int calc() {
           return left.calc() + right.calc();
       }
   
       @Override public void print(Writer out) throws IOException {
           out.write("(");
           left.print(out);
           out.write("+");
           right.print(out);
           out.write(")");
       }
   }

さて、次は××処理を追加しますのでNodeへ××メソッドを……と、まあ、
これはこれで良いんですが、処理を追加するたびにNodeおよびNode実装クラスに手を加える必要があり、それが嬉しくない状況もあります。

処理を外から渡す
--------------------

Nodeから処理を取り除いて外から渡すことを考えてみます。

まずはinstanceofで分岐しつつ各Node実装クラスについて処理してみます。

.. sourcecode:: java
   
   package visitor;
   
   public interface Node3 {}
   
   class NumNode3 implements Node3 {
   
       public final int value;
   
       public NumNode3(int value) {
           this.value = value;
       }
   }
   
   class AddNode3 implements Node3 {
   
       public final Node3 left;
       public final Node3 right;
   
       public AddNode3(Node3 left, Node3 right) {
           this.left = left;
           this.right = right;
       }
   }
   
   class Calclurator3 {
   
       public int calc(Node3 node) {
           if (node instanceof AddNode3) {
               AddNode3 addNode3 = (AddNode3) node;
               return calc(addNode3.left) + calc(addNode3.right);
           } else if (node instanceof NumNode3) {
               NumNode3 numNode3 = (NumNode3) node;
               return numNode3.value;
           }
           throw new IllegalArgumentException(String.valueOf(node));
       }
   }

わーいこれで処理を外だしﾃﾞｷﾀﾖｰ、じゃねえよ！という感じですね。

instanceofの欠点はケースの漏れを静的に検出できないことだと思っています。
例えばこの例で言うとNode実装クラスはAddNodeとNumNodeがありますが、
NumNodeへの分岐を忘れていてもコンパイル時に気付きません。
さらに node instanceof java.util.Date とか無関係なクラスを書いていても
これもコンパイル時に気付きません。

ケースの漏れを静的に検出といえばswitchがありますが、
Stringかprimitiveまたはenumしか使えないので今回の例には不適当です。

いやいやそんなのポリもーなんとかでアレすれば良いじゃん、という事で次のようなインターフェースを作ります。

.. sourcecode:: java

   interface Visitor4 {
   
       int visit(NumNode4 node);
   
       int visit(AddNode4 node);
   }

これをこういう風に実装すれば……

.. sourcecode:: java

   class Calclurator4 implements Visitor4 {
   
       public int calc(Node4 node) {
           return visit(node);
       }
   
       @Override public int visit(NumNode4 node) {
           return node.value;
       }
   
       @Override public int visit(AddNode4 node) {
           return visit(node.left) + visit(node.left);
       }
   }

華麗に解決！というわけには行きませんね。
calcメソッド内のvisit(node)やAddNodeをとるvisitメソッド内でのvisit(node.left)やvisit(node.right)では
渡しているNode実装クラスがなんなのか、コンパイル時には分かりませんので普通にコンパイルエラーです。

無理矢理コンパイルを通そうと思うとこんなコードになりました。

.. sourcecode:: java

   class Calclurator4 implements Visitor4 {
   
       public int calc(Node4 node) {
           if (node instanceof NumNode4) {
               return visit((NumNode4) node);
           } else if (node instanceof AddNode4) {
               return visit((AddNode4) node);
           } else {
               throw new IllegalArgumentException(String.valueOf(node));
           }
       }
   
       @Override public int visit(NumNode4 node) {
           return node.value;
       }
   
       @Override public int visit(AddNode4 node) {
   
           //compile error
           //return visit(node.left) + visit(node.left);
   
           if (node.left instanceof NumNode4) {
               NumNode4 left = (NumNode4) node.left;
               if (node.right instanceof NumNode4) {
                   NumNode4 right = (NumNode4) node.right;
                   return visit(left) + visit(right);
               } else if (node.right instanceof AddNode4) {
                   AddNode4 right = (AddNode4) node.right;
                   return visit(left) + visit(right);
               } else {
                   throw new IllegalArgumentException(String.valueOf(node));
               }
           } else if (node.left instanceof AddNode4) {
               AddNode4 left = (AddNode4) node.left;
               if (node.right instanceof NumNode4) {
                   NumNode4 right = (NumNode4) node.right;
                   return visit(left) + visit(right);
               } else if (node.right instanceof AddNode4) {
                   AddNode4 right = (AddNode4) node.right;
                   return visit(left) + visit(right);
               } else {
                   throw new IllegalArgumentException(String.valueOf(node));
               }
           } else {
               throw new IllegalArgumentException(String.valueOf(node));
           }
       }
   }

はい、そこそこクソコードになりましたね？
ていうかまたinstanceofが出てきましたし。

そこでVisitorパターンですよ
----------------------------------

Nodeにacceptメソッドを追加して実装クラスで対応するvisitメソッドを呼ぶようにします。

.. sourcecode:: java

   package visitor;
   
   import java.io.IOException;
   import java.io.Writer;
   
   public interface Node5 {
   
       int accept(Visitor5 visitor);
   }
   
   class NumNode5 implements Node5 {
   
       public final int value;
   
       public NumNode5(int value) {
           this.value = value;
       }
   
       @Override public int accept(Visitor5 visitor) {
           return visitor.visit(this);
       }
   }
   
   class AddNode5 implements Node5 {
   
       public final Node5 left;
       public final Node5 right;
   
       public AddNode5(Node5 left, Node5 right) {
           this.left = left;
           this.right = right;
       }
   
       @Override public int accept(Visitor5 visitor) {
           return visitor.visit(this);
       }
   }
   
   interface Visitor5 {
   
       int visit(NumNode5 node);
   
       int visit(AddNode5 node);
   }
   
   class Calclurator5 implements Visitor5 {
   
       @Override public int visit(NumNode5 node) {
           return node.value;
       }
   
       @Override public int visit(AddNode5 node) {
           int left = node.left.accept(this);
           int right = node.right.accept(this);
           return left + right;
       }
   }
   
   class Printer5 implements Visitor5 {
   
       private final Writer out;
   
       public Printer5(Writer out) {
           this.out = out;
       }
   
       @Override public int visit(NumNode5 node) {
           try {
               out.write(String.valueOf(node.value));
           } catch (IOException e) {
               throw new RuntimeException(e);
           }
           return 0;
       }
   
       @Override public int visit(AddNode5 node) {
           try {
               out.write("(");
               node.left.accept(this);
               out.write("+");
               node.right.accept(this);
               out.write(")");
           } catch (IOException e) {
               throw new RuntimeException(e);
           }
           return 0;
       }
   }

先ほどの例とは異なりvisitメソッドを各Node実装クラスのacceptメソッド内で呼んでいるので
どのvisitメソッドなのかコンパイル時に分かりますね。

これは次のように使います。

.. sourcecode:: java

   package visitor;
   
   import static org.hamcrest.CoreMatchers.*;
   import static org.hamcrest.MatcherAssert.*;
   import java.io.StringWriter;
   import org.junit.Test;
   
   public class Node5Test {
   
       @Test public void testCalc() throws Exception {
           Node5 node1 = new NumNode5(2);
           Node5 node2 = new NumNode5(3);
           Node5 node3 = new AddNode5(node1, node2);
           Node5 node4 = new NumNode5(4);
           Node5 node5 = new AddNode5(node3, node4);
           Calclurator5 calclurator = new Calclurator5();
           int actual = node5.accept(calclurator);
           int expected = 2 + 3 + 4;
           assertThat(actual, is(expected));
       }
   
       @Test public void testPrint() throws Exception {
           Node5 node1 = new NumNode5(2);
           Node5 node2 = new NumNode5(3);
           Node5 node3 = new AddNode5(node1, node2);
           Node5 node4 = new NumNode5(4);
           Node5 node5 = new AddNode5(node3, node4);
           StringWriter out = new StringWriter();
           Printer5 printer = new Printer5(out);
           node5.accept(printer);
           String actual = out.toString();
           String expected = "((2+3)+4)";
           assertThat(actual, is(expected));
       }
   }

これで処理を外に出せました。

が、visitメソッドの戻り値がintだったりそもそもPrinterでは戻り値が意味なかったりしてもやもやしますね。

ジェネリクスを使う
-----------------------

使いましょう。
引数と戻り値をジェネリクスでアレします。

.. sourcecode:: java

   package visitor;
   
   import java.io.IOException;
   import java.io.Writer;
   
   public interface Node6 {
   
       <R, P> R accept(Visitor6<R, P> visitor, P parameter);
   }
   
   class NumNode6 implements Node6 {
   
       public final int value;
   
       public NumNode6(int value) {
           this.value = value;
       }
   
       @Override public <R, P> R accept(Visitor6<R, P> visitor, P parameter) {
           return visitor.visit(this, parameter);
       }
   }
   
   class AddNode6 implements Node6 {
   
       public final Node6 left;
       public final Node6 right;
   
       public AddNode6(Node6 left, Node6 right) {
           this.left = left;
           this.right = right;
       }
   
       @Override public <R, P> R accept(Visitor6<R, P> visitor, P parameter) {
           return visitor.visit(this, parameter);
       }
   }
   
   interface Visitor6<R, P> {
   
       R visit(NumNode6 node, P parameter);
   
       R visit(AddNode6 node, P parameter);
   }
   
   class Calclurator6 implements Visitor6<Integer, Void> {
   
       @Override public Integer visit(NumNode6 node, Void parameter) {
           return node.value;
       }
   
       @Override public Integer visit(AddNode6 node, Void parameter) {
           int left = node.left.accept(this, parameter);
           int right = node.right.accept(this, parameter);
           return left + right;
       }
   }
   
   class Printer6 implements Visitor6<Void, Writer> {
   
       @Override public Void visit(NumNode6 node, Writer parameter) {
           try {
               parameter.write(String.valueOf(node.value));
           } catch (IOException e) {
               throw new RuntimeException(e);
           }
           return null;
       }
   
       @Override public Void visit(AddNode6 node, Writer parameter) {
           try {
               parameter.write("(");
               node.left.accept(this, parameter);
               parameter.write("+");
               node.right.accept(this, parameter);
               parameter.write(")");
           } catch (IOException e) {
               throw new RuntimeException(e);
           }
           return null;
       }
   }

これでだいぶ良い感じになってきました。

が、PrinterでIOExceptionをRuntimeExceptionへラップしてるおなじみのコードが哀愁を漂わせます。

例外もジェネリクスで
----------------------------

やってしまいましょう。
Visitorの定義を少し修正します。

.. sourcecode:: java

   package visitor;
   
   import java.io.IOException;
   import java.io.Writer;
   
   public interface Node7 {
   
       <R, P, E extends Exception> R accept(Visitor7<R, P, E> visitor, P parameter)
               throws E;
   }
   
   class NumNode7 implements Node7 {
   
       public final int value;
   
       public NumNode7(int value) {
           this.value = value;
       }
   
       @Override public <R, P, E extends Exception> R accept(
               Visitor7<R, P, E> visitor, P parameter) throws E {
           return visitor.visit(this, parameter);
       }
   }
   
   class AddNode7 implements Node7 {
   
       public final Node7 left;
       public final Node7 right;
   
       public AddNode7(Node7 left, Node7 right) {
           this.left = left;
           this.right = right;
       }
   
       @Override public <R, P, E extends Exception> R accept(
               Visitor7<R, P, E> visitor, P parameter) throws E {
           return visitor.visit(this, parameter);
       }
   }
   
   interface Visitor7<R, P, E extends Exception> {
   
       R visit(NumNode7 node, P parameter) throws E;
   
       R visit(AddNode7 node, P parameter) throws E;
   }
   
   class Calclurator7 implements Visitor7<Integer, Void, RuntimeException> {
   
       @Override public Integer visit(NumNode7 node, Void parameter) {
           return node.value;
       }
   
       @Override public Integer visit(AddNode7 node, Void parameter) {
           int left = node.left.accept(this, parameter);
           int right = node.right.accept(this, parameter);
           return left + right;
       }
   }
   
   class Printer7 implements Visitor7<Void, Writer, IOException> {
   
       @Override public Void visit(NumNode7 node, Writer parameter)
               throws IOException {
           parameter.write(String.valueOf(node.value));
           return null;
       }
   
       @Override public Void visit(AddNode7 node, Writer parameter)
               throws IOException {
           parameter.write("(");
           node.left.accept(this, parameter);
           parameter.write("+");
           node.right.accept(this, parameter);
           parameter.write(")");
           return null;
       }
   }

もうだいぶ訳の分からないクソコードとなってきた感じがしますが、
Calculatorではチェック例外を投げず、PrinterではIOExceptionを投げるような表現が
できました。
お疲れ様でした。

他の言語ではどうなのか
-----------------------------

Groovyではどのメソッドを呼ぶかは実行時に決まるのでacceptメソッドが不要です。
たしか動的ディスパッチと呼ばれていたと思います。

.. sourcecode:: groovy

   class AddNode {
       def left
       def right
   }
   
   class NumNode {
       def value
   }
   
   class Calculator {
       def visit(AddNode node) {
           visit(node.left) + visit(node.right)
       }
       def visit(NumNode node) { node.value }
   }
   
   def node1 = new NumNode(value: 2)
   def node2 = new NumNode(value: 3)
   def node3 = new AddNode(left: node1, right: node2)
   def node4 = new NumNode(value: 4)
   def node5 = new AddNode(left: node3, right: node4)
   def calculator = new Calculator()
   def actual = calculator.visit(node5)

   assert actual == (2 + 3 + 4)

またScalaではパターンマッチを使えば良いです。
ケースの漏れはsealedを使えば検出可能だったと思います。

.. sourcecode:: scala

   sealed trait Node
   case class NumNode(value: Int) extends Node
   case class AddNode(left: Node, right: Node) extends Node
   
   def calc(node: Node): Int = node match {
     case NumNode(value) => value
     case AddNode(left, right) => calc(left) + calc(right)
   }
   
   val node1 = NumNode(2)
   val node2 = NumNode(3)
   val node3 = AddNode(node1, node2)
   val node4 = NumNode(4)
   val node5 = AddNode(node3, node4)
   val actual = calc(node5)
   
   assert(actual == (2 + 3 + 4))

それに、Nodeを分解してvalueやleft、rightを取り出したりできてvisitorパターンより超高機能です。
しかもコード短いし。
静的なアレだし。

まとめ
------------

Javaではデータとアルゴリズムを分離するとき、

* instanceofはケースの漏れを静的に検出できない
* switchはString、primitive、enumしか受け付けない
* パターンマッチが無い

などの理由によりVisitorパターンを使わざるを得ない場合があります。
しかし数あるデザインパターンの中でもVisitorパターンは理解するのが難しいように思います。
またそれなりに汎用的にしようと思うとジェネリクスを使って複雑な定義になってしまったり。

よって、使わなくて済むならそれに越した事は無く、使う場合でも本当にVisitorパターンが必要なのかしっかり検討すべきだと思います。

私も最近、色々あってVisitorパターンを使ってしまいましたが、もっと良い設計があったような気がしています。

こんなまとめでええんか？

まあいいか。

* `本日のコード <https://github.com/backpaper0/sandbox/tree/master/visitor-example>`_

.. author:: default
.. categories:: none
.. tags:: Java, Design pattern
.. comments::
