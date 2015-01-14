Spring BootのサンプルをJAX-RSにしてみた
================================================================================

先日写経したSpring BootのサンプルがSpring MVCで書かれていたのでJAX-RS、
というかJersey MVCにしてみました。

* :doc:`/2015/01/11/spring_boot`

ソースコードは先日と同じ場所に置いてあります。

* https://github.com/backpaper0/spring_boot_sample

tag作りました。

* https://github.com/backpaper0/spring_boot_sample/releases/tag/jaxrs

やったこと
--------------------------------------------------------------------------------

まず `Spring Bootのドキュメント <http://docs.spring.io/spring-boot/docs/1.2.1.RELEASE/reference/htmlsingle/#boot-features-jersey>`_ を参考にしてpom.xmlの編集とJerseyConfigクラスを作成しました。

次に `Jerseyのリファレンス <https://jersey.java.net/documentation/latest/mvc.html#mvc.spi>`_ を参考にしてTemplateProcessorの実装クラスを作成しました。

そして各ControllerクラスをSpring MVC仕様からJAX-RS仕様に変更しました。
詳細書くのは面倒なのでコミット見てください。

例外出た
--------------------------------------------------------------------------------

一通りコードを書いて、IDEから動かしたら起動時に例外が出ました。

.. code-block:: none

   java.util.concurrent.ExecutionException: org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Tomcat].StandardHost[localhost].StandardContext[]]
       at java.util.concurrent.FutureTask.report(FutureTask.java:122)
       at java.util.concurrent.FutureTask.get(FutureTask.java:192)
       at org.apache.catalina.core.ContainerBase.startInternal(ContainerBase.java:917)
       at org.apache.catalina.core.StandardHost.startInternal(StandardHost.java:868)
       at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150)
       at org.apache.catalina.core.ContainerBase$StartChild.call(ContainerBase.java:1409)
       at org.apache.catalina.core.ContainerBase$StartChild.call(ContainerBase.java:1399)
       at java.util.concurrent.FutureTask.run(FutureTask.java:266)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
       at java.lang.Thread.run(Thread.java:745)
   Caused by: org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Tomcat].StandardHost[localhost].StandardContext[]]
       at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:154)
       ... 6 common frames omitted
   Caused by: java.lang.NoSuchMethodError: javax.servlet.ServletContext.addFilter(Ljava/lang/String;Ljavax/servlet/Filter;)Ljavax/servlet/FilterRegistration$Dynamic;
       at org.springframework.boot.context.embedded.FilterRegistrationBean.onStartup(FilterRegistrationBean.java:250)
       at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.selfInitialize(EmbeddedWebApplicationContext.java:222)
       at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.access$000(EmbeddedWebApplicationContext.java:84)
       at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext$1.onStartup(EmbeddedWebApplicationContext.java:206)
       at org.springframework.boot.context.embedded.tomcat.TomcatStarter.onStartup(TomcatStarter.java:54)
       at org.apache.catalina.core.StandardContext.startInternal(StandardContext.java:5185)
       at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150)
       ... 6 common frames omitted

なんかサーブレットAPIが古いようです。

十中八九Jersey関連が持ってきたんだろうな、と思いつつ、調査しました。
maven-dependency-plugin の treeゴールを使えば依存関係を一覧できます。
`-l` オプションでログをファイルに書き出してエディタで検索するのが楽だと思います。

.. code-block:: sh

   mvn -l log.txt dependency:tree -Dscope=test

Mavenを実行すると次のようなログが書き出されました。

.. code-block:: none

   [INFO] Scanning for projects...
   [INFO]                                                                         
   [INFO] ------------------------------------------------------------------------
   [INFO] Building spring-boot-sample 1.0-SNAPSHOT
   [INFO] ------------------------------------------------------------------------
   [INFO] 
   [INFO] --- maven-dependency-plugin:2.9:tree (default-cli) @ spring-boot-sample ---
   [INFO] sample:spring-boot-sample:jar:1.0-SNAPSHOT
   [INFO] +- org.twitter4j:twitter4j-core:jar:4.0.2:compile
   [INFO] +- org.springframework.boot:spring-boot-starter-jersey:jar:1.2.1.RELEASE:compile
   [INFO] |  +- org.springframework.boot:spring-boot-starter:jar:1.2.1.RELEASE:compile
   [INFO] |  |  +- org.springframework.boot:spring-boot:jar:1.2.1.RELEASE:compile
   [INFO] |  |  +- org.springframework.boot:spring-boot-autoconfigure:jar:1.2.1.RELEASE:compile
   [INFO] |  |  +- org.springframework.boot:spring-boot-starter-logging:jar:1.2.1.RELEASE:compile
   [INFO] |  |  |  +- org.slf4j:jcl-over-slf4j:jar:1.7.8:compile
   [INFO] |  |  |  +- org.slf4j:jul-to-slf4j:jar:1.7.8:compile
   [INFO] |  |  |  +- org.slf4j:log4j-over-slf4j:jar:1.7.8:compile
   [INFO] |  |  |  \- ch.qos.logback:logback-classic:jar:1.1.2:compile
   [INFO] |  |  |     \- ch.qos.logback:logback-core:jar:1.1.2:compile
   [INFO] |  |  \- org.yaml:snakeyaml:jar:1.14:runtime
   [INFO] |  +- org.springframework.boot:spring-boot-starter-tomcat:jar:1.2.1.RELEASE:compile
   [INFO] |  |  +- org.apache.tomcat.embed:tomcat-embed-core:jar:8.0.15:compile
   [INFO] |  |  +- org.apache.tomcat.embed:tomcat-embed-el:jar:8.0.15:compile
   [INFO] |  |  +- org.apache.tomcat.embed:tomcat-embed-logging-juli:jar:8.0.15:compile
   [INFO] |  |  \- org.apache.tomcat.embed:tomcat-embed-websocket:jar:8.0.15:compile
   [INFO] |  +- com.fasterxml.jackson.core:jackson-databind:jar:2.4.4:compile
   [INFO] |  |  +- com.fasterxml.jackson.core:jackson-annotations:jar:2.4.4:compile
   [INFO] |  |  \- com.fasterxml.jackson.core:jackson-core:jar:2.4.4:compile
   [INFO] |  +- org.hibernate:hibernate-validator:jar:5.1.3.Final:compile
   [INFO] |  |  +- javax.validation:validation-api:jar:1.1.0.Final:compile
   [INFO] |  |  +- org.jboss.logging:jboss-logging:jar:3.1.3.GA:compile
   [INFO] |  |  \- com.fasterxml:classmate:jar:1.0.0:compile
   [INFO] |  +- org.springframework:spring-core:jar:4.1.4.RELEASE:compile
   [INFO] |  +- org.springframework:spring-web:jar:4.1.4.RELEASE:compile
   [INFO] |  |  +- org.springframework:spring-aop:jar:4.1.4.RELEASE:compile
   [INFO] |  |  |  \- aopalliance:aopalliance:jar:1.0:compile
   [INFO] |  |  +- org.springframework:spring-beans:jar:4.1.4.RELEASE:compile
   [INFO] |  |  \- org.springframework:spring-context:jar:4.1.4.RELEASE:compile
   [INFO] |  |     \- org.springframework:spring-expression:jar:4.1.4.RELEASE:compile
   [INFO] |  +- org.glassfish.jersey.core:jersey-server:jar:2.14:compile
   [INFO] |  |  +- org.glassfish.jersey.core:jersey-common:jar:2.14:compile
   [INFO] |  |  |  +- org.glassfish.jersey.bundles.repackaged:jersey-guava:jar:2.14:compile
   [INFO] |  |  |  \- org.glassfish.hk2:osgi-resource-locator:jar:1.0.1:compile
   [INFO] |  |  +- org.glassfish.jersey.core:jersey-client:jar:2.14:compile
   [INFO] |  |  +- javax.annotation:javax.annotation-api:jar:1.2:compile
   [INFO] |  |  +- org.glassfish.hk2:hk2-api:jar:2.4.0-b06:compile
   [INFO] |  |  |  +- org.glassfish.hk2:hk2-utils:jar:2.4.0-b06:compile
   [INFO] |  |  |  \- org.glassfish.hk2.external:aopalliance-repackaged:jar:2.4.0-b06:compile
   [INFO] |  |  +- org.glassfish.hk2.external:javax.inject:jar:2.4.0-b06:compile
   [INFO] |  |  \- org.glassfish.hk2:hk2-locator:jar:2.4.0-b06:compile
   [INFO] |  |     \- org.javassist:javassist:jar:3.18.1-GA:compile
   [INFO] |  +- org.glassfish.jersey.containers:jersey-container-servlet-core:jar:2.14:compile
   [INFO] |  +- org.glassfish.jersey.containers:jersey-container-servlet:jar:2.14:compile
   [INFO] |  +- org.glassfish.jersey.ext:jersey-spring3:jar:2.14:compile
   [INFO] |  |  +- org.glassfish.hk2:hk2:jar:2.4.0-b06:compile
   [INFO] |  |  |  +- org.glassfish.hk2:config-types:jar:2.4.0-b06:compile
   [INFO] |  |  |  +- org.glassfish.hk2:core:jar:2.4.0-b06:compile
   [INFO] |  |  |  +- org.glassfish.hk2:hk2-config:jar:2.4.0-b06:compile
   [INFO] |  |  |  |  +- org.jvnet:tiger-types:jar:1.4:compile
   [INFO] |  |  |  |  \- org.glassfish.hk2.external:bean-validator:jar:2.4.0-b06:compile
   [INFO] |  |  |  +- org.glassfish.hk2:hk2-runlevel:jar:2.4.0-b06:compile
   [INFO] |  |  |  \- org.glassfish.hk2:class-model:jar:2.4.0-b06:compile
   [INFO] |  |  |     \- org.glassfish.hk2.external:asm-all-repackaged:jar:2.4.0-b06:compile
   [INFO] |  |  \- org.glassfish.hk2:spring-bridge:jar:2.4.0-b06:compile
   [INFO] |  \- org.glassfish.jersey.media:jersey-media-json-jackson:jar:2.14:compile
   [INFO] |     +- com.fasterxml.jackson.jaxrs:jackson-jaxrs-base:jar:2.3.2:compile
   [INFO] |     \- com.fasterxml.jackson.jaxrs:jackson-jaxrs-json-provider:jar:2.3.2:compile
   [INFO] |        \- com.fasterxml.jackson.module:jackson-module-jaxb-annotations:jar:2.3.2:compile
   [INFO] +- org.glassfish.jersey.ext:jersey-mvc:jar:2.14:compile
   [INFO] |  +- javax.servlet:servlet-api:jar:2.4:compile
   [INFO] |  \- javax.ws.rs:javax.ws.rs-api:jar:2.0.1:compile
   [INFO] +- org.springframework.boot:spring-boot-starter-test:jar:1.2.1.RELEASE:test
   [INFO] |  +- org.mockito:mockito-core:jar:1.10.8:test
   [INFO] |  |  \- org.objenesis:objenesis:jar:2.1:test
   [INFO] |  +- org.hamcrest:hamcrest-core:jar:1.3:test
   [INFO] |  +- org.hamcrest:hamcrest-library:jar:1.3:test
   [INFO] |  \- org.springframework:spring-test:jar:4.1.4.RELEASE:test
   [INFO] +- org.springframework.boot:spring-boot-starter-thymeleaf:jar:1.2.1.RELEASE:compile
   [INFO] |  +- org.springframework.boot:spring-boot-starter-web:jar:1.2.1.RELEASE:compile
   [INFO] |  |  \- org.springframework:spring-webmvc:jar:4.1.4.RELEASE:compile
   [INFO] |  +- org.thymeleaf:thymeleaf-spring4:jar:2.1.4.RELEASE:compile
   [INFO] |  |  +- org.thymeleaf:thymeleaf:jar:2.1.4.RELEASE:compile
   [INFO] |  |  |  +- ognl:ognl:jar:3.0.8:compile
   [INFO] |  |  |  \- org.unbescape:unbescape:jar:1.1.0.RELEASE:compile
   [INFO] |  |  \- org.slf4j:slf4j-api:jar:1.7.8:compile
   [INFO] |  \- nz.net.ultraq.thymeleaf:thymeleaf-layout-dialect:jar:1.2.7:compile
   [INFO] \- junit:junit:jar:4.12:test
   [INFO] ------------------------------------------------------------------------
   [INFO] BUILD SUCCESS
   [INFO] ------------------------------------------------------------------------
   [INFO] Total time: 3.425 s
   [INFO] Finished at: 2015-01-14T23:02:38+09:00
   [INFO] Final Memory: 21M/165M
   [INFO] ------------------------------------------------------------------------

servlet-apiを検索してヒットした箇所を見るとやはりjersey-mvcが依存していました。

`dependency要素にexclusion要素を追加してservlet-apiへの依存を除外した <https://github.com/backpaper0/spring_boot_sample/commit/0f5c45d893948976d9f8dacfccc3790498dcd364>`_
ところIDEからも起動できました。

所感
--------------------------------------------------------------------------------

Spring MVCはMVCと言うだけあってビューを持つアプリケーションはさくさく作れそうな気がしました。

それに対してJAX-RSは単純にJSONを返すというようなAPIを作るのに特化してるなー、と改めて思いました。

まあ、そんな感じで。
おしまい。

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot, JAX-RS
.. comments::
