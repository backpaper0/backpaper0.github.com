私のBeanValidationの使い方(Java EE Advent Calendar 2013)
==========================================================

このエントリは `Java EE Advent Calendar 2013 <http://www.adventar.org/calendars/152>`_ の3日目です。
昨日は `@matsumana <https://twitter.com/matsumana>`_ さんのご担当で `JAX-RS + mustache - @matsumana の技術メモ <http://matsumana.info/blog/2013/12/02/jax-rs-mustache/>`_ でした。

今回はBeanValidationの自分なりの使い方をご紹介します。

その前に
--------------

BeanValidationてなんや？という方は `JSR 349 <http://jcp.org/en/jsr/detail?id=349>`_ の仕様を読むと良いでしょう。
200ページ超えてますが半分以上コードっぽいのでそんなにしんどくないんじゃないかと思わなくもないけどどうでしょうか？

もしくは「BeanValidation しんさん」でググると良いですよ。

本題
----------------------------------

BeanValidationではフィールドやgetterに@NotNullとか@Sizeとかアノテーションをモリモリ付けてバリデーションするわけですが、調子に乗ってるとすぐアノテーション地獄になってキツいのです。
ですので特定のバリデーションを集約する方法が欲しいわけでして、正攻法は独自のアノテーションを導入してそこに集約することだと思いますが、私は別のやり方を採用しています。

まず、正攻法と同じく独自のアノテーションとConstraintValidatorを導入します。
アノテーションはこんな感じ。

.. code-block:: java


   package net.hogedriven.backpaper0.javaeeadventcalendar2013;
   
   import static java.lang.annotation.ElementType.*;
   import static java.lang.annotation.RetentionPolicy.*;
   
   import java.lang.annotation.Documented;
   import java.lang.annotation.Retention;
   import java.lang.annotation.RetentionPolicy;
   import java.lang.annotation.Target;
   
   import javax.validation.Constraint;
   import javax.validation.Payload;
   
   @Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
   @Retention(RetentionPolicy.RUNTIME)
   @Documented
   @Constraint(validatedBy = { DomainValidator.class })
   public @interface DomainType {
   
       String message() default "";
   
       Class<?>[] groups() default {};
   
       Class<? extends Payload>[] payload() default {};
   
       @Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
       @Retention(RUNTIME)
       @Documented
       @interface List {
   
           DomainType[] value();
       }
   }

至って普通ですね。

続いてConstraintValidatorはこんな感じです。

.. code-block:: java

   package net.hogedriven.backpaper0.javaeeadventcalendar2013;
   
   import javax.validation.ConstraintValidator;
   import javax.validation.ConstraintValidatorContext;
   
   public class DomainValidator implements
           ConstraintValidator<DomainType, WithValidation> {
   
       @Override
       public void initialize(DomainType constraintAnnotation) {
       }
   
       @Override
       public boolean isValid(WithValidation value,
               ConstraintValidatorContext context) {
   
           if (value == null) {
               return true;
           }
   
           String message = value.validate();
           if (message == null) {
               return true;
           }
   
           context.disableDefaultConstraintViolation();
           context.buildConstraintViolationWithTemplate(message)
                   .addConstraintViolation();
   
           return false;
       }
   }

isValidメソッドでは具体的なバリデーションは行わずWithValidation#validateに任せています。

WithValidation実装クラスは例えばこんな感じ。

.. code-block:: java

   package net.hogedriven.backpaper0.javaeeadventcalendar2013;
   
   public class UserId implements WithValidation {
   
       private final String value;
   
       public UserId(String value) {
           this.value = value;
       }
   
       public String getValue() {
           return value;
       }
   
       @Override
       public String validate() {
   
           if (value.length() > 10) {
               return "10文字以下でｵﾅｼｬｽ";
           }
   
           for (char c : value.toCharArray()) {
               if (('a' <= c && c <= 'z') == false
                       && ('A' <= c && c <= 'Z') == false
                       && ('0' <= c && c <= '9') == false) {
                   return "アルファベットと数字でよろろ";
               }
           }
   
           return null;
       }
   
       public static UserId fromString(String value) {
           if (value == null || value.isEmpty()) {
               return null;
           }
           return new UserId(value);
       }
   }

validateメソッド内で詳しく値をチェックしてエラーがなければnullを、エラーがあったらエラーメッセージを返しています。

ConstraintValidatorのisValidメソッドではこのvalidateメソッドでエラーが返ってきたらそれをもとにConstraintViolationを組み立てます。

なぜこの方法を取るのか
------------------------------

私の大好きな `JAX-RS <http://jcp.org/en/jsr/detail?id=339>`_ ではリクエストパラメータやフォームパラメータを独自のクラスで受け取ることが出来ます。
で、jersey-mvc使って画面もモリモリ書いてるのでそれなりのメッセージが返るバリデーションをしたいのです。
しかもものぐさなので出来るだけ楽したいなー、と考えたり考えなかったりしながら色々試して今ここ、といった感じです。
それにしてもJAX-RSいいよJAX-RS。

ちなみにDomainTypeという名前にしているのはDDD由来ではなくて私の大好きな `Doma <http://doma.seasar.org/>`_ というフレームワークの機能であるドメインクラスに対してバリデーションを付けることが多いのでそういう名前にしています。
いやホントDomaいいよDoma。

メリット＆デメリット
------------------------

この方法をとるとアノテーションは@DomainTypeを付けるだけで良いのでどのアノテーションを使えば良いのか迷うこともないしアノテーション地獄が少しマシになります。

デメリットもあって、これは自分でもイケてないと思いまくっているのですが、WithValidation実装クラスがバリデーションするために不正な状態を許している、という点です。
本来ならfromStringファクトリメソッドでバリデーションしておかしな値だったら例外投げるのが正道と思います。
まあメリットとデメリットを秤にかけて現状はこの方法を取っとくのがベターやな、といった所です。

おまけ：相関バリデーション
--------------------------------

……というのかどうかは知りませんが「開始時刻」と「終了時刻」の前後関係が正しいか？みたいなふたつ以上の値を用いたバリデーションをする方法です。
簡単です。

BeanValidationはフィールドかgetterにアノテーションを付けてバリデーションを行うので一見相関バリデーションは行えない気がします。
が、例えば、ふたつの値をまとめるTupleというクラスを作ってそれに対してバリデーションするConstraintValidatorを作ればおkです。

試しにふたつの値が同じか検証するやつを書いてみました。

まずはTupleというクラスを導入。

.. code-block:: java

   package net.hogedriven.backpaper0.javaeeadventcalendar2013;

   public class Tuple {
   
       public final String first;
   
       public final String second;
   
       public Tuple(String first, String second) {
           this.first = first;
           this.second = second;
       }
   }

次にConstraintValidator。

.. code-block:: java

   package net.hogedriven.backpaper0.javaeeadventcalendar2013;
   
   import java.util.Objects;
   
   import javax.validation.ConstraintValidator;
   import javax.validation.ConstraintValidatorContext;
   
   public class EqualValidator implements ConstraintValidator<Equal, Tuple> {
   
       @Override
       public void initialize(Equal constraintAnnotation) {
       }
   
       @Override
       public boolean isValid(Tuple value, ConstraintValidatorContext context) {
   
           if (value == null) {
               return true;
           }
   
           return Objects.equals(value.first, value.second);
       }
   }

最後にアノテーション。

.. code-block:: java

   package net.hogedriven.backpaper0.javaeeadventcalendar2013;
   
   import static java.lang.annotation.ElementType.*;
   import static java.lang.annotation.RetentionPolicy.*;
   
   import java.lang.annotation.Documented;
   import java.lang.annotation.Retention;
   import java.lang.annotation.RetentionPolicy;
   import java.lang.annotation.Target;
   
   import javax.validation.Constraint;
   import javax.validation.Payload;
   
   @Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
   @Retention(RetentionPolicy.RUNTIME)
   @Documented
   @Constraint(validatedBy = { EqualValidator.class })
   public @interface Equal {
   
       String message() default "";
   
       Class<?>[] groups() default {};
   
       Class<? extends Payload>[] payload() default {};
   
       @Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
       @Retention(RUNTIME)
       @Documented
       @interface List {
   
           Equal[] value();
       }
   }

特別なことはなにもないコードですね。

使い方は次のような感じです。

.. code-block:: java

   private String first;

   private String second;

   @Equal(message = "違う値はアカン")
   public Tuple getValue() {
       return new Tuple(first, second);
   }

また、相関バリデーションはひとつひとつの値がvalid前提であることが多いでしょうからgroupsを上手く使ってアレしてあげれば良いですね。

というわけで
------------------

自分なりのBeanValidationの使い方でした。

* `本日のコード <https://github.com/backpaper0/javaee-advent-calendar>`_

Java EE Advent Calendar 2013、明日のご担当は `@kazuhira_r <https://twitter.com/kazuhira_r>`_ さんです。

.. author:: default
.. categories:: none
.. tags:: Java, BeanValidation
.. comments::
