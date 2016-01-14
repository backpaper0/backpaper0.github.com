JUnit 4.12から入ったTestRuleを軽く見てみる
================================================================================

DisableOnDebug
--------------------------------------------------------------------------------

``DisableOnDebug`` 他の ``TestRule`` をラップして、
デバッグ実行されているときのみラップした ``TestRule`` を適用します。

.. sourcecode:: java

   import org.junit.Rule;
   import org.junit.Test;
   import org.junit.rules.DisableOnDebug;
   import org.junit.rules.TestRule;
   import org.junit.rules.Timeout;
   
   public class HogeTest {
   
       @Rule
       public TestRule timeout = new DisableOnDebug(Timeout.seconds(1)); //1秒以上かかったら失敗とみなす
   
       @Test
       public void testHoge() throws Exception {
           //test code
       }
   }

こんな感じで ``Timeout`` と組み合わせる事が多い気がします。

コマンドライン引数に次のいずれかが含まれていればデバッグ実行されていると判断するようです。

* ``-Xdebug``
* ``-agentlib:jdwp``

デバッグ実行かどうかの判断は ``DisableOnDebug.isDebugging`` メソッドをオーバーライドすればカスタマイズできます。

Stopwatch
--------------------------------------------------------------------------------

``Stopwatch`` はテスト実行にかかった時間を ``System.nanoTime`` メソッドで計測します。

.. sourcecode:: java

   import java.util.logging.Logger;
   
   import org.junit.Rule;
   import org.junit.Test;
   import org.junit.rules.Stopwatch;
   import org.junit.runner.Description;
   
   public class FugaTest {
   
       private static Logger logger = Logger.getLogger(FugaTest.class.getName());
   
       @Rule
       public Stopwatch stopwatch = new Stopwatch() {
           @Override
           protected void succeeded(long nanos, Description description) {
               logger.info(() -> String.format("テストの実行に%,dナノ秒かかった", nanos));
           }
       };
       
       @Test
       public void test() throws Exception {
           //test code
       }
   }

ロギング目的に使うのが多そうです。

.. categories:: none
.. tags:: Java, JUnit
.. comments::
