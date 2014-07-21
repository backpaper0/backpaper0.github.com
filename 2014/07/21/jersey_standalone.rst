Jerseyをjava -jarで動かす
==========================

Jerseyはサーブレット経由でなく `com.sun.net.httpserver.HttpServer <http://docs.oracle.com/javase/jp/7/jre/api/net/httpserver/spec/index.html>`_
や `Grizzly <https://grizzly.java.net/>`_ 、Jettyで動かす事もできるのでmaven-shade-pluginなどでひとつのJARにまとめてしまえば ``java -jar``
で実行できるJAX-RSアプリケーションの完成です。

例えば ``com.sun.net.httpserver.HttpServer`` を使用するやつをdependenciesに突っ込んで、

.. code-block:: xml

   <dependencies>
     <dependency>
       <groupId>org.glassfish.jersey.containers</groupId>
       <artifactId>jersey-container-jdk-http</artifactId>
     </dependency>
   </dependencies>
 
   <dependencyManagement>
     <dependencies>
       <dependency>
         <groupId>org.glassfish.jersey</groupId>
         <artifactId>jersey-bom</artifactId>
         <version>2.10.1</version>
         <scope>import</scope>
         <type>pom</type>
       </dependency>
     </dependencies>
   </dependencyManagement>

mavne-shade-pluginを突っ込んで、

.. code-block:: xml

   <plugin>
     <groupId>org.apache.maven.plugins</groupId>
     <artifactId>maven-shade-plugin</artifactId>
     <version>2.3</version>
     <executions>
       <execution>
         <id>standalone-jar</id>
         <phase>package</phase>
         <goals>
           <goal>shade</goal>
         </goals>
         <configuration>
           <transformers>
             <transformer
               implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
               <mainClass>app.Main</mainClass>
             </transformer>
           </transformers>
     	  <createDependencyReducedPom>false</createDependencyReducedPom>
         </configuration>
       </execution>
     </executions>
   </plugin>

JAX-RSなコードを書いて ``mvn package`` でJAR作って ``java -jar hoge.jar`` で動かしましょう。

ギッハブにもサンプル置いています。

* `jersey-standalone-example <https://github.com/backpaper0/sandbox/tree/master/jersey-standalone-example>`_

Gradleではどうやったら良いんでしょうね？
誰か書いて下さいお願いします。

.. author:: default
.. categories:: none
.. tags:: JAX-RS, Jersey, Java, Maven
.. comments::
