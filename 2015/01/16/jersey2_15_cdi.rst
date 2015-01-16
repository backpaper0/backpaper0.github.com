Jersey 2.15のCDI統合を試す
================================================================================

Jersey 2.15でCDIとの統合機能が変更されたようです。

* https://github.com/jersey/jersey/releases/tag/2.15

ざっくり読むと、これまではJava EEコンテナ(ていうかGlassFish？)との統合に注力してたけど
2.15からはJava EE環境じゃなくても統合できまっせ！という感じっぽいです。

試した
--------------------------------------------------------------------------------

ハローワールドな、なんの役にも立たないWeb APIを作って試してみました。

* https://github.com/backpaper0/sandbox/tree/master/jersey2_15-cdi-example

メインクラスはこんな感じ。

.. code-block:: java

   package example;
   
   import java.net.URI;
   
   import org.glassfish.jersey.jdkhttp.JdkHttpServerFactory;
   import org.glassfish.jersey.server.ResourceConfig;
   import org.jboss.weld.environment.se.Weld;
   
   import com.sun.net.httpserver.HttpServer;
   
   public class App {
   
       public static void main(String[] args) {
           Weld weld = new Weld();
           weld.initialize();
           URI uri = URI.create("http://localhost:8080/");
           ResourceConfig config = new ResourceConfig(HelloResource.class);
           HttpServer server = JdkHttpServerFactory.createHttpServer(uri, config);
           Runtime.getRuntime().addShutdownHook(new Thread(() -> {
               server.stop(0);
               weld.shutdown();
           }));
   
           System.out.println("http://localhost:8080/hello?name=YourName");
       }
   }

ご覧の通りです。
普通にWeldを動かして、Jerseyを動かしてるだけです。
簡単です。

pom.xmlのdependencyはこんな感じ。

.. code-block:: xml
 
   <dependency>
     <groupId>org.glassfish.jersey.ext.cdi</groupId>
     <artifactId>jersey-weld2-se</artifactId>
   </dependency>
   <dependency>
     <groupId>org.glassfish.jersey.ext.cdi</groupId>
     <artifactId>jersey-cdi1x</artifactId>
   </dependency>

所感
--------------------------------------------------------------------------------

私はJava EEは好きですがJava SEでも簡単に動くようになるのは嬉しいのでこの変更は嬉しいです！

アホっぽい感想ですが、まあそんな感じでー。

.. author:: default
.. categories:: none
.. tags:: Java, Jersey, JAX-RS, CDI
.. comments::
