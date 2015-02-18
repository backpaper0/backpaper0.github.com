よく使うasadminのコマンドを紹介する
================================================================================

これは `GlassFish Advent Calendar 2014 <http://www.adventar.org/calendars/383>`_ の7日目です。

小ネタです。
私がよく使うasadminのコマンドを、引数も書いて実際に使っている感じを出しつつ紹介します。

``asadmin list-commands``
  どんなコマンドあったっけなー、ってときどき確認します。
``asadmin list-domain``
  GlassFishはドメインという単位で管理しますが、このコマンドで今あるドメインを確認します。
``asadmin delete-domain domain1``
  要らんドメインを消します。
  ドメインは ``glassfish/domains/`` 以下に作成されますが、ここを心を込めて手動で消しても大丈夫っぽいです。
``asadmin create-domain --portbase=9000 domain1``
  ドメインを作ります。
  portbaseを指定すればHTTPは9080、管理は9048という風に良い感じにポートを設定してくれます。
``asadmin start-domain domain1``
  ドメインを起動します。
  後述するcreate-jdbc-connection-poolコマンドなど一部のコマンドはドメインが起動していないと実行できなかったりします。
``asadmin stop-domain domain1``
  起動しているドメインを停止します。
``asadmin create-jdbc-connection-pool --datasourceclassname org.h2.jdbcx.JdbcDataSource --restype javax.sql.DataSource --property url=jdbc\\:h2\\:sampleDB:user=sa:password=secret samplePool``
  JDBCコネクションプールを作ります。
  propertyにURLを書く場合、コロンをエスケープしないといけないので気をつけましょー。
  一番最後の引数(この例でいうとsamplePool)がコネクションプールIDです。
  なお、JDBCドライバは ``glassfish/domains/domain1/lib/ext/`` (domain1はドメインの名前なので適宜置き換えてください)に置きます。
``asadmin create-jdbc-resource --connectionpoolid samplePool jdbc/sample``
  JDBCリソースを作ります。
  アプリケーションからはここで設定したJNDI名(この例でいうとjdbc/sample)で参照します。
  ひとつのJDBCコネクションプールに対して複数のJDBCリソースを作ることもできます。
``asadmin create-jvm-options -Xmx1024m``
  JVMオプションを設定します。
  この例では最大メモリサイズを設定しています。
  このコマンドで設定したJVMオプションはドメインを再起動したときに反映されます。
``asadmin set-log-levels org.seasar.doma=CONFIG``
  ログレベルを設定します。
``asadmin deploy --contextroot=sample --name=sample sample.war``
  デプロイします。
``asadmin redeploy --name=sample sample.war``
  再デプロイします。
  デプロイと再デプロイでコマンドを使い分けなきゃダメなのはちょっと面倒です。
``asadmin undeploy sample``
  アンデプロイします。
  引数にはデプロイ時に設定したnameを指定します。

とまあ、よく使うのはこんな所でしょうか。
自分が思っていたより少なかったですね。

簡単ですが、以上になります。
おそまつさまでした。

.. author:: default
.. categories:: none
.. tags:: Java, GlassFish
.. comments::
