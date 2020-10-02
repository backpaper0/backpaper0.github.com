MacBook ProでPayara Microのクラスタリングを試そうとして躓いたけど出来た！
================================================================================

問題
--------------------------------------------------------------------------------


`Payara Micro Clustering <http://www.payara.co/payara_micro_clustering>`_
を見ながらクラスタリング試そうと思ってあれしてみたんですが全然クラスタ組んでくれない！

Payara Microを2つ立ち上げた際の2つめのPayara Microのログの抜粋(クラスタ関連)がこれ。

.. sourcecode:: none

   [2015-06-19T04:03:01.749+0900] [Payara 4.1] [INFO] [] [com.hazelcast.cluster.impl.MulticastJoiner] [tid: _ThreadID=1 _ThreadName=main] [timeMillis: 1434654181749] [levelValue: 800] [[
     [192.168.99.1]:5901 [dev] [3.4.2]
   
   
   Members [1] {
           Member [192.168.99.1]:5901 this
   }
   ]]

ご覧の通りメンバーがいない！
ソロ活動だ！

クラスタ組んでくだされ〜(´;ω;`)

解決
--------------------------------------------------------------------------------

などとTwitterで嘆いてたら `かずひらさん <https://twitter.com/kazuhira_r>`_
が助けてくれた！

.. raw:: html

   <blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">NICも指定できないし…&#10;&#10;あとは、-Djava.net.preferIPv4Stack=trueにしてIPv4にしてみるとかかな…</p>&mdash; かずひら (@kazuhira_r) <a href="https://twitter.com/kazuhira_r/status/611382429039788033">2015, 6月 18</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

かずひらさん、それです！

というわけで次のようにすればいけた。

.. sourcecode:: sh

   java -Djava.net.preferIPv4Stack=true -jar payara-micro-4.1.152.1.jar --deploy clusterjsp.war --port 8000

これでクラスタが組める！
組めるぞおおおおおおお！
( ﾟ∀ﾟ)ｱﾊﾊ八八ﾉヽﾉヽﾉヽﾉ ＼ / ＼/ ＼

.. sourcecode:: none

   [2015-06-19T04:11:18.909+0900] [Payara 4.1] [INFO] [] [com.hazelcast.cluster.ClusterService] [tid: _ThreadID=45 _ThreadName=hz.glassfish-web.server.generic-operation.thread-1] [timeMillis: 1434654678909] [levelValue: 800] [[
     [192.168.99.1]:5900 [dev] [3.4.2]
   
   Members [21] {
           Member [192.168.99.1]:5900 this
           Member [192.168.99.1]:5901
           Member [192.168.99.1]:5902
           Member [192.168.99.1]:5903
           Member [192.168.99.1]:5904
           Member [192.168.99.1]:5905
           Member [192.168.99.1]:5906
           Member [192.168.99.1]:5907
           Member [192.168.99.1]:5908
           Member [192.168.99.1]:5909
           Member [192.168.99.1]:5910
           Member [192.168.99.1]:5911
           Member [192.168.99.1]:5912
           Member [192.168.99.1]:5913
           Member [192.168.99.1]:5914
           Member [192.168.99.1]:5915
           Member [192.168.99.1]:5916
           Member [192.168.99.1]:5917
           Member [192.168.99.1]:5918
           Member [192.168.99.1]:5919
           Member [192.168.99.1]:5920
   }
   ]]

無駄に21クラスタ！

ここまで書いて、
まだまだいけんじゃね？と思い、
調子に乗ってPMC48(Payara Micro Clusterデス)とかやろうとしたけど30パヤラ越えたあたりからMacさんが唸りだしたのでビビって止めてしまった。

謝辞
--------------------------------------------------------------------------------

かずひらさんありがとうございました！！！

.. author:: default
.. categories:: none
.. tags:: Java, Payara, Mac
.. comments::
