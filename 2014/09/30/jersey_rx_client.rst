Jersey ClientのRxサポートを軽〜く試す
======================================

Jersey 2.13がリリースされました。

* `Release Notes - Jersey 2.13 <https://jersey.java.net/release-notes/2.13.html>`_

リリースノートを見ると `[JERSEY-2639] - Jersey Client - Add Support for Rx <https://java.net/jira/browse/JERSEY-2639>`_ というのがあったので試してみましたん。

pom.xmlに突っ込むdependency
-------------------------------

`jersey-rx-clientの実装 <http://repo1.maven.org/maven2/org/glassfish/jersey/ext/rx/>`_ には、

* jersey-rx-client-guava
* jersey-rx-client-java8
* jersey-rx-client-jsr166e
* jersey-rx-client-rxjava 

があるっぽいですがRxJavaとかよく分かんないので今回はjava8で試します。

.. sourcecode:: xml

   <dependency>
     <groupId>org.glassfish.jersey.ext.rx</groupId>
     <artifactId>jersey-rx-client-java8</artifactId>
   </dependency>

クライアントコード
-------------------------

名前を渡したらこんにちは言ってくれるいつものリソースクラスがあったとします。

まずはふつうのJAX-RSクライアントのコード。

.. sourcecode:: java

   WebTarget target = ClientBuilder.newClient().target("http://localhost:8080/rest/hello");

   String resp = target.queryParam("name", "world")
                       .request()
                       .get(String.class);
         
   System.out.println(resp); //Hello, world!

うむ。普通。

次にRx板のコードです。

.. sourcecode:: java

   WebTarget target = ClientBuilder.newClient().target("http://localhost:8080/rest/hello");

   CompletionStage<String> stage = RxCompletionStage.from(target)
                                       .queryParam("name", "world")
                                       .request()
                                       .rx()
                                       .get(String.class);

   stage.thenAccept(s -> System.out.println(s)); //Hello, world!

ご覧の通り `CompletionStage <http://docs.oracle.com/javase/jp/8/api/java/util/concurrent/CompletionStage.html>`_ であれこれできるっぽいです。

まとめ
---------

RxJava学ぼうかな。

本日のコード
------------------

* https://github.com/backpaper0/sandbox/tree/master/jersey-rx-client-java8-example

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS, Rx, Jersey
.. comments::
