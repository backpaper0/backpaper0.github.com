Jersey 2.14でパラメータの受け取りにOptionalが使えるようになった
================================================================================

Jersey 2.14がリリースされたようです！

* https://jersey.java.net/release-notes/2.14.html

で、注目は `[JERSEY-2612] <https://java.net/jira/browse/JERSEY-2612>`_ です。
この対応のおかげで@QueryParamなどのパラメータをOptionalで定義する事が可能になります。
ただしParamConverterを書く必要はありますが。

ParamConverterってなんやねん！って方は :doc:`/2013/07/17/jaxrs_parameter`
の後半を読んでくださいませー。

リクエストパラメータをOptionalで受け取るコード例
--------------------------------------------------------------------------------

適当ですがサクッちょとサンプル書きました。

* https://github.com/backpaper0/sandbox の `jersey-optional-example` ディレクトリ

リソースクラスをこちらにも掲載します。
ちょー簡単な例ですが、こんな感じでリソースメソッドの引数にOptionalを使えるようになります。

.. code-block:: java

   package example;
   
   import java.util.Optional;
   
   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.QueryParam;
   import javax.ws.rs.core.MediaType;
   
   @Path("hello")
   public class HelloWorld {
   
       @GET
       @Produces(MediaType.TEXT_PLAIN)
       public String say(@QueryParam("name") Optional<String> name) {
           return "Hello, " + name.orElse("world") + "!";
       }
   }

注意点としては先ほども書きましたがParamConverter実装クラスとParamConverterProvider実装クラスも
自前で準備しなくてはならない事です。
まあ、一度書いたら使い回せるはずなのでサクッと書いておきましょー。

今までこれが出来なかった理由
--------------------------------------------------------------------------------

@QueryParamなどで注釈された引数へ渡される値はSingleValueExtractorのextractメソッドを
通るんですが、Jersey 2.13までのextractメソッドは「値がnullでなければParamConverterなどで変換、
nullなら@DefaultValueで設定された値を返す」という感じの実装になっていました。

その部分を抜粋します。

  .. code-block:: java
  
     @Override
     public T extract(MultivaluedMap<String, String> parameters) {
         String v = parameters.getFirst(getName());
         if (v != null) {
             try {
                 return fromString(v);
             } catch (WebApplicationException ex) {
                 throw ex;
             } catch (ProcessingException ex) {
                 throw ex;
             } catch (Exception ex) {
                 throw new ExtractorException(ex);
             }
         } else {
             return defaultValue();
         }
     }

このロジックが原因でOptionalのParamConverterを書いてもnullが渡ってくるアレっぷりでした。

しかしこのextractメソッドはJersey 2.14で次のように修正されました。

  .. code-block:: java
  
     @Override
     public T extract(MultivaluedMap<String, String> parameters) {
         String v = parameters.getFirst(getName());
         try {
             return fromString((v == null && isDefaultValueRegistered()) ? getDefaultValueString() : v);
         } catch (WebApplicationException ex) {
             throw ex;
         } catch (ProcessingException ex) {
             throw ex;
         } catch (IllegalArgumentException ex) {
             return defaultValue();
         } catch (Exception ex) {
             throw new ExtractorException(ex);
         }
     }

ご覧の通り「値がnullかつデフォルト値が設定されていればデフォルト値を、
そうでなければ値をParamConverterなどに渡す」という風になっています。

これで値がnullの場合でもParamConverterを通るようになり、Optionalへの変換が可能になりました。

まとめ
--------------------------------------------------------------------------------

* Jerseyでリクエストパラメータなどの受け取りにOptional使えるようになって嬉しい
* ハイテンションでブログ書いたら文章やばい

そんな感じでー

.. author:: default
.. categories:: none
.. tags:: JAX-RS, Java, Jersey
.. comments::
