どうやってApplicationサブクラスの名前取ってきてんの？
================================================================================

これは `JavaFX Advent Calendar 2014 <http://www.adventar.org/calendars/380>`_ の7日目です。

小ネタです。

JavaFXアプリケーションのメインクラスは次のように書きますよね。

.. sourcecode:: java

   import javafx.application.Application;
   import javafx.stage.Stage;
   
   public class Hoge extends Application {
   
       public static void main(String[] args) {
           launch(args);
       }
   
       @Override
       public void start(Stage primaryStage) throws Exception {
           //略
       }
   }

これを初めて見たとき、launchメソッドにApplicationサブクラスのインスタンスや
Classを渡してるわけでもないのにインスタンス化されてstartメソッドが呼ばれるのが
キモいなー、と思ったのでした。

で、だいたい予想はつきましたが、Application.javaを読んでみました。
その部分を引用します。

  .. sourcecode:: java
  
     // Figure out the right class to call
     StackTraceElement[] cause = Thread.currentThread().getStackTrace();
  
     boolean foundThisMethod = false;
     String callingClassName = null;
     for (StackTraceElement se : cause) {
         // Skip entries until we get to the entry for this class
         String className = se.getClassName();
         String methodName = se.getMethodName();
         if (foundThisMethod) {
             callingClassName = className;
             break;
         } else if (Application.class.getName().equals(className)
                 && "launch".equals(methodName)) {
  
             foundThisMethod = true;
         }
     }

という感じで、スタックトレースを取得して現在のメソッド(launch)のひとつ前の
メソッド名(main)とクラス名(Hoge)を取得していました。

予想通り割とキモい方法でクラス名を取ってきていたことが分かって満足です。

JavaFXである必要性の薄い内容でしたが、以上になります。
おそまつさまでした。

.. author:: default
.. categories:: none
.. tags:: Java, JavaFX
.. comments::
