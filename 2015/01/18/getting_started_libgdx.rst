libGDXプロジェクトをセットアップする #libgdx
================================================================================

libGDXはJavaのゲームフレームワークで、デスクトップ・Android・iOS・HTML5用にビルドできるフレームワークです。
どのプラットフォームであっても起動用のクラス以外のほとんどのコードを共有できるすごいやつです。

* `libGDX <http://libgdx.badlogicgames.com/>`_
* `GitHubでホスティングされているlibGDXのWiki <https://github.com/libgdx/libgdx/wiki>`_

今回はlibGDXを使ったプロジェクトのセットアップ方法を書いていこうと思います。

セットアップツールによるプロジェクトの生成
--------------------------------------------------------------------------------

`ダウンロードページ <http://libgdx.badlogicgames.com/download.html>`_
で "Download Setup App" をクリックして gdx-seup.jar をダウンロードしてください。

ダウンロードできたらダブルクリック、もしくは次のコマンドで実行してください。

.. sourcecode:: sh

   java -jar gdx-setup.jar
   
.. image:: /images/gdx-setup-screenshot.*

各項目を編集します。

.. list-table::
   :widths: 2,8

   * - Name
     - プロジェクトの名前。Androidプロジェクトはres/values/string.xmlのapp_nameにも使用される。
   * - Package
     - 出力されるサンプルコードのパッケージ。AndroidManifest.xmlに書かれるpackageにも使用される。
   * - Game class
     - `ApplicationListener <http://libgdx.badlogicgames.com/nightlies/docs/api/com/badlogic/gdx/ApplicationListener.html>`_
       実装クラス。libGDXにおける起点となるクラス。
   * - Destination
     - プロジェクトの出力先ディレクトリ。
   * - Android SDK
     - Android SDKのパス。Android用のビルドをする場合に必要。

"LibGDX Version" は最新のものが選択されているはずなので、そのままで。

"Sub Projects" はすべてチェックされていると思います。
不要になればその時点で取り除けば良いし個別にビルドもできるので、これもそのままで。

"Extensions" は "Box2d" のみがチェックされていると思います。
ここについては詳しい解説が出来るほどの知識がありません。
誰か教えてください！
これもそのままでいきましょう。

以上の状態で "Generate" を押してください。

初回はGradleや依存JARのダウンロードが行われるので時間がかかります。
お茶でも飲んでお待ちください。

次のようなログが出ると完了です。

.. sourcecode:: none

   BUILD SUCCESSFUL
   
   Total time: 42.551 secs
   Done!
   To import in Eclipse: File -> Import -> Gradle -> Gradle Project
   To import to Intellij IDEA: File -> Import -> build.gradle
   To import to NetBeans: File -> Open Project...

.. note::

   プロジェクトのビルドには `Gradle <https://www.gradle.org/>`_
   ( `日本語ドキュメント <http://gradle.monochromeroad.com/docs/>`_ )が使われていますが、
   gdx-setup.jarが設定済みのbuild.gradleを出力してくれるのでGradleに詳しくなくても大丈夫です。

寄り道：Gitでバージョン管理を始める
--------------------------------------------------------------------------------

今後の事を考えてGitでのバージョン管理を始めておきましょう。

セットアップツールが .gitignore も出力してくれているのでややこしいことは何も考えずにバージョン管理を始められます。

.. sourcecode:: sh

   git init
   git add .
   git commit -m "Initial commit"

Eclipseへのインポート
--------------------------------------------------------------------------------

セットアップのログを見た感じだとEclipseにGradleプラグインが入っているとそのままインポート出来そうですね。

私はGradleプラグインが入っていないEclipseを使っているので、その場合のインポート方法を書きます。

まずGradleでコマンドを実行します。

.. sourcecode:: sh

   gradlew eclipse

次にEclipseのメニューから
:menuselection:`File --> Import --> General --> Existing Projects into Workspace`
を選択します。
それから "Select root directory" にプロジェクトのパスを入力してください。

.. note::

   プロジェクトのパスをコピーするときはMacなら次のコマンドを使うとクリップボードに格納されて便利です。

   .. sourcecode:: sh

      pwd|pbcopy

   Windowsなら次のコマンドで同じ事ができます。

   .. sourcecode:: bat

      cd|clip

インポートするプロジェクトは code と desktop だけで良いでしょう。
基本的にはデスクトップで開発してたまに実機確認という感じで進められると思います。

インポートできたら（これが面倒なのですが）desktopプロジェクトにあるassetsディレクトリをクラスパスに加えてください。

手っ取り早い方法はassetsディレクトリで右クリックして
:menuselection:`Build Path --> Use as Source Folder`
です。

もしくは、プロジェクトのプロパティを開いて
:menuselection:`Java Build Path --> Libraries`
と辿って "Add Class Folder" を押してassetsディレクトリを指定してください。

IntelliJ IDEAへのインポート
--------------------------------------------------------------------------------

私はIntelliJ IDEA分からんのですが、セットアップのログに書かれているように
:menuselection:`File --> Import --> build.gradle`
をやってみたところインポートできたっぽいです。

実行する
--------------------------------------------------------------------------------

desktopプロジェクトの ``src/main/java/yourpackage/DesktopLauncher.java`` を実行してください。
( ``yourpackage`` はセットアップ時に設定したパッケージです。
適宜読み替えてください。)

結び
--------------------------------------------------------------------------------

というわけでlibGDXプロジェクトのセットアップ方法を記載してみました。

libGDXはAndroidアプリであってもデスクトップ中心で開発でき、
コードの殆どを共有できるのがすごくて嬉しくてお気に入りです。

願わくばもっともっとlibGDXユーザーが増えますように！

.. author:: default
.. categories:: none
.. tags:: Java, libGDX
.. comments::
