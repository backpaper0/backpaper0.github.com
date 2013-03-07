Java8でBDDっぽくテストを書けるかもしれないアイデア
=====================================================

JasmineでJavaScriptのテスト書いたりJava8のラムダに思いを馳せていたらなんとなく思いつきました。
ラムダにインスタンスイニシャライザを組み合わせたらこんな感じでテストが書けそうです。

.. code-block:: java

   package app;
   
   public class CalcSpec extends Specs {{
   
       it("1 足す 2 は 3", () -> {
           expect(() -> 1 + 2).toEqual(3);
       });
   
       it("1 割る 0 は例外", () -> {
           expect(() -> 1 / 0).toThrow(ArithmeticException.class);
       });
   
   }}

うむ、Jasmineぽい。
まあ実はBDDぽいとかよく分かっていませんが。

itメソッドを呼ぶと第一引数のテスト名をkey、第二引数のRunnableのようなオブジェクトをvalueとするマップに突っ込みます。
このマップのひとつのEntryがひとつのテストになります。
itメソッドはスーパークラスのSpecsに定義されています。
そのSpecs自体に@RunWithが注釈しており、テストはSpecRunnerというテストランナーで実行されます。
SpecRunnerはSpecsに集められたテストを実行します。

などと文章にしても伝えられる気がまったく無いのでSpecsとSpecRunnerのコード晒します。

Specsはこんな感じ。

.. code-block:: java

   package app;
   
   import java.util.LinkedHashMap;
   import java.util.Map;
   import java.util.concurrent.Callable;
   import org.junit.Assert;
   import org.junit.runner.RunWith;
   
   @RunWith(SpecRunner.class)
   public class Specs {
   
       public Map<String, Spec> specs = new LinkedHashMap<>();
   
       protected void it(String name, Spec spec) {
           specs.put(name, spec);
       }
   
       protected <T> Expect<T> expect(Callable<T> c) {
           return new Expect<>(c);
       }
   
       public interface Spec {
   
           void run() throws Exception;
       }
   
       public static class Expect<T> {
   
           private final Callable<T> c;
   
           public Expect(Callable<T> c) {
               this.c = c;
           }
   
           public void toEqual(T value) throws Exception {
               Assert.assertEquals(value, c.call());
           }
   
           public void toThrow(Class<? extends Exception> exceptionClass) throws Exception {
               try {
                   c.call();
                   Assert.fail();
               } catch (Exception e) {
                   if (!exceptionClass.isAssignableFrom(e.getClass())) {
                       Assert.fail();
                   }
               }
           }
       }
   }

SpecRunnerはこんな感じ。

.. code-block:: java

   package app;
   
   import org.junit.runner.Description;
   import org.junit.runner.Runner;
   import org.junit.runner.notification.Failure;
   import org.junit.runner.notification.RunNotifier;
   
   public class SpecRunner extends Runner {
   
       private final Specs spec;
   
       public SpecRunner(Class<Specs> specClass) throws InstantiationException, IllegalAccessException {
           spec = specClass.newInstance();
       }
   
       @Override
       public Description getDescription() {
           Description desc = Description.createSuiteDescription(spec.getClass());
           for (String name : spec.specs.keySet()) {
               desc.addChild(Description.createSuiteDescription(name));
           }
           return desc;
       }
   
       @Override
       public void run(RunNotifier notifier) {
           for (String name : spec.specs.keySet()) {
               Description desc = Description.createSuiteDescription(name);
               notifier.fireTestStarted(desc);
               try {
                   spec.specs.get(name).run();
               } catch (Exception ex) {
                   Failure f = new Failure(desc, ex);
                   notifier.fireTestFailure(f);
               } finally {
                   notifier.fireTestFinished(desc);
               }
           }
       }
   }

これらのコードを、Java8に対応しているNetBeansの開発版を使用して試してみました。

.. image:: /images/test-result.*

いい感じで実行できました。

というわけで、ふわっとした思いつきをサクッと試してみただけですが、なかなかJava8の可能性を感じれた気がします。
テスティングフレームワークに限らずね、色々出てきてくれそうですね。

楽しみだ。はよこいJava8。

ギットハブにも置いたよ
--------------------------

* https://github.com/backpaper0/junit-spec-runner


.. author:: default
.. categories:: none
.. tags:: Java,Testing
.. comments::
