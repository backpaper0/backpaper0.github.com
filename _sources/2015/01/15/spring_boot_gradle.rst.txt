Spring BootのサンプルをGradle化した、けども……
================================================================================

最近Spring Bootで遊んでいます。

* :doc:`/2015/01/14/spring_boot_jersey`

今回はMavenでビルドされているサンプルをGradle化しました。

ソースコードは https://github.com/backpaper0/spring_boot_sample です。

tagは https://github.com/backpaper0/spring_boot_sample/releases/tag/gradle です。

本題
--------------------------------------------------------------------------------

まず、おもむろにgradle initしました。

.. sourcecode:: sh

   gradle init

すでにpom.xmlがあるので依存関係とか色々よろしくやってくれたbuild.gradleが出力されました。

.. sourcecode:: groovy

   apply plugin: 'java'
   apply plugin: 'maven'
   
   group = 'sample'
   version = '1.0-SNAPSHOT'
   
   description = """spring-boot-sample"""
   
   sourceCompatibility = 1.8
   targetCompatibility = 1.8
   
   
   
   repositories {
           
        maven { url "http://repo.maven.apache.org/maven2" }
   }
   dependencies {
       compile group: 'org.twitter4j', name: 'twitter4j-core', version:'4.0.2'
       compile(group: 'org.springframework.boot', name: 'spring-boot-starter-jersey', version:'1.2.1.RELEASE') {
   exclude(module: 'spring-webmvc')
       }
       compile(group: 'org.glassfish.jersey.ext', name: 'jersey-mvc', version:'2.14') {
   exclude(module: 'servlet-api')
       }
       compile group: 'org.springframework.boot', name: 'spring-boot-starter-thymeleaf', version:'1.2.1.RELEASE'
       testCompile(group: 'org.springframework.boot', name: 'spring-boot-starter-test', version:'1.2.1.RELEASE') {
   exclude(module: 'commons-logging')
       }
       testCompile group: 'junit', name: 'junit', version:'4.12'
   }

あとはSpring Bootのリファレンスの
`10.1.2 Gradle installation <http://docs.spring.io/spring-boot/docs/1.2.1.RELEASE/reference/htmlsingle/#getting-started-gradle-installation>`_
を参考にしてちょこちょこっと編集しました。

.. sourcecode:: groovy

   buildscript {
     repositories {
       jcenter()
       maven { url "http://repo.spring.io/snapshot" }
       maven { url "http://repo.spring.io/milestone" }
     }
     dependencies {
       //ここで拡張プロパティspringBootVersionは参照できひんの？_(:3｣∠)_
       classpath("org.springframework.boot:spring-boot-gradle-plugin:1.2.1.RELEASE")
     }
   }
   
   apply plugin: 'java'
   apply plugin: 'spring-boot'
   apply plugin: 'eclipse'
   apply plugin: 'idea'
   
   group = 'sample'
   version = '1.0-SNAPSHOT'
   
   sourceCompatibility = 1.8
   targetCompatibility = 1.8
   
   ext {
     springBootVersion = '1.2.1.RELEASE'
   }
   
   repositories {
     jcenter()
     maven { url "http://repo.spring.io/snapshot" }
     maven { url "http://repo.spring.io/milestone" }
   }
   
   dependencies {
     compile 'org.twitter4j:twitter4j-core:4.0.2'
     compile ("org.springframework.boot:spring-boot-starter-jersey:$springBootVersion") {
       exclude(module: 'spring-webmvc')
     }
     compile ('org.glassfish.jersey.ext:jersey-mvc:2.14') {
       exclude(module: 'servlet-api')
     }
     compile "org.springframework.boot:spring-boot-starter-thymeleaf:$springBootVersion"
     testCompile ("org.springframework.boot:spring-boot-starter-test:$springBootVersion") {
       exclude(module: 'commons-logging')
     }
     testCompile 'junit:junit:4.12'
   }

知りたいこと
--------------------------------------------------------------------------------

build.gradleにも書いたけどbuildscriptのブロック内で拡張プロパティspringBootVersionを参照できないのでしょうか？
（試しに使ってみたらビルド失敗した。。。）

教えてくださいお願いしますお願いします（他力本願）。

早速解決しました！
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. raw:: html

   <blockquote class="twitter-tweet" lang="ja"><p><a href="https://twitter.com/backpaper0">@backpaper0</a> buildscriptブロック内で拡張プロパティが使えない件ですが、buildscriptブロック内で拡張プロパティを定義すれば、全体でその値を使えたと思いますよー</p>&mdash; さときち (@satokittyd) <a href="https://twitter.com/satokittyd/status/555730693188091904">2015, 1月 15</a></blockquote>
   <script async src="//platform.twitter.com/widgets.js" charset="utf-8">{}</script>

ありがとうございます！

`修正してコミットしました！ <https://github.com/backpaper0/spring_boot_sample/commit/8ba07180a7758000522ebf99007d4c2b629378e2>`_

まとめ
--------------------------------------------------------------------------------

Gradle化すげえ簡単だった。

あわせて読みたい
--------------------------------------------------------------------------------

* `初心者大歓迎! webアプリを作ってみよう!勉強会のレポ起因にブログ書いてもらったからやってみた！！！ - そこに仁義はあるのか(仮) <http://syobochim.hatenablog.com/entry/2015/01/25/193327>`_

.. author:: default
.. categories:: none
.. tags:: Java, Spring Boot, Gradle
.. comments::
