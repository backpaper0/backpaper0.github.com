Java EEアプリケーションで起動時になにかしらの処理をする方法
================================================================================

いくつか考えてみました。

* ``HttpServlet.init`` をオーバーライドする(Servlet)
* ``ServletContainerInitializer`` の実装クラスを作る(Servlet)
* ``Singleton`` セッションビーンに ``@Startup`` を付けて ``@PostConstructed`` を付けたメソッドを定義する(EJB)
* ``Extension`` の実装クラスを作ってライフサイクルイベントをハンドリングするオブザーバーメソッドを作る(CDI)
* ``@ApplicationScoped`` なCDI管理ビーンを作って ``@Initialized(ApplicationScoped.class)`` なイベントをハンドリングするオブザーバーメソッドを作る(CDI)

他にもあったら教えてください！

で、個人的には

* Servlet APIを直接使うのは可能な限り避けたい
* EJBは使わない

という感じなのでCDIで実現するのが良さそうです。

起動時処理に ``Extension`` を使うのはなんか違う感じがしますし、
``@Initialized(ApplicationScoped.class)`` を使った方法が好みです。

具体的にはこんなコードです。

.. code-block:: java

   import javax.enterprise.context.ApplicationScoped;
   import javax.enterprise.context.Initialized;
   import javax.enterprise.event.Observes;
   
   @ApplicationScoped
   public class Hoge {
   
       public void handle(@Observes @Initialized(ApplicationScoped.class) Object event) {
           //ここに起動時にしたい処理を書く
       }
   }

CDI以外のサンプルも含んだコードは次のURLです。

* https://github.com/backpaper0/sandbox/tree/master/javaee-startup-sample

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS, CDI, EJB, Servlet
.. comments::
