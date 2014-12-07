Tinkererにはてなスターを設置した
================================================================================

`Tinkerer <http://tinkerer.me/>`_ で書いてるこのブログに `はてなスター <http://s.hatena.ne.jp/>`_
を設置したのでその辺まとめておきます。
なお、私は `modern5` をベースにカスタマイズしたテーマを使用していますので別のテーマだと多少異なるかも知れません。

まずはてなスターのマイページでブログを登録します。
マイページのURLは http://s.hatena.ne.jp/<自分のID> です。

次に _templates/page.html のextraheadブロック(
`{%- block extrahead -%}` と `{%- endblock -%}`
に囲まれたところ)に次のJavaScriptコードを書きます。

.. code-block:: html

   <script type="text/javascript">
      Hatena.Star.Token = <自分のトークン>;
      Hatena.Star.SiteConfig = {
        entryNodes: {
          'div.main-container': {
            uri: 'window.location',
            title: 'document.title',
            container: 'span.hatenastar'
          }
        }
      };
   </script>

`<自分のトークン>` にはマイページでブログを追加したあとに表示されるトークンを書いてください。

最後に実際にはてなスターを設置する場所となる要素を追加します。
私はエントリのいっちゃん下に置きたかったのでbodyブロックの最後の方に次のspan要素を書きました。

.. code-block:: html

   <span class="hatenastar"> </span>

自分のTinkererちからが低すぎて悩んだりもしたけれど、出来てしまえば簡単でした！

より詳しくは http://d.hatena.ne.jp/hatenastar/20070707 を参照くださいですじゃ。

.. author:: default
.. categories:: none
.. tags:: Tinkerer, Hatena
.. comments::
