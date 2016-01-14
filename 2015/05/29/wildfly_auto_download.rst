GradleでWildflyを自動でダウンロードしてからArquillianを実行する
================================================================================

Java EEなアプリケーションのテストを回すのに `Arquillian <http://arquillian.org/>`_
が便利なんですけど、
サンプル書くのに手動でアプリケーションサーバをダウンロードするのはちょい面倒なので、
Gradleにダウンロードしてもらうっていう話です。

アプリケーションサーバは `Wildfly <http://wildfly.org/>`_ を使用します。

それではbuild.gradleをいじりましょー！

まずdependenciesにWildflyのアーカイブを追加します。

.. sourcecode:: groovy

   dependencies {
       archives "org.wildfly:wildfly-dist:$wildflyVersion@zip"
   }

次にアーカイブをunzipするタスクを書きます。

.. sourcecode:: groovy

   task readyWildfly(type: Copy) {
       def wildflyZip = configurations.archives.find { it.name ==~ /wildfly.*/ }
   
       from zipTree(wildflyZip)
       into buildDir
   
       inputs.file wildflyZip
       outputs.upToDateWhen { new File(buildDir, "wildfly-$wildflyVersion").exists() }
   }

既にunzipされたWildflyがあったらタスクをスキップしてほしいので
``inputs.file`` と ``outputs.upToDateWhen`` でこちょこちょやっています。

* 参考： `Gradleで変更がない場合にタスク実行をスキップする方法 - しおしお(´・ω・｀) <http://siosio.hatenablog.com/entry/2014/08/31/002105>`_

最後にテストを実行する前にreadyWildflyタスクを実行するようにします。

.. sourcecode:: groovy

   test.dependsOn readyWildfly

あとは ``gradlew build`` するだけ。

ログはこんな感じ。

.. sourcecode:: none

   :compileJava
   :processResources UP-TO-DATE
   :classes
   :war
   :assemble
   :readyWildfly
   :compileTestJava
   :processTestResources
   :testClasses
   :test
   :check
   :build
   
   BUILD SUCCESSFUL
   
   Total time: 31.107 secs
   
   This build could be faster, please consider using the Gradle Daemon: http://gradle.org/docs/2.4/userguide/gradle_daemon.html

testの前にreadyWildflyタスクが実行されていますね。
この時点で所定の場所へWildflyがunzipされています。

ではもう一度 ``gradlew build`` してみましょう。

.. sourcecode:: none

   :compileJava UP-TO-DATE
   :processResources UP-TO-DATE
   :classes UP-TO-DATE
   :war UP-TO-DATE
   :assemble UP-TO-DATE
   :readyWildfly
   :compileTestJava UP-TO-DATE
   :processTestResources UP-TO-DATE
   :testClasses UP-TO-DATE
   :test UP-TO-DATE
   :check UP-TO-DATE
   :build UP-TO-DATE
   
   BUILD SUCCESSFUL
   
   Total time: 10.617 secs
   
   This build could be faster, please consider using the Gradle Daemon: http://gradle.org/docs/2.4/userguide/gradle_daemon.html

なんということでしょう！
readyWildflyタスクがスキップされま……されてない！？

あれー？？？(´･_･\`)

も、もう一度実行だ！

.. sourcecode:: none

   :compileJava UP-TO-DATE
   :processResources UP-TO-DATE
   :classes UP-TO-DATE
   :war UP-TO-DATE
   :assemble UP-TO-DATE
   :readyWildfly UP-TO-DATE
   :compileTestJava UP-TO-DATE
   :processTestResources UP-TO-DATE
   :testClasses UP-TO-DATE
   :test UP-TO-DATE
   :check UP-TO-DATE
   :build UP-TO-DATE
   
   BUILD SUCCESSFUL
   
   Total time: 8.532 secs
   
   This build could be faster, please consider using the Gradle Daemon: http://gradle.org/docs/2.4/userguide/gradle_daemon.html

なぜスキップされたし(・_・)

というわけで、なんかあと一歩で出来てない感がありますが、一番の目的である
「自動でWildflyの準備してArquillian走らせる」ってのは出来たので一旦これで良いやー。

* コード：https://github.com/backpaper0/sandbox/tree/master/jaxrs-async-sample

.. author:: default
.. categories:: none
.. tags:: Java, Gradle, Wildfly, Arquillian
.. comments::
