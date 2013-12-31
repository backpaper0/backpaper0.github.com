
JAX-RSとかの話
===========================

これは2013-04-19に行われた「いいね！Java EE！」で使用した資料を加筆修正したものです。

* http://connpass.com/event/2109/

JAX-RSって？
-------------------

* Webアプリを作るためのAPI
* `JSR 311 (JAX-RS 1.x) <http://jcp.org/en/jsr/detail?id=311>`_
* `JSR 339 (JAX-RS 2.x) <http://jcp.org/en/jsr/detail?id=339>`_
* Java EE 6 Full Profile に入ってる(なぜかWeb Profileじゃない)
* Java EE 7 からは Web Profile に入る
* Jersey(参照実装)、RESTEasy、Apache CXFなどの実装があり、みんな大好きTomcatでも使える
* 仕様書(PDF)は41ページで目に優しい(ちなみにEJB 3.1は626ページ)

開発準備
-----------------

* `NetBeans <http://ja.netbeans.org/>`_ を使いましょう！

以上

Maven
~~~~~~~~~~~~~~~~~

Mavenでアレするなら次のようなdependencyを書けば良いです。

.. code-block:: xml

   <dependency>
     <groupId>com.sun.jersey</groupId>
     <artifactId>jersey-bundle</artifactId>
     <version>1.11.1</version>
     <scope>provided</scope>
   </dependency>
   <dependency>
     <groupId>com.sun.jersey.jersey-test-framework</groupId>
     <artifactId>jersey-test-framework-http</artifactId>
     <version>1.11.1</version>
     <scope>test</scope>
   </dependency>

Jerseyのartifactはjersey-serverやjersey-jsonなどいくつかに分かれているのですが、jersey-bundleはそれらがまとめられたもので、こいつを指定するのが楽ちんです。

jersey-test-framework-http はJerseyのテスティングフレームワークで、Hotspotに入ってる com.sun.net.httpserver.HttpServer で実行します。

artifactId の末尾の -http を -grizzly にするとGrizzly(GlassFishのHTTPを捌く部分)で動かす事もできますし、-inmemory にするとソケットを介さずインメモリで動かす事もできます。

はじめてのJAX-RS
---------------------------

クエリパラメータで名前を渡すとHello, xxx!が返るWeb APIを書きましょう。

.. code-block:: java

   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.QueryParam;
   
   @Path("hello")
   public class HelloResource {

       @GET
       public String say(
               @QueryParam("name") String name) {
           return "Hello, " + name + "!";
       }
   }

これは次のようなHTTPリクエストを処理することができます。

.. code-block:: http

   GET /rest/hello?name=world HTTP/1.1

/rest がアプリケーションのルートとなります。
これは後述するApplicationサブクラスに注釈する@ApplicationPathで指定する値が対応します。
あとは何となく見たら分かる感じではありますが、/hello が @Path("hello") に、?name=world が @QueryParam("name") に、それからリクエストメソッドがGETですが @GET が対応しています。

こいつをとりあえずサクッと動かすならjersey-test-frameworkを使うのがらくちんです。
JUnitでぶん回すことができます。

.. code-block:: java

   import com.sun.jersey.test.framework.AppDescriptor;
   import com.sun.jersey.test.framework.JerseyTest;
   import com.sun.jersey.test.framework.LowLevelAppDescriptor.Builder;
   import static org.hamcrest.CoreMatchers.*;
   import static org.junit.Assert.*;
   import org.junit.Test;
   
   public class HelloResourceTest extends JerseyTest {

       @Test
       public void test_say() throws Exception {
           String response = resource()
                   .path("hello")
                   .queryParam("name", "world")
                   .get(String.class);
           assertThat(response, is("Hello, world!"));
       }

       @Override
       protected AppDescriptor configure() {
           return new Builder(HelloResource.class).build();
       }
   }

アプリケーションサーバやサーブレットコンテナで動かす
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`GlassFish <https://glassfish.java.net/>`_ などのJava EEアプリケーションサーバで動かすにはApplicationサブクラスを作ります。

.. code-block:: java

   import javax.ws.rs.ApplicationPath;
   import javax.ws.rs.core.Application;
   
   @ApplicationPath("rest")
   public class JaxrsActivator extends Application {
   }

Applicationを継承して@ApplicationPathで注釈するだけです。
あとはHelloResourceとこのJaxrsActivatorをWARにパッケージングしてデプロイすればおkです。

Tomcatなどのサーブレットコンテナだと専用のサーブレットを登録する必要がある……と見せかけてServlet 3対応のコンテナならJerseyのJARを突っ込むだけでweb.xmlを書く必要はありません。
web.xmlを書かなくてもServletContainerInitializerを利用して動的にサーブレットを追加してくれます。

リソースクラス、リソースメソッド
------------------------------------------

リソースクラスは@Pathで注釈したクラスで先の例でいうとHelloResourceがリソースクラスになります。
クラス名に制約はないのでHelloでもFoobarでも何でも良いです。
@Pathにはこのリソースクラスで処理するパスを指定します。
リソースクラスはpublicなコンストラクタが必要です。

.. code-block:: java

   @Path("hello")
   public class HelloResource { ... }

リソースメソッドはリソースクラスに定義されたメソッドで@GETや@POSTといったHTTPメソッドに対応するアノテーションで注釈します。
リソースメソッドでは@Consumesで受け取るリクエストボディのContent-Typeを指定できます。
同じように@Producesで送り返すレスポンスボディのContent-Typeを指定できます。
また引数に@QueryParamや@HeaderParamを注釈することでクエリパラメータやリクエストヘッダをマッピングすることができます。

.. code-block:: java

  @GET
  @Consumes("text/plain")
  @Produces("text/plain")
  public String say(
          @QueryParam("name") @DefaultValue("world") String name) {
      return "Hello, " + name + "!";
  }

なお、@QueryParamなどでマッピング出来るのはリソースメソッドの引数だけじゃなくコンストラクタの引数や

.. code-block:: java

   @Path("hello")
   public class HelloResource {
  
       private final String name;
 
       public HelloResource(
               @QueryParam("name") String name) {
           this.name = name;
       }

       ...

フィールド、

.. code-block:: java

   @Path("hello")
   public class HelloResource {

       @QueryParam("name")
       private String name;

       ...

setterなども使用できます。

.. code-block:: java

   @Path("hello")
   public class HelloResource {

       private String name;

       @QueryParam("name")
       public void setName(String name) {
           this.name = name;
       }

       ...

個人的にはメソッドの引数を使用するのが好きです。
 
パラメータのマッピング
------------------------------------------------

既にクエリパラメータを@QueryParamでマッピングする例は挙げましたが、他にはリクエストヘッダやパスの一部、Cookieの値などをアノテーションでマッピングすることができます。

@QueryParam
~~~~~~~~~~~~~~~~~~

* クエリパラメータをマッピング
* /hoge?\ **name**\ =\ **value**

.. code-block:: java

   @GET
   public String sayHello(
           @QueryParam("name") String name) {
       ...

@FormParam
~~~~~~~~~~~~~~~~~~~

* フォームのPOSTリクエストで送信するパラメータをマッピング
* <input type="text" name="\ **name**\ ">

.. code-block:: java

   @POST
   public String sayHello(
           @FormParam("name") String name) {
       ...

@PathParam
~~~~~~~~~~~~~~

* パスの一部をマッピング
* /hoge/\ **value**

.. code-block:: java

   @GET
   @Path("{name}")
   public String sayHello(
           @PathParam("name") String name) {
       ...

コロンで区切って正規表現を書く事もできます。

.. code-block:: java

   @GET
   @Path("{id:[0-9]{1,10}}")
   public String findById(
           @PathParam("id") Long id) {
       ...

@MatrixParam
~~~~~~~~~~~~~~~~

* マトリックスパラーメータ
* セミコロンで区切った形式
* /hoge;foo=1;bar=2

.. code-block:: java

   @GET
   @Produces("text/plain")
   public String sayHello(
           @MatrixParam("left") String left,
           @MatrixParam("right") String right) {
       ...

@CookieParam
~~~~~~~~~~~~~~~~~~~

* Cookieをマッピング

.. code-block:: java

   @GET
   @Produces("text/plain")
   public String sayHello(
           @Cookie("name") String name) {
       ...

@HeaderParam
~~~~~~~~~~~~~~~~~~~~~

* リクエストヘッダをマッピング

.. code-block:: java

   @GET
   @Produces("text/plain")
   public String sayHello(
           @HeaderParam("name") String name) {
       ...

パラメータをまとめる
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

パラメータがひとつふたつなら良いですが、もっと多くなると引数に列挙するのはシグネチャがうるさくなりますね。
Jerseyなら@InjectParamを使うことでパラメータをPOJOにまとめることができます。
ただし、JAX-RSの仕様じゃなくてJerseyの実装依存の機能ですので、そこんとこ注意です。

.. code-block:: java

   @GET
   @Produces("text/plain")
   public String sayHello(
           @InjectParam HogeBean bean) {
       ...
   
   public class HogeBean {
       
       @QueryParam("foo")
       public String foo;
       
       @QueryParam("bar")
       public String bar;
       
       ...

ちなみにJAX-RS 2からはこの@InjectParamと同様の機能をもつ@BeanParamというアノテーションが追加されます。

パラメータをPOJOで受け取る
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ここまで@QueryParamなどで受け取るパラメータの型はStringを使用していましたが、自作のクラスを使用することも可能です。
パラメータを受け取れるクラスは、valueOfまたはfromStringという名前の静的ファクトリメソッドを定義する必要があります。
引数はStringです。

.. code-block:: java

   public class Fullname {

      ...

       //public static Fullname valueOf(String value) {
       public static Fullname fromString(String value) {
           return new Fullname(value);
       }
   }

リソースメソッドではStringでパラメータを受けるときと同じ感覚で使えます。

.. code-block:: java

   @GET
   @Produces("text/plain")
   public String sayHello(
           @QueryParam("name") Fullname name) {
       ...

XMLで通信する
-------------------------

エンティティボディがXMLの場合、JAXBで自作のクラスにマッピングする機能がJAX-RSにはあります。

例えばこのようなXMLを、

.. code-block:: xml

   <hogeBean>
     <foo>hello</foo>
     <bar>world</bar>
   </hogeBean>

このようなクラスで受け取ることが可能です。
@XmlRootElementはJAXBのAPIです。

.. code-block:: java

   @XmlRootElement
   public class HogeBean {

       public String foo;

       public String bar;
   }

リソースメソッドはこのようになります。
@ConsumesでXMLを受け取る事を明示しています。

.. code-block:: java

   @POST
   @Consumes("application/xml")
   public void doHoge(HogeBean bean) {
       ...

レスポンスをXMLにすることも可能です。
その場合、リソースメソッドは次のようになります。
今度は@ProducesでXMLを返すことを明示しています。

.. code-block:: java

   @GET
   @Produces("application/xml")
   public HogeBean getHoge() {
       ...

前述の通りXMLとクラスの相互変換を行う部分はJAX-RSではなくJAXBの仕様です。
JAXBはJava SEに入っているので動作確認は手軽にできます。

.. code-block:: java

   HogeBean obj = ...
   StringWriter out = new StringWriter();
   JAXB.marshal(obj, out);
   String xml = out.toString();

   ...

   String xml = ...
   StringReader in = new StringReader(xml);
   HogeBean obj = JAXB.unmarshal(xml, HogeBean.class);

JSONで通信する
------------------

前述のようにJAXBでXML通信している場合、Jerseyなら@Consumesや@Producesでのメディアタイプの指定をapplication/jsonに変更するだけでJSONで通信することが可能です。

.. code-block:: java

   @POST
   //@Consumes("application/xml")
   //@Produces("application/xml")
   @Consumes("application/json")
   @Produces("application/json")
   public HogeBean doHoge(HogeBean bean) {
       ...

元々はXMLで通信していましたが、たったこれだけで次のようなJSONで通信するようになります。

.. code-block:: json

   { "foo" : "hello",
     "bar" : "world" }

JSON通信での問題点
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

リストを含む次のようなクラスの、

.. code-block:: java

   @XmlRootElement
   public class Hoge {
   
       public List<String> foobar;
   }

インスタンスを作成して、

.. code-block:: java

   Hoge obj = new Hoge();
   obj.foobar = Arrays.asList("a", "b", "c");

XML通信すると次のようなXMLになります。

.. code-block:: xml

   <hoge>
     <foobar>a</foobar>
     <foobar>b</foobar>
     <foobar>c</foobar>
   </hoge>

foobar要素がリストの要素分、フラットに並んでいますね。

これがJSON通信の場合だと次のようなJSONになります。

.. code-block:: json

   { "foobar" : [ "a", "b", "c" ] }

XMLではフラットに並んでいたfoobar要素が空気を読んでリストになっていますね。

で、次はこんな感じのインスタンスを、

.. code-block:: java

   Hoge obj = new Hoge();
   obj.foobar = Arrays.asList("x");

JSON通信すると次のようなJSONになります。

.. code-block:: java

   { "foobar" : "x" }

リストじゃなくなっていますね。
なんでやねん、と。

foobar要素が一つのXMLを想像するとなんとなく納得できます。

.. code-block:: java

   <hoge>
     <foobar>x</foobar>
   </hoge>

このように、要素がひとつだとリストなのかリストじゃないのか分からないのです。
JerseyのJAXB経由のJSON変換は、XMLに変換する過程に横入りして行っているのでこの影響をモロに受けてリストじゃなくなってしまうっぽいです。

クライアント側もJerseyを使っていたりするとこれが問題になることは無いですが、WebアプリでjQueryなんかを使ってたりするとリストのつもりで受け取ったらリストじゃなかったでござる、という状況になって困ります。
というか困りました、実際に。

JacksonでJSON通信する
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

前述の「要素がひとつの場合にリストじゃなくなっちゃう問題」に対処するにはJacksonを利用したJSON変換を行うと良いです。

* http://jackson.codehaus.org/

Jacksonを使うとfoobar要素がひとつしかない場合でも次のようなJSONに変換されます。

.. code-block:: json

   { "foobar" : [ "x" ] }

また、Jacksonを使うと、

* クラスを@XmlRootElementで注釈する必要がない
* リソースメソッドの戻り値をjava.util.Listにする事が可能

などの利点があります。

JerseyでJacksonを使うには初期パラメータ com.sun.jersey.api.json.POJOMappingFeature を true に設定します。

jersey-test-frameworkを使ったりJDKのHttpServerで動かす場合はResourceConfigというクラスで設定すると良いです。

.. code-block:: java

   ResourceConfig rc = ...
   rc.getFeatures().put(JSONConfiguration.FEATURE_POJO_MAPPING, true);

書くまでもないですが、このコードにあるJSONConfiguration.FEATURE_POJO_MAPPINGは文字列の定数で、"com.sun.jersey.json.POJOMappingFeature"です。

サーブレット経由で動かすならweb.xmlで設定することも可能です。

.. code-block:: xml

   <servlet>
     <servlet-name>Jersey</servlet-name>
     <servlet-class>com.sun.jersey.spi.container.servlet.ServletContainer</servlet-class>
     <init-param>
       <param-name>com.sun.jersey.api.json.POJOMappingFeature</param-name>
       <param-value>true</param-value>
     </init-param>
   </servlet>

個人的にはJerseyでJSON通信するならJacksonを使うのが良いと思います。

XMLでもJSONでも通信する
---------------------------------

これまでXMLかJSONのどちらか片方で通信する設定方法を紹介しましたが、ひとつのメソッドでXMLでもJSONでも通信することも可能です。
設定は単純で@Consumesや@Producesに複数のメディアタイプを書けば良いです。

.. code-block:: java

   @POST
   @Consumes({ "application/json", "application/xml" })
   @Produces({ "application/json", "application/xml" })
   public HogeBean doHoge(HogeBean bean) {
       ...

このリソースメソッドはクライアントがAcceptヘッダでapplication/jsonを要求すればJSONで通信し、application/xmlを要求すればXMLで通信します。
このようにメソッドの内容はまったく同じだけど、HTTPリクエストの内容によって通信のフォーマットを切り替えられるのはJAX-RSの強みですね。

MessageBodyReader/MessageBodyWriter
----------------------------------------------

JAX-RSで通信できるのはXMLやJSONだけではありません。
MessageBodyReaderやMessageBodyWriterを実装すればエンティティボディを好きにマッピングすることが可能です。

例えば、String[][]をCSVで出力するMessageBodyWriterを実装してみます。

.. code-block:: java

   @Provider
   @Produces("text/csv")
   public class CsvWriter implements MessageBodyWriter<String[][]> {

       @Override
       public boolean isWriteable(Class<?> type, Type genericType,
               Annotation[] annotations, MediaType mediaType) {
           return type == String[][].class;
       }

       @Override
       public long getSize(String[][] t, Class<?> type, Type genericType,
               Annotation[] annotations, MediaType mediaType) {
           return -1;
       }

       @Override
       public void writeTo(String[][] t, Class<?> type, Type genericType,
               Annotation[] annotations, MediaType mediaType,
               MultivaluedMap<String, Object> httpHeaders,
               OutputStream entityStream) throws IOException, WebApplicationException {
           try (PrintWriter out = new PrintWriter(entityStream)) {
               for (String[] row : t) {
                   for (String column : row) {
                       out.printf("%s,", column);
                   }
                   out.println();
               }
           }
       }
   }

@Providerで注釈していますが、これを付けておくとアノテーションスキャンで拾ってくれます。
あるいはクラスパス上にMETA-INF/services/javax.ws.rs.ext.MessageBodyWriterというファイルを作って、中にCsvWriterのFQDNを書いてServiceLoaderに拾ってもらいます。

@Producesで注釈することで、このMessageBodyWriterが処理する対象となるContent-Typeを指定しています。
さらにisWritableメソッドでこのMessageBodyWriterを使うべきか判断することが可能です。

getSizeメソッドは書き出すエンティティボディのバイトサイズです。
算出できない（し辛い）場合は-1を返しておくと良きに計らってくれます。

最後にwriteToメソッドですが、これが実際にエンティティボディに書き出すメソッドになります。

このCsvWriterに対応するレスポンスを返すリソースメソッドはこんな感じです。

.. code-block:: java

   @GET
   @Produces("text/csv")
   public String[][] getCsv() {
       ...

オブジェクトから実際の通信形式へ変換する方法をMessageBodyWriterに分離しているのでリソースメソッドはシンプルに保たれていますね。

WebApplicationException
--------------------------------------------------

場合によってはリソースメソッドで処理中に「やっぱり404返したいわー」などというときもあると思いますが、WebApplicationExceptionを投げるのが楽ちんです。

.. code-block:: java

   @GET
   @Path("{isbn}")
   @Produces("application/json")
   public Book get(@PathParam("isbn") Isbn isbn) {
       Book book = bookBean.get(isbn);
       if(book == null) {
           throw new WebApplicationException(404);
       }
       ...

ExceptionMapper
-----------------------------------

リソースメソッドから投げられた特定の例外を受け取って処理したい場合はExceptionMapperを実装したサブクラスを作ります。

例えばJPAの楽観排他機能で更新したいエンティティが既に別のひとに更新されていた場合、OptimisticLockExceptionが投げられますが、これを受け取って処理をするExceptionMapperを書いてみます。

.. code-block:: java

   @Provider
   public class OptimisticLockExceptionMapper implements ExceptionMapper<OptimisticLockException> {

       @Override
       public Response toResponse(OptimisticLockException exception) {
           return Response.status(400).entity("更新されとった＞＜").type("text/plain").build();
       }
   }

@Contextで色々な情報を参照する
-------------------------------------

前述のOptimisticLockExceptionMapperですが、EJBを使っている場合はOptimisticLockExceptionがRollbackExceptionに包まれて投げられます。
RollbackExceptionはOptimisticLockExceptionと継承関係は無いのでOptimisticLockExceptionMapperで処理できません。

そんな場合はProvidersを使います。

.. code-block:: java

   public static class RollbackExceptionMapper implements ExceptionMapper<RollbackException> {

       @Context
       private Providers p;

       @Override
       public Response toResponse(RollbackException exception) {
           Throwable cause = exception.getCause();
           Class<Throwable> type = (Class<Throwable>) cause.getClass();
           return p.getExceptionMapper(type).toResponse(cause);
       }
   }

@ContextでProvidersをインジェクションします。
Providersはクラスやアノテーションを渡すとそれに対応するExceptionMapperやMessageBodyReaderを取ってこれる便利なものです。
このような便利クラスを@Contextでインジェクションできます。

インジェクションできる便利クラスはProvidersの他にクエリパラメータやパスの情報を取って来れるUriInfoや、HTTPヘッダを取れるHttpHeaders、認証情報を取れるSecurityContextなどがあります。

他にもDIしたい
--------------------

EJBでDI
~~~~~~~~~~~

リソースクラスをStateless Session Beanにします。
@EJBでSession Beanを、@PersistenceContextでEntityManagerなどをインジェクションできます。

.. code-block:: java

   @Path("hello")
   @Stateless
   public class HelloResource {
   
       @EJB
       private HelloBean helloBean;
   
       @GET
       public String say(@QueryParam("name") String name) {
           return helloBean.say(name);
       }
   }

個人的な利点は宣言的トランザクションでしょうか。

欠点はSession BeanかEntityManagerぐらいしかDIするものがないことですかね。

CDIでDI
~~~~~~~~~~~~~~

WEB-INF/beans.xmlを作成します。
空のファイルでもOKです。

.. code-block:: java

   @Path("hello")
   @RequestScoped
   public class HelloResource {
   
       @Inject
       private HelloBean helloBean;
   
       @GET
       public String say(@QueryParam("name") String name) {
           return helloBean.say(name);
       }
   }

基本的に何でもDIできるのが利点です。
CDIでは殆どのクラスが管理Beanになります。

欠点はEJBでは使えていた宣言的トランザクション使えないことです。
まあ自分でCDIのインターセプターを書いて適用すれば良いんですが、ちょっと面倒です。

EJBとCDIを併用する
~~~~~~~~~~~~~~~~~~~~~~~

というわけでEJBとCDIを併用します。

.. code-block:: java

   @Stateless
   @Path("hello")
   public class HelloResource {
   
       @Inject
       private HelloBean helloBean;
   
       @GET
       public String say(@QueryParam("name") String name) {
           return helloBean.say(name);
       }
   }

利点はDIを@Injectで統一できることです。
CDI管理Beanは当然ですが、（少し手を加える必要がありますが）EntityManagerもDataSourceも@Injectでぶっ込むことが可能です。

欠点はJersey 1.11.1のバグです。

* http://www.coppermine.jp/docs/programming/2012/12/jax-rs-ejb2.html

その他、DIの利点
~~~~~~~~~~~~~~~~~~~~~~~~

* インターセプタをかませる（JAX-RS 2.0からはJAX-RSの仕様にインターセプターが入りますが）
* モックにすげ替えやすい
* Arquillianでテストしやすい

Arquillian
--------------------

ArquillianはJBossが提供しているJava EE向けの結合テストフレームワークです。
以下の例のようにテストコードを書く事が可能です。

.. code-block:: java

   @RunWith(Arquillian.class)
   public class CalcTest {

       @Inject
       CalcBean calcBean;

       @Test
       public void test_add() throws Exception {
           int answer = calcBean.add(2, 3);
           assertThat(answer, is(5));
       }

       @Deployment
       public static WebArchive createDeployment() {
           return ShrinkWrap.create(WebArchive.class)
               .addClass(CalcBean.class)
               .addAsWebInfResource(EmptyAsset.INSTANCE, "beans.xml");
   }

* http://d.hatena.ne.jp/backpaper0/20121202/1354465585

JAX-RS 2.0の新機能
------------------------------------

JAX-RS 2.0からは以下のような機能が追加されます。

* フィルター
* インターセプター
* 非同期処理
* クライアントAPI
* Bean Validationとの統合

フィルター
~~~~~~~~~~~~~~

リクエスト・レスポンスそれぞれに対応するフィルターを書けます。

.. code-block:: java

   @Provider
   public class LoggingFilter implements ContainerRequestFilter, ContainerResponseFilter {

       @Override
       public void filter(ContainerRequestContext requestContext) throws IOException {
           Logger.getLogger("request");
       }

       @Override
       public void filter(ContainerRequestContext requestContext,
               ContainerResponseContext responseContext) throws IOException {
           Logger.getLogger("response");
       }
   }

インターセプター
~~~~~~~~~~~~~~~~~~~~~~

エンティティボディを読み書きするところに横入りしてごにょごにょできます。

.. code-block:: java

   @Provider
   public class StarInterceptor implements ReaderInterceptor, WriterInterceptor {

       @Override
       public Object aroundReadFrom(ReaderInterceptorContext context) throws IOException,
           WebApplicationException {
           Object entity = context.proceed();
           return "+" + entity + "+";
       }

       @Override
       public void aroundWriteTo(WriterInterceptorContext context) throws IOException,
           WebApplicationException {
           Object entity = context.getEntity();
           context.setEntity("*" + entity + "*");
           context.proceed();
       }
   }

アノテーションで適用する範囲を決める
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CDIも似たような感じですが、フィルター（インターセプター）にアノテーションを付けておくと同じアノテーションが付いているリソースクラス・リソースメソッドにそのフィルター（インターセプター）を噛ませることが出来るようです。

.. code-block:: java

   @NameBinding
   @Retention(RetentionPolicy.RUNTIME)
   @Target({ElementType.TYPE,
            ElementType.METHOD})
   public static @interface Logged {
   }

   @Logged
   @Provider
   public class LoggingFilter implements ContainerRequestFilter, ContainerResponseFilter {
       ...

リソースメソッドはこんな感じ。

.. code-block:: java

   @POST
   @Logged
   public String post(String s) {
       ...

非同期処理
~~~~~~~~~~~~~~~~~~~~~~

Servlet 3.xにも非同期処理が入りましたが、JAX-RSにもやってきました。
以下のサンプルはJSR 339に乗っていたものです。

.. code-block:: java

   private static final BlockingQueue<AsyncResponse> suspended =
       new ArrayBlockingQueue<AsyncResponse>(5);

   @GET
   @Produces("text/plain")
   public void readMessage(@Suspended AsyncResponse ar) throws InterruptedException {
       suspended.put(ar);
   }

   @POST
   @Produces("text/plain")
   public String postMessage(final String message) throws InterruptedException {
       final AsyncResponse ar = suspended.take();
       ar.resume(message); // resumes the processing of one GET request
       return "Message sent";
   }

うん、使いどころがわかりません！

使ってみたい
~~~~~~~~~~~~~~~~~~~~~~

というわけで、JAX-RS 2.0のリリースはまだですが、いち早く試したい場合はJersey 2.xを使ってみましょう！

.. code-block:: xml

   <dependencies>
     <dependency>
       <groupId>org.glassfish.jersey.core</groupId>
       <artifactId>jersey-server</artifactId>
       <version>2.0-rc1</version>
     </dependency>
     <dependency>
       <groupId>org.glassfish.jersey.test-framework.providers</groupId>
       <artifactId>jersey-test-framework-provider-jdk-http</artifactId>
       <version>2.0-rc1</version>
       <scope>test</scope>
     </dependency>
   </dependencies>

まとめ
--------------------

* JAX-RSいいね！
* もうServletは要らないですね
* ところで「いいね！Java EE！」の第二回はあるんですかね？

資料の手直し、最後の方疲れたので投げやりです。
まあ、またJAX-RSは話題に出すと思いますので書ききれなかった（書き忘れた）アレとかソレはまたの機会にー。

.. author:: default
.. categories:: none
.. tags:: JAX-RS, Jersey, Java
.. comments::

