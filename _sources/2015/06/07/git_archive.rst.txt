Gitで管理してるソースをZIPにする
================================================================================

小ネタです。
メモ的な。

GitHubにもpushしてない状態でちょっと人に見てもらいたいなー、
ってときにDropboxに置いてーとかやる事があるんですが、
そのときに.gitまで含めたくないし.gitignoreで無視してるファイルも含めたくないときに使うやつです。

``git archive`` コマンドを使います。

.. sourcecode:: sh

   git archive --format=zip HEAD > ../hoge.zip

``--format`` に使えるフォーマットは ``git archive --list`` で確認できます。

.. author:: default
.. categories:: none
.. tags:: Git
.. comments::
