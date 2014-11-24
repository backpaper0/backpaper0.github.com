Java SEでWebSocketサーバを立てて遊ぶ
=============================================

先だってリリースされたJava EE 7に `JSR 356: Java API for WebSocket`_ が入りました。 
GlassFish v4などを利用すればWebSocketで遊べます。

が、やっぱJava SEで動かしたいですよね？
ね？

というわけでJSR 356の参照実装であるTyrusを使います。

* `Tyrus Project`_

サーバ側のエンドポイントを作成します。
POJOにアノテーションを付ける感じです。

.. code-block:: java

   import javax.websocket.OnClose;
   import javax.websocket.OnMessage;
   import javax.websocket.OnOpen;
   import javax.websocket.Session;
   import javax.websocket.server.ServerEndpoint;
   
   @ServerEndpoint("/echo")
   public class EchoServerEndPoint {
   
       @OnOpen
       public void onOpen(Session session) {
           System.out.println("[open] " + session);
       }
   
       @OnMessage
       public String onMessage(String message, Session session) {
           System.out.println("[" + message + "] " + session);
           return message;
       }
   
       @OnClose
       public void onClose(Session session) {
           System.out.println("[close] " + session);
       }
   }

@OnOpenはセッションが確立したとき、@OnMessageはクライアントからメッセージが届いたとき、@OnCloseはセッションが切断されたときに呼ばれます。
@OnMessageを付けたメソッドではクライアントが送信したテキストをStringの引数で受け取ることができます。
なお、バイナリメッセージだとbyte[]やByteBufferで受け取れるようです。
また、このメソッドはStringを返していますがこれはクライアントへ送信されるテキストメッセージとなります。

では次にこれをJava SEで動かすためのコードを書きます。

.. code-block:: java

   import java.io.IOException;
   import javax.websocket.DeploymentException;
   import org.glassfish.tyrus.server.Server;
   
   public class EchoMain {
   
       public static void main(String[] args) throws Exception {
           Server server = new Server("localhost", 8080, "/ws", EchoServerEndPoint.class);
           try {
               server.start();
               System.in.read();
           } finally {
               server.stop();
           }
       }
   }

Serverのコンストラクタにホスト、ポート、ルートパス、エンドポイントのクラスを渡してインスタンス化し、startメソッドを呼べばWebSocketサーバの出来上がりです。
あとはクライアントから ws://localhost:8080/ws/echo に接続すればOKです。
簡単ですね。

今日のソース
------------------

* https://github.com/backpaper0/sandbox/tree/master/websocket-example

.. _Tyrus Project: https://tyrus.java.net/
.. _JSR 356\: Java API for WebSocket: http://jcp.org/en/jsr/detail?id=356

.. author:: default
.. categories:: none
.. tags:: Java, WebSocket, Tyrus
.. comments::
