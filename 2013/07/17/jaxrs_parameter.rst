JAX-RSでパラメータの受け取り方をいろいろ試す
=================================================

JAX-RSでは次に挙げるアノテーションをメソッドの引数などに付けることでクエリパラメータやパスの一部を受け取ることができます。

* @MatrixParam
* @QueryParam
* @PathParam
* @CookieParam
* @HeaderParam

メソッドの引数はStringやプリミティブを使うことができますが、それ以外のクラスも使用できます。

Stringの引数をひとつだけ受け取るpublicなコンストラクタを持つクラス
-----------------------------------------------------------------------

次のようなクラスでもクエリパラメータなどを受け取ることが出来ます。

.. code-block:: java

   public class Hoge {

       public final String value;

       public Hoge(String value) {
           this.value = value;
       }
   }

リソースメソッドでは次のように使います。

.. code-block:: java

   @GET
   public String get(@QueryParam("abc") Hoge abc) {
       ...

この例でいうとabcという名前のクエリパラメータがnullの場合はHogeはインスタンス化されず引数abcはnullとなります。
クエリパラメータがnullの場合というのはabcという名前のクエリパラメータが無い場合です。
?abc=&def=xyz というようなクエリパラメータの場合はabcはnullではなく空文字列です。

Stringの引数をひとつだけ受け取る"valueOf"という名前のstaticファクトリメソッドを持つクラス
------------------------------------------------------------------------------------------------

次のようなクラスを使用することも可能です。

.. code-block:: java

   public class Hoge {

       public final String value;

       private Hoge(String value) {
           this.value = value;
       }

       public static Hoge valueOf(String value) {
           return new Hoge(value);
       }
   }

staticファクトリメソッドを書く分の手間が増えますが、例えば、

* valueが空文字列の場合はnullを返す
* Integerのようにキャッシュすることができる
* サブクラスを返すことができる

という風に柔軟に実装することが可能です。
また、クラス（この例でいうとHoge）をabstractにすることも可能です。

Stringの引数をひとつだけ受け取る"fromString"という名前のstaticファクトリメソッドを持つクラス
---------------------------------------------------------------------------------------------------

staticファクトリメソッドはvalueOf以外にfromStringという名前にすることも可能です。

ひとつのクラスにvalueOfとfromStringの両方が定義されている場合はvalueOfが呼ばれます。
ただし列挙型の場合はvalueOfが暗黙的に実装されており挙動を上書きできないためか、fromStringが呼ばれます。
列挙型でなくともfromStringを優先にしておけば良かったのでは、と思わなくもないです。


ParamConverterを使用する
------------------------------------

JAX-RS 2から

* `ParamConverter`_
* `ParamConverterProvider`_

というふたつのインターフェースが追加されました。

ParamConverterの実装クラスではStringから任意のクラスに変換するロジックを書きます。

.. code-block:: java

   public class HogeParamConverter implements ParamConverter<Hoge> {

       @Override
       public Hoge fromString(String value) {
           return new Hoge(value);
       }

       @Override
       public String toString(Hoge hoge) {
           return hoge.value;
       }
   }

ParamConverterProviderの実装クラスではリソースメソッドの引数の型やアノテーションをもとにParamConverterを選択して返します。

.. code-block:: java

   public class HogeParamConverterProvider implements ParamConverterProvider {

       @Override
       public <T> ParamConverter<T> getConverter(Class<T> rawType, Type genericType, Annotation[] annotations) {
           if (rawType == Hoge.class) {
               return (ParamConverter<T>) new HogeParamConverter();
           }
           return null;
       } 
   }

この方法は一番手間がかかりますがstaticファクトリメソッドを用いる方法と比べて

* Hogeをインターフェースにすることが可能
* 同じ型に対してもアノテーションによって異なるParamConverterを使用できる
* javaから始まるパッケージのクラスなど既存のクラスも使用できる

といったことが利点だと思います。

まとめ
------------

JAX-RS 2からParamConverterが入った事でクリエパラメータやリクエストヘッダをどんな型でも受け取ることができるようになりました。
インターセプターやクライアントAPIに比べると地味に見えますが、なかなか素晴らしい進化だと個人的には思っています。

サンプル書きました。

* https://github.com/backpaper0/sandbox/tree/master/jaxrs-parameter-example

.. _ParamConverter: http://docs.oracle.com/javaee/7/api/javax/ws/rs/ext/ParamConverter.html
.. _ParamConverterProvider: http://docs.oracle.com/javaee/7/api/javax/ws/rs/ext/ParamConverterProvider.html

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS
.. comments::
