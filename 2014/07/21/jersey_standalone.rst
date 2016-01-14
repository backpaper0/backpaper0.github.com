Jerseyをjava -jarで動かす
==========================

Jerseyはサーブレット経由でなく `com.sun.net.httpserver.HttpServer <http://docs.oracle.com/javase/jp/7/jre/api/net/httpserver/spec/index.html>`_
や `Grizzly <https://grizzly.java.net/>`_ 、Jettyで動かす事もできるのでmaven-shade-pluginなどでひとつのJARにまとめてしまえば ``java -jar``
で実行できるJAX-RSアプリケーションの完成です。

例えば ``com.sun.net.httpserver.HttpServer`` を使用するやつをdependenciesに突っ込んで、

.. sourcecode:: xml

   <dependencies>
     <dependency>
       <groupId>org.glassfish.jersey.containers</groupId>
       <artifactId>jersey-container-jdk-http</artifactId>
     </dependency>
   </dependencies>
 
   <dependencyManagement>
     <dependencies>
       <dependency>
         <groupId>org.glassfish.jersey</groupId>
         <artifactId>jersey-bom</artifactId>
         <version>2.10.1</version>
         <scope>import</scope>
         <type>pom</type>
       </dependency>
     </dependencies>
   </dependencyManagement>

mavne-shade-pluginを突っ込んで、

.. sourcecode:: xml

   <plugin>
     <groupId>org.apache.maven.plugins</groupId>
     <artifactId>maven-shade-plugin</artifactId>
     <version>2.3</version>
     <executions>
       <execution>
         <id>standalone-jar</id>
         <phase>package</phase>
         <goals>
           <goal>shade</goal>
         </goals>
         <configuration>
           <transformers>
             <transformer
               implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
               <mainClass>app.Main</mainClass>
             </transformer>
           </transformers>
     	  <createDependencyReducedPom>false</createDependencyReducedPom>
         </configuration>
       </execution>
     </executions>
   </plugin>

JAX-RSなコードを書いて、

.. sourcecode:: java

   package app;
   
   import javax.ws.rs.DefaultValue;
   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.QueryParam;
   import javax.ws.rs.core.MediaType;
   
   @Path("hello")
   public class Hello {
   
       @GET
       @Produces(MediaType.TEXT_PLAIN)
       public String say(@QueryParam("name") @DefaultValue("world") String name) {
           return String.format("Hello, %s!", name);
       }
   }

メインクラス書いて、

.. sourcecode:: java

   package app;
   
   import java.net.URI;
   
   import org.glassfish.jersey.filter.LoggingFilter;
   import org.glassfish.jersey.jdkhttp.JdkHttpServerFactory;
   import org.glassfish.jersey.server.ResourceConfig;
   
   public class Main {
   
       public static void main(String[] args) {
   
           //ベースとなるURL
           URI uri = URI.create("http://localhost:8080/");
   
           //リソースクラスなどを登録する
           //以下は一例
           ResourceConfig config = new ResourceConfig();
   
           //appパッケージ以下のリソースクラスなどJAX-RSに関係するクラスを登録する
           //パッケージは再帰的にスキャンされる
           config.packages(true, "app");
   
           //リクエストとレスポンスに関する情報をログ出力するフィルターを登録する
           config.register(LoggingFilter.class);
   
           //サーバー起動
           JdkHttpServerFactory.createHttpServer(uri, config);
   
           //http://localhost:8080/hello?name=foobar にアクセスして動作確認
           //control + cでJVM落としてサーバも停止する
       }
   }

``mvn package`` でJAR作って ``java -jar hoge.jar`` で動かしましょう。

ギッハブにもサンプル置いています。

* `jersey-standalone-example <https://github.com/backpaper0/sandbox/tree/master/jersey-standalone-example>`_

Gradleではどうやったら良いんでしょうね？
誰か書いて下さいお願いします。

.. author:: default
.. categories:: none
.. tags:: JAX-RS, Jersey, Java, Maven
.. comments::
