前方一致の検索条件とドメインクラス #doma2
================================================================================

`Doma 2 <http://doma.readthedocs.org/>`_ で前方一致の検索条件をドメインクラスでどう扱うか考えた話です。

馬鹿正直にドメインクラスを使う
--------------------------------------------------------------------------------

SIerで業務アプリ作ってると検索して結果をグリッド表示する画面とかよく作ると思うんですが、
その際に前方一致の検索条件を扱う事も多いのです。

例えば従業員を検索するときに条件に従業員番号と所属部門番号を使えるとします。
加えて、どちらも前方一致で検索するとします。
この検索を行うDAOメソッドを何も考えずに書くとこうなります。

.. code-block:: java

   @Select
   List<Emp> select(EmpId empId, DeptId deptId);

ちなみにSQLファイルは雰囲気こんな感じで。

.. code-block:: sql

   SELECT /*%expand */*
     FROM emp
    WHERE empId LIKE /* empId */'AA%'
      AND deptId LIKE /* deptId */'BB%'

EmpIdは従業員番号を表すドメインクラスです。
検索条件は前方一致、つまり従業員番号の後ろが欠けた中途半端な状態のものが渡される可能性があります。
そういった項目にEmpIdを使用するのはおかしいのではないでしょうか？

Stringを使う
--------------------------------------------------------------------------------

そこで検索条件を汎用的な型であるStringに変更します。

.. code-block:: java

   @Select
   List<Emp> select(String empId, String deptId);

EmpIdの不適切な使用はなくなりましたが、
`select(deptId, empId)` というふうに引数の順番を間違えてもコンパイル時に検出されなくなってしまいました。

ドメインクラスPrefix<DOMAIN>を作る
--------------------------------------------------------------------------------

というわけで考えたのがPrefix<DOMAIN>というドメインクラスです。

次にコードを記載します。

.. code-block:: java

   import java.util.Optional;
   
   import org.seasar.doma.Domain;
   
   @Domain(valueType = String.class, factoryMethod = "of")
   public class Prefix<DOMAIN> {
   
       private final String value;
   
       private Prefix(String value) {
           this.value = value;
       }
   
       public String getValue() {
           return value;
       }
   
       public static <T> Prefix<T> of(String value) {
           return Optional.ofNullable(value).map(x -> new Prefix<T>(x)).orElse(null);
       }
   }

型パラメータDOMAINには他のドメインクラスをバインドします。

このPrefix<DOMAIN>を使用するとDAOメソッドは次のようになります。

.. code-block:: java

   @Select
   List<Emp> select(Prefix<EmpId> empId, Prefix<DeptId> deptId);

これで、

* ドメインクラスに適しない前方一致に使用するような中途半端な状態を持てる
* DAOメソッドの引数の順を間違えてもコンパイル時に検出できる

という思いを実現する事ができました。
現時点ではベターな手法だと思っています。

これはドメインクラスをジェネリックなクラスに出来るが故にとれた手法ですが、
そういった事ができるようになったのは実は私の要望だったりします。

* `ドメインクラスで型パラメータをサポート - taediumの日記 <http://d.hatena.ne.jp/taedium/20130811/p1>`_

あのときはこんなことに使えるとは露程も思っていませんでした(・ω<) ﾃﾍﾍﾟﾛ

Doma 2良いよ！

.. author:: default
.. categories:: none
.. tags:: Java, Doma
.. comments::
