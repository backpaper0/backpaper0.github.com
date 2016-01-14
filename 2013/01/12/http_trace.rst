GlassFish v3.1.2.2でTRACEメソッドを許可しない 
================================================= 

デフォルトで許可しないようになっていますが備忘録的に一応書いておきます。 
asadminコマンドで設定します。

.. sourcecode:: sh 

    asadmin set configs.config.server-config.network-config.protocols.protocol.http-listener-1.http.trace-enabled=false 

もちろんGUI管理コンソールからも設定可能で、構成 -> server-config -> ネットワーク構成 -> プロトコル -> http-listener-1 の「HTTP」タブを開いてトレースのチェックを外します。 

この状態でTRACEリクエストを投げると405 Method Not Allowedが返ってきます。 

.. author:: default
.. categories:: none
.. tags:: Java, GlassFish, HTTP, Security
.. comments::
