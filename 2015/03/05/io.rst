Reader/Writer/InputStream/OutputStream
================================================================================

少し話題に出たのでファイル読み書きなどでよく使う感じのアレをアレしたいと思います。

まず、

* ``InputStream`` / ``OutputStream`` はバイナリデータのストリームです。
  ``byte[]`` で読み書きします。
* ``Reader`` / ``Writer`` はテキストデータのストリームです。
  ``char[]`` で読み書きします。
* ストリームというのは ``byte[]`` や ``char[]`` を使って少しずつデータを読み込んだり書き出したりするためのものです。

というのが基本になります。

ファイルの読み書き
--------------------------------------------------------------------------------

テキストファイルを読み込む
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: java

   Path path = Paths.get("path/to/file");
   try (BufferedReader in = Files.newBufferedReader(path)) {
       //読み込み処理
   }

ファイルはUTF-8で読み込まれます。

UTF-8以外のファイルを読み込む場合は第二引数に ``Charset`` を渡します。

.. sourcecode:: java

   try (BufferedReader in = Files.newBufferedReader(path, Charset.forName("Windows-31J"))) {
       String line;
       while(null != (line = in.readLine())) {
           //読み込み処理
       }
   }

バイナリファイルを読み込む
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: java

   try (InputStream in = new BufferedInputStream(Files.newInputStream(path))) {
       byte[] b = new byte[1000];
       int i;
       while (-1 != (i = in.read(b))) {
           //読み込み処理
       }
   }

``Files.newInputStream`` はバッファリングされないので巨大なファイルやたくさんファイルを扱う処理だと遅いと思います。
基本的には ``BufferedInputStream`` でラップする方が良いかとー。

テキストファイルを書き出す
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: java

   try (BufferedWriter out = Files.newBufferedWriter(path)) {
       //書き出し処理
   }

バイナリファイルを書き出す
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. sourcecode:: java

   try (OutputStream out = new BufferedOutputStream(Files.newOutputStream(path))) {
       //書き出し処理
   }

``Files.newInputStream`` と同じく ``Files.newOutputStream`` もバッファリングされません。

オンメモリで扱う
--------------------------------------------------------------------------------

``Writer`` を渡したらそこにもろもろ書き出してくれるライブラリがあるんだけど
わざわざファイルに書き出すんじゃなくてオンメモリで処理して ``String`` で結果を取りたいんや！
というような場合には ``StringWriter`` を使います。

.. sourcecode:: java

   StringWriter out = new StringWriter();
   library.writeTo(out);
   String result = out.toString();

``Reader`` / ``InputStream`` / ``OutputStream`` にもそれぞれオンメモリで使用するためのクラスがあります。

* ``StringReader`` は ``String`` を読み込める ``Reader``
* ``StringWriter`` は ``String`` へ書き出せる ``Writer``
* ``ByteArrayInputStream`` は ``byte[]`` を読み込める ``InputStream``
* ``ByteArrayOutputStream`` は ``byte[]`` へ書き出せる ``OutputStream``

InputStreamをReaderへ/OutputStreamをWriterへ変換する
--------------------------------------------------------------------------------

それぞれ ``InputStreamReader`` と ``OutputStreamWriter`` を使って変換できます。

.. sourcecode:: java

   InputStream in = ...
   Reader reader = new InputStreamReader(in, StandardCharsets.UTF_8);

   OutputStream out = ...
   Writer writer = new OutputStreamWriter(out, StandardCharsets.UTF_8);

第二引数に ``Charset`` を渡していますが、何も渡さない場合はデフォルトエンコーディングが使用されるので注意が必要です。
デフォルトエンコーディングとはシステムプロパティ ``file.encoding`` で取得できるものです。
変更したい場合は次のようにJava起動時にオプションを設定します。

.. sourcecode:: sh

   java -Dfile.encoding=UTF-8 com.example.MainClass

ZIPファイルを読み込む/書き出す
--------------------------------------------------------------------------------

ZIPファイルの読み書きには ``ZipInputStream`` と ``ZipOutputStream`` が使えます。

.. sourcecode:: java

   InputStream in = ...
   try(ZipInputStream zin = new ZipInputStream(in, StandardCharsets.UTF_8)) {
       ZipEntry zipEntry;
       while (null != (zipEntry = zin.getNextEntry())) {
           byte[] b = new byte[1000];
           int i;
           while (-1 != (i = zin.read(b))) {
               //読み込み処理
           }
       }
   }

.. sourcecode:: java

   OutputStream out = ...
   try(ZipOutputStream zout = new ZipOutputStream(out, StandardCharsets.UTF_8)) {
       ZipEntry zipEntry = new ZipEntry("hoge.txt");
       zout.putNextEntry(zipEntry);
       byte[] b = ...
       zout.write(b);
       zout.closeEntry();
   }

ファイルのコピー、移動をする
--------------------------------------------------------------------------------

``Files`` を使います。

.. sourcecode:: java

   Path src = ...
   Path dest = ...

   Files.copy(src, dest);

   Files.move(src, dest);

Channel
--------------------------------------------------------------------------------

``Reader`` / ``Writer`` / ``InputStream`` / ``OutputStream``
の他に ``Channel`` というものもありますが ``Channel`` が必要になるライブラリには
ほぼ出会った事がないので覚えなくても生きて行けると思います。

おまけ
--------------------------------------------------------------------------------

テキストファイルの読み込みには ``Files.newBufferedReader`` を使うと書きましたが
Java 6までは ``FileReader`` を使って次のようにファイル読み込みをしていました。

.. sourcecode:: java

   File file = new File("path/to/file");
   Reader in = new FileReader(file);
   try {
       //読み込み処理
   } finally {
       in.close();
   }

``Charset`` を渡さずに ``FileReader`` をインスタンス化していますが、
この場合はデフォルトエンコーディングが使われていました。

しかも ``FileReader`` には ``Charset`` を受け取るコンストラクタは用意されていません。
ではデフォルトエンコーディング以外でファイルを読み込みたい場合はどうするのか？

その場合は、

1. ``FileInputStream`` でファイルを開いて
2. ``InputStreamReader`` で ``Charset`` を指定しつつラップする

という方法をとっていました。

.. sourcecode:: java

   File file = new File("path/to/file");
   Reader in = new InputStreamReader(new FileInputStream(file), Charset.forName("iso-2022-jp"));
   try {
       //読み込み処理
   } finally {
       in.close();
   }

そういう訳で ``java.io`` で ``Charset`` を受け取らない場合はデフォルトエンコーディング、
``java.nio.file`` で ``Charset`` を受け取らない場合はUTF-8が使われる、という感じです。

デフォルトエンコーディングは環境によって変わるので ``java.nio.file`` を使っておくのが安全だと思います。

.. author:: default
.. categories:: none
.. tags:: Java
.. comments::
