NetBeans 7.2.1でJPQLの補完するー
========================================

こんばんは！
em.cQ と打って control + space で createQuery を補完するうらがみです。

もうキャメルケースでの補完が無かったら生きて行けません。
これはEcliなんとかでも出来ます。
たぶんIDEAでも出来るでしょう。

本題。
NetBeansではJPQLの補完もできます、という話。

.. image:: /images/compl1.*

FROM も。

.. image:: /images/compl2.*

エンティティ名も。

.. image:: /images/compl3.*

WHERE や、

.. image:: /images/compl4.*

プロパティも。

.. image:: /images/compl5.*

演算子も。

.. image:: /images/compl6.*

という感じです。
でもこれローカル変数に突っ込むと補完してくれないのが残念です。

.. image:: /images/compl7.*

あと@NamedQueryに書くJPQLでも補完できます。

.. image:: /images/compl8.*

ローカル変数に突っ込んだときも補完が効いてくれるようになるともっと嬉しいですねー。
簡単ですが、そんな感じでー。

.. author:: default
.. categories:: none
.. tags:: NetBeans,JPQL,JPA,Java
.. comments::
