スタックトレースろふ #irof
================================================================================

これは `いろふ Advent Calendar 2014 <http://www.adventar.org/calendars/331>`_ の1日目です。

いろふアドベントカレンダーとは、我らが `いろふさん <https://twitter.com/irof>`_
への愛をワールドワイドなインターネッツに大公開する感じのやつです。

いろふさんをご存じない方はTwitterでﾋｮﾛｰをキメて、著書である養成読本を熟読すると良いですよ！

*  `Javaエンジニア養成読本［現場で役立つ最新知識、満載！］：書籍案内｜技術評論社 <http://gihyo.jp/book/2014/978-4-7741-6931-6>`_

本編という名の出オチ
--------------------------------------------------------------------------------

こちらのリポジトリをcloneして、

* https://github.com/backpaper0/sandbox

irofディレクトリに移動し ``gradlew run`` してください。

するとこうなります。

.. image:: /images/stacktracerof.*

なんといろふさんが例外吐いて終了しました！ (-∧-；)　ﾅﾑｰ

投げっぱなしの解説
--------------------------------------------------------------------------------

Java言語ではメソッド名に空白や記号を使えませんがクラスファイルとJVM的にはもうちょい制約緩いっぽいので
その辺を利用してスタックトレースでいろふさんを描きました。

いろふさんのアイコンからAAを作ったのは次のサービスです。

* http://www.text-image.com/convert/ascii.html

で、クラスファイルを書き出したのはASMというライブラリです。

* http://asm.ow2.org/

ASMの `ClassWriter <http://asm.ow2.org/asm50/javadoc/user/org/objectweb/asm/ClassWriter.html>`_
と `GeneratorAdapter <http://asm.ow2.org/asm50/javadoc/user/org/objectweb/asm/commons/GeneratorAdapter.html>`_
を使えば割と簡単にクラスファイルを書き出す事ができます。
詳しくはGeneratorAdapterのJavadocと今回のいろふソースコードを参照ください。

それと今回は使っていませんが `ClassReader <http://asm.ow2.org/asm50/javadoc/user/org/objectweb/asm/ClassReader.html>`_
を使うとクラスファイルを読む事ができます。

例えばインスタンスメソッドを実行してるコードを見つけて標準出力に書き出すようなアレは次のように書けます。

.. sourcecode:: java

   ClassReader reader = new ClassReader("irof.Irof");

   MethodVisitor methodVisitor = new MethodVisitor(Opcodes.ASM5) {

       @Override
       public void visitMethodInsn(int opcode, String owner, String name, String desc, boolean itf) {
           if (opcode == Opcodes.INVOKEVIRTUAL) {
               System.out.printf("owner=%1$s name=%2$s desc=%3$s%n", owner, name, desc);
           }
       }
   };

   ClassVisitor classVisitor = new ClassVisitor(Opcodes.ASM5) {

       @Override
       public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
           return methodVisitor;
       }
   };

   reader.accept(classVisitor, 0);

ちなみにASMはJDKにも入っています。
``rt.jar`` の ``com.sun.xml.internal.ws.org.objectweb.asm`` 以下がそうですね。
JAX-WSに使われているようです。

あと `jersey-server <http://repo1.maven.org/maven2/org/glassfish/jersey/core/jersey-server/>`_ にも使われています。
``jersey.repackaged.org.objectweb.asm`` 以下がそうです。

まとめ
--------------------------------------------------------------------------------

いざやってみるとすんなり出来ちゃって変態度が低すぎてアレですが、まあいいか。

.. author:: default
.. categories:: none
.. tags:: Java, irof
.. comments::
