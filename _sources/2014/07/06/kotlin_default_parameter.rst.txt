Kotlinのデフォルト引数を調べた
==================================

こっとりーん！(挨拶)

Kotlinはこんな感じでデフォルト引数が使えます。


.. sourcecode:: kotlin

   class Calc {
     fun add(x: Int = 1, y: Int = 2): Int = x + y
     fun add2() = add(8, 16)
     fun add3() = add(4)
     fun add4() = add()
   }

addの引数にデフォルト値を設定しているのでadd3やadd4で引数を省略できています。

で、これをjavapしました。

.. sourcecode:: none

     public final int add(int, int);
       descriptor: (II)I
       flags: ACC_PUBLIC, ACC_FINAL
       Code:
         stack=2, locals=3, args_size=3
            0: iload_1       
            1: iload_2       
            2: iadd          
            3: ireturn       
         LocalVariableTable:
           Start  Length  Slot  Name   Signature
               0       4     0  this   LCalc;
               0       4     1     x   I
               0       4     2     y   I
         LineNumberTable:
           line 2: 0
       RuntimeVisibleParameterAnnotations:
         parameter 0: 
           0: #22(#23=s#24)
         parameter 1: 
           0: #22(#23=s#25)
   
     public static int add$default(Calc, int, int, int);
       descriptor: (LCalc;III)I
       flags: ACC_PUBLIC, ACC_STATIC
       Code:
         stack=4, locals=4, args_size=4
            0: aload_0       
            1: iload_3       
            2: iconst_1      
            3: iand          
            4: ifeq          9
            7: iconst_1      
            8: istore_1      
            9: iload_1       
           10: iload_3       
           11: iconst_2      
           12: iand          
           13: ifeq          18
           16: iconst_2      
           17: istore_2      
           18: iload_2       
           19: invokevirtual #32                 // Method add:(II)I
           22: ireturn       
         LineNumberTable:
           line 2: 7
         StackMapTable: number_of_entries = 2
              frame_type = 73 /* same_locals_1_stack_item */
             stack = [ class Calc ]
              frame_type = 255 /* full_frame */
             offset_delta = 8
             locals = [ class Calc, int, int, int ]
             stack = [ class Calc, int ]
   
   
     public final int add2();
       descriptor: ()I
       flags: ACC_PUBLIC, ACC_FINAL
       Code:
         stack=3, locals=1, args_size=1
            0: aload_0       
            1: bipush        8
            3: bipush        16
            5: invokevirtual #32                 // Method add:(II)I
            8: ireturn       
         LocalVariableTable:
           Start  Length  Slot  Name   Signature
               0       9     0  this   LCalc;
         LineNumberTable:
           line 3: 0
   
     public final int add3();
       descriptor: ()I
       flags: ACC_PUBLIC, ACC_FINAL
       Code:
         stack=4, locals=1, args_size=1
            0: aload_0       
            1: iconst_4      
            2: iconst_0      
            3: iconst_2      
            4: invokestatic  #37                 // Method add$default:(LCalc;III)I
            7: ireturn       
         LocalVariableTable:
           Start  Length  Slot  Name   Signature
               0       8     0  this   LCalc;
         LineNumberTable:
           line 4: 0
   
     public final int add4();
       descriptor: ()I
       flags: ACC_PUBLIC, ACC_FINAL
       Code:
         stack=4, locals=1, args_size=1
            0: aload_0       
            1: iconst_0      
            2: iconst_0      
            3: iconst_3      
            4: invokestatic  #37                 // Method add$default:(LCalc;III)I
            7: ireturn       
         LocalVariableTable:
           Start  Length  Slot  Name   Signature
               0       8     0  this   LCalc;
         LineNumberTable:
           line 5: 0
   
     public Calc();
       descriptor: ()V
       flags: ACC_PUBLIC
       Code:
         stack=1, locals=1, args_size=1
            0: aload_0       
            1: invokespecial #41                 // Method java/lang/Object."<init>":()V
            4: return        
         LocalVariableTable:
           Start  Length  Slot  Name   Signature
               0       5     0  this   LCalc;

コンスタントプールやコンストラクタは省略しました。

注目すべきはadd$default(Calc, int, int, int)というstaticメソッドですね。
第2,3引数はaddメソッドの第1,2引数に対応しています。

そして第4引数がデフォルト値が必要かどうかを判断するためのビット演算を利用したフラグです。
判断の方法ですが、例えば第4引数と1との論理積が0の場合は第1引数にデフォルト値を、第4引数と2との論理積が0の場合は第2引数にデフォルト値を使用する、といった具合です。
次に示す箇所がそれに当たります。

.. sourcecode:: none

            1: iload_3       
            2: iconst_1      
            3: iand          
            4: ifeq          9
            7: iconst_1      
            8: istore_1      
            9: iload_1       

intは32ビットなので33以上の引数にはどう対応してるのだろうと思って調べてみたところ第33引数では一周回って1との論理積で判断していました。
ということは第1引数に明示的に値を指定すると第33引数に何も指定していなくてもデフォルト値は使用されないということになりますね。
試してはいないですが。

javapの抜粋を掲載しますがインデックス416以降がそれに当たります。

.. sourcecode:: none

       390: iload         34
       392: ldc           #77                 // int 1073741824
       394: iand          
       395: ifeq          401
       398: iconst_1      
       399: istore        31
       401: iload         31
       403: iload         34
       405: ldc           #78                 // int -2147483648
       407: iand          
       408: ifeq          414
       411: iconst_1      
       412: istore        32
       414: iload         32
       416: iload         34
       418: iconst_1      
       419: iand          
       420: ifeq          426
       423: iconst_1      
       424: istore        33
       426: iload         33
       428: invokevirtual #80                 // Method x:(IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII)I
       431: ireturn       

ただしKotlinはまだM8なので改善されるかも知れませんね。
ていうか33も引数使うんじゃねえ、って話ですが。

そんなこんなでKotlinのデフォルト引数を調べてみました。
あとやっぱりjavapは楽しいです。

.. author:: default
.. categories:: none
.. tags:: Kotlin
.. comments::
