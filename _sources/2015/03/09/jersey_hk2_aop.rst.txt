Jerseyでリソースメソッドをトランザクション境界にする
================================================================================

ちょろっと話題に出たので簡単にまとめました。

やりたいこと
--------------------------------------------------------------------------------

リソースメソッドをトランザクション境界にしたい。

話題に出た方法
--------------------------------------------------------------------------------

`ContainerRequestFilter <http://docs.oracle.com/javaee/7/api/javax/ws/rs/container/ContainerRequestFilter.html>`_
や
`ContainerResponseFilter <http://docs.oracle.com/javaee/7/api/javax/ws/rs/container/ContainerResponseFilter.html>`_
を使って実現できないかなー、という話が出ましたが私は無理だと思っています。

ContainerRequestFilter
はリソースメソッドの前に実行されるだけ、
ContainerResponseFilter
はリソースメソッドの後に実行されるだけで
try-catch-finally
ができないからです。

パッと思いつく方法
--------------------------------------------------------------------------------

GlasFishなどJava EE 7準拠のアプリケーションサーバで動かすのであればリソースクラスを
CDI管理ビーンにして
`@Transactional <http://docs.oracle.com/javaee/7/api/javax/transaction/Transactional.html>`_
で注釈すればそれだけでリソースメソッドがトランザクション境界になります。

Tomcat + Jerseyぐらいの構成で実現する方法
--------------------------------------------------------------------------------

CDI使ってない、っていうかTomcatで動かしてる、つーかDIコンテナ使ってない！！！という場合はどうすれば良いのか？

Jerseyは内部的に `HK2 <https://hk2.java.net/>`_ というDIコンテナを使っています。
このHK2のAOP機能を利用してリソースクラスにインテーセプターを適用して
リソースメソッドをトランザクション境界にする方法が取れます。

ザクッとサンプル書いてみたので詳細はコードを読んでください。

* https://github.com/backpaper0/jersey-interceptor-sample

まとめ
--------------------------------------------------------------------------------

* JAX-RSの仕様ではサーブレットフィルタのような try-catch-finally ができるポイントが無い
* CDIを併用すれば何とでもなる
* Jerseyなら実装に依存するけどHK2を使うことで何とかなる

.. author:: default
.. categories:: none
.. tags:: Java, Jersey, HK2
.. comments::
