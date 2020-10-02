Grgitでコミットのハッシュ値をファイルに書き出してwarに入れる
================================================================================

今デプロイされてるwarはどのコミットから作ったんじゃろ？
っていう疑問を解決するためのやつです。
Gradleでwarを作る前に
`Grgit <https://github.com/ajoberstar/grgit>`_
というものを使ってコミットのハッシュ値をファイルに書き出しておいて
warに入れてしまってついでにJAX-RSのリソースとしてあれしてしまいましょう、
という話。

build.gradle
--------------------------------------------------------------------------------

まずGrgitを使う準備。
Gradleは普通にGroovyコードを書けて便利。

.. sourcecode:: groovy

   import org.ajoberstar.grgit.Grgit
   
   ext.repo = Grgit.open(project.file('.'))
   
   buildscript {
       repositories {
           jcenter()
           mavenCentral()
       }
       dependencies {
           classpath('org.ajoberstar:gradle-git:1.1.0')
       }
   }

次にハッシュをファイルに書き出すタスクの定義とwarタスクとの依存関係の設定。
今回はwarファイル内の `WEB-INF/classes/head` にファイルがパッケージングされるようにしました。

.. sourcecode:: groovy

   task writeHeadCommitHash << {
       def file = new File(buildDir, 'git/head')
       file.parentFile.mkdirs()
       file.write(repo.head().id)
   }
   
   war.classpath new File(buildDir, 'git')
   
   war.dependsOn writeHeadCommitHash

JAX-RSのリソースクラス
--------------------------------------------------------------------------------

.. sourcecode:: java

   package javayou;
   
   import java.io.IOException;
   import java.net.URISyntaxException;
   import java.net.URL;
   import java.nio.file.Files;
   import java.nio.file.Paths;
   
   import javax.enterprise.context.RequestScoped;
   import javax.inject.Named;
   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.core.MediaType;
   
   @Named
   @RequestScoped
   @Path("head")
   public class GitCommitHashResource {
   
       @GET
       @Produces(MediaType.TEXT_PLAIN)
       public String getHead() {
           URL resource = getClass().getResource("/head");
           if (resource != null) {
               try {
                   byte[] b = Files.readAllBytes(Paths.get(resource.toURI()));
                   return new String(b);
               } catch (URISyntaxException | IOException ignored) {
               }
           }
           return "<none>";
       }
   }

コーディング中にIDEから動かしたとかそういうときはファイルが無いから
<none>
って表示されるようにしています。

これで、このリソースにアクセスすればどのコミットから作られたwarなのかが分かるます。

動くコード例
--------------------------------------------------------------------------------

* https://github.com/backpaper0/java-you

動かして http://localhost:8080/java-you/api/head を開いてください。

.. author:: default
.. categories:: none
.. tags:: Java, JAX-RS, Git, Gradle, Grgit
.. comments::
