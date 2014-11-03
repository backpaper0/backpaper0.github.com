セミコロンレスJavaでフィボナッチをZコンビネータなしで
================================================================================

:doc:`/2014/11/02/semicolonless_java_fibonacci` でZコンビネータ使って再帰だ！(ドヤ)
とか書きましたがそんなものは必要なかった。

.. code-block:: java

   public class SemicolonlessFibonacci {
   
       public static void main(String[] args) {
           if (java.util.stream.Stream.<F> of((f, n) -> n <= 1 ? n : f.apply(f, n - 2) + f.apply(f, n - 1))
               .map(f -> f.apply(f, Integer.parseInt(args[0])))
               .peek(System.out::println).count() > 0) {
           }
       }
   
       interface F extends java.util.function.BiFunction<F, Integer, Integer> {
       }
   }

難しく考え過ぎんなって話ですね_(:3｣∠)_

.. author:: default
.. categories:: none
.. tags:: Java, SemicolonlessJava
.. comments::
