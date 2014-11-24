Java API for WebSocketの@PathParamを試す
=============================================

`@PathParam`_ というアノテーションでパスの一部をメソッドの引数で受け取ることができるようなので試してみました。

.. code-block:: java

   package chat;
   
   import java.io.IOException;
   import java.util.concurrent.CopyOnWriteArraySet;
   import javax.websocket.OnClose;
   import javax.websocket.OnMessage;
   import javax.websocket.OnOpen;
   import javax.websocket.Session;
   import javax.websocket.server.PathParam;
   import javax.websocket.server.ServerEndpoint;
   
   @ServerEndpoint(value = "/chat/{guest-id}")
   public class ChatEndPoint {
   
       private static CopyOnWriteArraySet<Session> sessions = new CopyOnWriteArraySet<>();
   
       @OnOpen
       public void onOpen(@PathParam("guest-id") String guestId, Session session) {
           sessions.add(session);
           for (Session s : sessions) {
               s.getAsyncRemote().sendText(guestId + "さんが入室しました");
           }
       }
   
       @OnMessage
       public void onMessage(@PathParam("guest-id") String guestId, String text) throws
               IOException {
           for (Session s : sessions) {
               s.getAsyncRemote().sendText("[" + guestId + "] " + text);
           }
       }
   
       @OnClose
       public void onClose(@PathParam("guest-id") String guestId, Session session) {
           sessions.remove(session);
           for (Session s : sessions) {
               s.getAsyncRemote().sendText(guestId + "さんが退室しました");
           }
       }
   }

クラスに付けたServerEndpointに書かれたパスの一部が {guest-id} となっていますね。
それをメソッドの引数に @PathParam("guest-id") と付けて受け取っています。
簡単ですね。

今回のソース
--------------------

* https://github.com/backpaper0/sandbox/tree/master/websocket-example

今回作ったクラスはchatというパッケージにしています。
また、mvn -Pchat exec:java とすればサーバが立ち上がるようにしています。
クライアントはchat.htmlです。
Chromeで何となく動くことを確認しています。
サーバを終了したい場合はコンソールで何かキーを押してください。

なお、今回のコードはきしださんが下記エントリで書かれたものを参考にしました。

* http://d.hatena.ne.jp/nowokay/20130613

.. _@PathParam: http://docs.oracle.com/javaee/7/api/javax/websocket/server/PathParam.html

.. author:: default
.. categories:: none
.. tags:: Java, WebSocket, Tyrus
.. comments::
