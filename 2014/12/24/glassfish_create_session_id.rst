GlassFishでセッションIDを生成してるところ
================================================================================

これは `GlassFish Advent Calendar 2014 <http://www.adventar.org/calendars/383>`_ の24日目です。

相変わらずの小ネタです。

以前調べたのですが、
GlassFishでのHttpSession実装クラスは ``org.apache.catalina.session.StandardSession`` で、
これはTomcatのコードを利用したものですが、
セッションIDの生成処理は変更されているようです。

なんやかんや辿って行くと ``com.enterprise.util.uuid.UuidUtil`` の ``generateUuid``
メソッドに行き着きました。

コードを引用します。

  .. code-block:: java

     //this method can take in the session object
     //and insure better uniqueness guarantees
     public static String generateUuid(Object obj) {

         //low order time bits
         long presentTime = System.currentTimeMillis();
         int presentTimeLow = (int) presentTime;
         String presentTimeStringLow = formatHexString(presentTimeLow);

         StringBuilder sb = new StringBuilder(50);
         sb.append(presentTimeStringLow);
         //sb.append(":");
         sb.append(getIdentityHashCode(obj));
         //sb.append(":");
         //sb.append(_inetAddr);
         sb.append(addRandomTo(_inetAddr));
         //sb.append(":");
         sb.append(getNextRandomString());
         return sb.toString();
     }

ご覧の通り、

* システム日付
* セッションオブジェクトのIdentityハッシュコード
* ローカルホストのIPアドレス
* ランダムな文字列

を繋げたものになっています。

ここから呼び出されているメソッドを細かく見て行くと7文字で切ってたりしてマジこれでセキュアなん？
とか思ってしまったりしましたが "insure better uniqueness guarantees"
とか書かれてるし衝突耐性高くて大丈夫なんでしょうたぶん。

ちなみに ``org.apache.catalina.session.StandardSession`` は `org.glassfish.main.web:web-core <http://repo1.maven.org/maven2/org/glassfish/main/web/web-core/4.1/>`_ に、
``com.enterprise.util.uuid.UuidUtil`` は `org.glassfish.main.common:common-util <http://repo1.maven.org/maven2/org/glassfish/main/common/common-util/4.1/>`_ に入っています。


というわけであっさりしていますが、以上。

GlassFishさん、来年もお世話になります！

.. author:: default
.. categories:: none
.. tags:: Java, GlassFish, security
.. comments::
