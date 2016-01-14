GlassFish 3.1.2.2の管理コンソールでlocalhostをプロキシ経由しようとしていて困ったけど解決した話
=================================================================================================

現象
----------

ローカルでGlassFish 3.1.2.2を動かして管理コンソールを開こうと思ったら開けなくて困りました。

具体的には次のような症状です。

* デフォルトのドメイン ``domain1`` で管理コンソールの起動にかなり時間がかかる。
* ``domain1`` は管理パスワードが設定されていないのでログインなしで管理コンソールを開けるはずなのにログインフォームが表示される。
* ユーザー名だけ入力してログインしようとするとかなり時間がかかった挙げ句ログインできない。



環境
-------

* GlassFish 3.1.2.2
* JDK 1.7.0_65
* Windows 7
* ネットワークの設定でプロキシ設定済み



調査
---------

まず管理コンソールの起動に時間がかかっている際のスレッドダンプを取得することにしました。

GlassFishを起動して ``http://localhost:4848`` をブラウザで開きます。

管理コンソールがなかなか起動されないことを確認したあと
JVisualVMでGlassFishに接続してボタンぽちっとスレッドダンプ取得しました。
JVisualVM便利。

スレッドダンプをエディタにコピペして ``glassfish`` という文字列を検索してそれっぽいスレッドを探しました。

その結果、次に記載するスレッドが怪しそうでした。
ソケットからのデータ読み込み中で止まってる感じがします。

.. sourcecode:: none

   "admin-thread-pool-4848(3)" daemon prio=6 tid=0x000000000a861800 nid=0xb08 runnable [0x000000001275c000]
      java.lang.Thread.State: RUNNABLE
       at java.net.SocketInputStream.socketRead0(Native Method)
       at java.net.SocketInputStream.read(SocketInputStream.java:152)
       at java.net.SocketInputStream.read(SocketInputStream.java:122)
       at java.io.BufferedInputStream.fill(BufferedInputStream.java:235)
       at java.io.BufferedInputStream.read1(BufferedInputStream.java:275)
       at java.io.BufferedInputStream.read(BufferedInputStream.java:334)
       - locked <0x00000000f7a63a80> (a java.io.BufferedInputStream)
       at sun.net.www.http.HttpClient.parseHTTPHeader(HttpClient.java:687)
       at sun.net.www.http.HttpClient.parseHTTP(HttpClient.java:633)
       at sun.net.www.protocol.http.HttpURLConnection.getInputStream(HttpURLConnection.java:1323)
       - locked <0x00000000f7a47030> (a sun.net.www.protocol.http.HttpURLConnection)
       at java.net.HttpURLConnection.getResponseCode(HttpURLConnection.java:468)
       at com.sun.jersey.client.urlconnection.URLConnectionClientHandler._invoke(URLConnectionClientHandler.java:240)
       at com.sun.jersey.client.urlconnection.URLConnectionClientHandler.handle(URLConnectionClientHandler.java:147)
       at com.sun.jersey.api.client.filter.CsrfProtectionFilter.handle(CsrfProtectionFilter.java:97)
       at com.sun.jersey.api.client.Client.handle(Client.java:648)
       at com.sun.jersey.api.client.WebResource.handle(WebResource.java:670)
       at com.sun.jersey.api.client.WebResource.access$200(WebResource.java:74)
       at com.sun.jersey.api.client.WebResource$Builder.get(WebResource.java:503)
       at org.glassfish.admingui.common.util.RestUtil.get(RestUtil.java:755)
       at org.glassfish.admingui.common.util.RestUtil.restRequest(RestUtil.java:191)
       at org.glassfish.admingui.common.handlers.RestApiHandlers.restRequest(RestApiHandlers.java:223)
       at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
       at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
       at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
       at java.lang.reflect.Method.invoke(Method.java:606)
       at com.sun.jsftemplating.layout.descriptors.handler.Handler.invoke(Handler.java:442)
       at com.sun.jsftemplating.layout.descriptors.LayoutElementBase.dispatchHandlers(LayoutElementBase.java:420)
       at com.sun.jsftemplating.layout.descriptors.LayoutElementBase.dispatchHandlers(LayoutElementBase.java:394)
       at com.sun.jsftemplating.layout.descriptors.LayoutComponent.beforeCreate(LayoutComponent.java:348)
       at com.sun.jsftemplating.layout.descriptors.LayoutComponent.getChild(LayoutComponent.java:288)
       at com.sun.jsftemplating.layout.LayoutViewHandler.buildUIComponentTree(LayoutViewHandler.java:556)
       at com.sun.jsftemplating.layout.LayoutViewHandler.createView(LayoutViewHandler.java:255)
       at com.sun.faces.lifecycle.RestoreViewPhase.execute(RestoreViewPhase.java:247)
       at com.sun.faces.lifecycle.Phase.doPhase(Phase.java:101)
       at com.sun.faces.lifecycle.RestoreViewPhase.doPhase(RestoreViewPhase.java:116)
       at com.sun.faces.lifecycle.LifecycleImpl.execute(LifecycleImpl.java:118)
       at javax.faces.webapp.FacesServlet.service(FacesServlet.java:593)
       at org.apache.catalina.core.StandardWrapper.service(StandardWrapper.java:1550)
       at org.apache.catalina.core.ApplicationDispatcher.doInvoke(ApplicationDispatcher.java:809)
       at org.apache.catalina.core.ApplicationDispatcher.invoke(ApplicationDispatcher.java:671)
       at org.apache.catalina.core.ApplicationDispatcher.processRequest(ApplicationDispatcher.java:505)
       at org.apache.catalina.core.ApplicationDispatcher.doDispatch(ApplicationDispatcher.java:476)
       at org.apache.catalina.core.ApplicationDispatcher.dispatch(ApplicationDispatcher.java:355)
       at org.apache.catalina.core.ApplicationDispatcher.forward(ApplicationDispatcher.java:305)
       at org.glassfish.admingui.common.security.AdminConsoleAuthModule.validateRequest(AdminConsoleAuthModule.java:232)
       at com.sun.enterprise.security.jmac.config.GFServerConfigProvider$GFServerAuthContext.validateRequest(GFServerConfigProvider.java:1171)
       at com.sun.web.security.RealmAdapter.validate(RealmAdapter.java:1452)
       at com.sun.web.security.RealmAdapter.invokeAuthenticateDelegate(RealmAdapter.java:1330)
       at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:551)
       at org.apache.catalina.core.StandardPipeline.doInvoke(StandardPipeline.java:623)
       at org.apache.catalina.core.StandardPipeline.invoke(StandardPipeline.java:595)
       at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:161)
       at org.apache.catalina.connector.CoyoteAdapter.doService(CoyoteAdapter.java:331)
       at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:231)
       at com.sun.enterprise.v3.services.impl.ContainerMapper$AdapterCallable.call(ContainerMapper.java:317)
       at com.sun.enterprise.v3.services.impl.ContainerMapper.service(ContainerMapper.java:195)
       at com.sun.grizzly.http.ProcessorTask.invokeAdapter(ProcessorTask.java:860)
       at com.sun.grizzly.http.ProcessorTask.doProcess(ProcessorTask.java:757)
       at com.sun.grizzly.http.ProcessorTask.process(ProcessorTask.java:1056)
       at com.sun.grizzly.http.DefaultProtocolFilter.execute(DefaultProtocolFilter.java:229)
       at com.sun.grizzly.DefaultProtocolChain.executeProtocolFilter(DefaultProtocolChain.java:137)
       at com.sun.grizzly.DefaultProtocolChain.execute(DefaultProtocolChain.java:104)
       at com.sun.grizzly.DefaultProtocolChain.execute(DefaultProtocolChain.java:90)
       at com.sun.grizzly.http.HttpProtocolChain.execute(HttpProtocolChain.java:79)
       at com.sun.grizzly.ProtocolChainContextTask.doCall(ProtocolChainContextTask.java:54)
       at com.sun.grizzly.SelectionKeyContextTask.call(SelectionKeyContextTask.java:59)
       at com.sun.grizzly.ContextTask.run(ContextTask.java:71)
       at com.sun.grizzly.util.AbstractThreadPool$Worker.doWork(AbstractThreadPool.java:532)
       at com.sun.grizzly.util.AbstractThreadPool$Worker.run(AbstractThreadPool.java:513)
       at java.lang.Thread.run(Thread.java:745)

JerseyクライアントでHTTPリクエストを行っているようです。

``RestApiHandlers.java:223`` にブレークポイントを置いてデバッグしてみることにしました。
デバッグにはEclipseを使いました。

一旦ドメインを停止してデバッグモードで起動し直します。

.. sourcecode:: none

   asadmin start-domain --debug domain1

起動したらコンソールにデバッグポートが表示されるのでそれを参考にリモートデバッグします。
Eclipseのデバッグの設定から ``Remote Java Application`` を選んで実行します。

デバッグ用に適当にプロジェクトを作りました。
``dependency`` は適当に使ってそうなやつを突っ込んでおきました。

.. sourcecode:: xml

   <dependencies>
     <dependency>
       <groupId>org.glassfish.main.admingui</groupId>
       <artifactId>console-core</artifactId>
       <version>3.1.2.2</version>
     </dependency>
     <dependency>
       <groupId>org.glassfish.main.admingui</groupId>
       <artifactId>console-common</artifactId>
       <version>3.1.2.2</version>
     </dependency>
   </dependencies>

.. note:: ちなみにNetBeansはこんな面倒なことをしなくてもプロジェクトをデバッグ実行すれば自動でGlassFishもデバッグモードで起動したと思います。

そんな感じでデバッグしてみたところ
``http://localhost:4848/management/domain/anonymous-user-enabled``
へのGETリクエストがなかなか返って来ませんでした。

やっとこさ返ってきたレスポンスは503エラーでした。
エンティティボディを見るとプロキシから応答が無いなどと書かれており
HTTPリクエストがプロキシ経由になっているのがマズいようでした。



対応
------

``localhost`` をプロキシを通過する対象から外してみました。

.. sourcecode:: none

   asadmin create-jvm-options -Dhttp.nonProxyHosts=localhost

GlassFishを再起動して管理コンソールにアクセスすると問題なく起動してくれました。

というわけで当座の問題は解決しました。



疑問
------

Windowsのプロキシ設定には
"ローカル アドレスにはプロキシ サーバーを使用しない"
というチェックボックスがありますが、
これにチェック入れてもJavaのソケットAPIは ``localhost`` を除外してくれないのでしょうか？

教えてエロいひと！



.. author:: default
.. categories:: none
.. tags:: Java, GlassFish
.. comments::
