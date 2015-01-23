Gitでブランチを統合する方法
================================================================================

こういうコミットを重ねたブランチを、

.. image:: /images/git_rebase_merge_1.*

どういう方法でmasterに統合すると嬉しい派なのか？っていう小ネタです。

マージする
--------------------------------------------------------------------------------

.. image:: /images/git_rebase_merge_2.*

.. code-block:: sh

   git checkout master
   git merge other -m "Merge branch 'other'"
   git branch -d other

操作が分かりやすい感じがする。

リベースする
--------------------------------------------------------------------------------

.. image:: /images/git_rebase_merge_3.*

.. code-block:: sh

   git checkout master
   git rebase master other
   git checkout master
   git merge other
   git branch -d other

コミットが一本化する。

リベースしてからマージする
--------------------------------------------------------------------------------

.. image:: /images/git_rebase_merge_4.*

.. code-block:: sh

   git checkout master
   git rebase master other
   git checkout master
   git merge other --no-ff -m "Merge branch 'other'"
   git branch -d other

コミットが一本化しつつブランチ単位の作業を把握しやすい。

まとめ
--------------------------------------------------------------------------------

私はリベースしてからマージする派！

おまけ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

最初に提示したコミットを作るスクリプト。

.. code-block:: sh

   #!/bin/sh
   rm -fr .git *.txt .gitignore
   git init
   echo init.sh>.gitignore && git add .gitignore && git commit -m "Initial Commit"
   echo b>b.txt && git add b.txt && git commit -m "master 1"
   git branch other
   echo c>c.txt && git add c.txt && git commit -m "master 2"
   echo d>d.txt && git add d.txt && git commit -m "master 3"
   git checkout other
   echo e>e.txt && git add e.txt && git commit -m "other 1"
   echo f>f.txt && git add f.txt && git commit -m "other 2"
   git checkout master

.. author:: default
.. categories:: none
.. tags:: Git
.. comments::
