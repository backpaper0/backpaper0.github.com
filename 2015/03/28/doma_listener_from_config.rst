Doma 2.2.0からEntityListenerをDIコンテナから取得できるようになった #doma2
================================================================================

Doma 2.1.0までは ``EntityType`` 実装クラス(コンパイル時に自動生成されるクラス)のコンストラクタ内で単純にインスタンス化されていましたが、
Doma 2.2.0からは ``Config`` に ``getEntityListenerProvider`` というメソッドが追加され、
そのメソッドが返す ``EntityListenerProvider`` をカスタマイズすることで
``EntityListener`` のインスタンス取得をフックできるようになりました。

``EntityListenerProvider`` は ``EntityListener`` のインスタンスを取得する ``get``
メソッドを持っていますs。
``EntityListenerProvider.get`` メソッドのデフォルト実装は次のようになっています。

.. code-block:: java

   default <ENTITY, LISTENER extends EntityListener<ENTITY>> LISTENER get(
           Class<LISTENER> listenerClass, Supplier<LISTENER> listenerSupplier) {
       return listenerSupplier.get();
   }

ご覧のように単純に ``Supplier.get`` メソッドを実行しているだけです。

この ``EntityListenerProvider.get`` メソッドをオーバーライドしてDIコンテナから ``EntityListener``
のインスタンスを取得する例を書きます。
この例ではGuiceを使用しており ``Config`` 実装クラスと ``EntityListenerProvider``
実装クラスもGuiceで管理しています。

まずは ``EntityListenerProvider`` 実装クラス。
Guiceの ``Injector`` をインジェクションしてそこから ``EntityListener`` のインスタンスを取得しています。

.. code-block:: java

   package sample;
   
   import java.util.function.Supplier;
   
   import javax.inject.Inject;
   
   import org.seasar.doma.jdbc.EntityListenerProvider;
   import org.seasar.doma.jdbc.entity.EntityListener;
   
   import com.google.inject.Injector;
   
   public class SampleEntityListenerProvider implements EntityListenerProvider {
   
       @Inject
       private Injector injector;
   
       @Override
       public <ENTITY, LISTENER extends EntityListener<ENTITY>> LISTENER get(
               Class<LISTENER> listenerClass, Supplier<LISTENER> listenerSupplier) {
           return injector.getInstance(listenerClass);
       }
   }

次に ``Config`` 実装クラス。
``EntityListenerProvider`` をインジェクションしてそのまま返しているだけです。

.. code-block:: java

   package sample;
   
   import javax.inject.Inject;
   import javax.sql.DataSource;
   
   import org.seasar.doma.jdbc.Config;
   import org.seasar.doma.jdbc.EntityListenerProvider;
   import org.seasar.doma.jdbc.dialect.Dialect;
   
   public class SampleConfig implements Config {
   
       @Inject
       private EntityListenerProvider entityListenerProvider;
   
       @Inject
       private DataSource dataSource;
   
       @Inject
       private Dialect dialect;
   
       @Override
       public EntityListenerProvider getEntityListenerProvider() {
           return entityListenerProvider;
       }
   
       @Override
       public DataSource getDataSource() {
           return dataSource;
       }
   
       @Override
       public Dialect getDialect() {
           return dialect;
       }
   }

Guice以外のDIコンテナでも似たような方法を取れるでしょう。
例えばCDIだと ``Injector`` ではなく ``BeanManager`` をインジェクションして
``BeanManager`` から ``EntityListener`` 実装クラスのインスタンスをルックアップすると良いと思います。
(CDI 1.1以降であれば ``CDI.current().select(listenerClass)`` でも良いと思います)

``EntityListener`` をDIコンテナから取得できるようになると色々とインジェクションできるのも嬉しいですし、
インターセプターをかますことも出来たりしてさらに嬉しいですね！！！

* `Config.getEntityListenerProviderのサンプルコード <https://github.com/backpaper0/doma-listener-from-dicontainer-sample>`_

.. author:: default
.. categories:: none
.. tags:: Java, Doma
.. comments::
