Spring Bootのサンプルで使ってるアノテーションをJSR 330のものにした
================================================================================

最近Spring Bootで遊んでいます。

* :doc:`/2015/01/15/spring_boot_gradle`
* :doc:`/2015/01/14/spring_boot_jersey`
* :doc:`/2015/01/11/spring_boot`

今回はSpringのアノテーションである
`@Component <http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/stereotype/Component.html>`_
と
`@Autowired <http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/beans/factory/annotation/Autowired.html>`_
をJSR 330のアノテーションである
`@Named <http://docs.oracle.com/javaee/7/api/javax/inject/Named.html>`_
と
`@Inject <http://docs.oracle.com/javaee/7/api/javax/inject/Inject.html>`_
に変更してみました。

ソースコードは https://github.com/backpaper0/spring_boot_sample です。

tagは https://github.com/backpaper0/spring_boot_sample/releases/tag/jsr330 です。

本題
--------------------------------------------------------------------------------

特に書くことない。
普通に置き換えたら普通に動いたので。

ただしスコープのアノテーションはSpringのままです。
セッションスコープのクラスに付けたアノテーションを
`@SessionScoped <http://docs.oracle.com/javaee/7/api/javax/enterprise/context/SessionScoped.html>`_
に変更したかったのですがJSR 330ではなくCDIのアノテーションのためどうしようもなかったというかなんというか。

まあいいか。

まとめ
--------------------------------------------------------------------------------

JSR 330のアノテーションの方が見慣れていて個人的には良い。

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot, JSR 330
.. comments::
