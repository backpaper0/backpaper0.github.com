Streamのメソッドを操作の種類別で一覧にした
=============================================

``Stream`` の操作は **中間操作** と **終端操作** がありますが、
各メソッドがどちらの操作にあたるのか一覧にしてみました。

.. note::

   中間操作と終端操作の詳細は
   `ストリーム操作とパイプライン <http://docs.oracle.com/javase/jp/8/api/java/util/stream/package-summary.html#StreamOps>`_
   を参照してください。

ちなみに一覧中の ``T`` は ``Stream`` が取る型変数です。
例えば ``String[]`` をストリーム化した場合 ``T`` は ``String`` になります。

それから ``S`` は ``BaseStream`` が取る型変数で ``Stream<T>`` を指します。



中間操作
------------------------------

* `Stream<T> filter(Predicate<? super T> predicate)`_

* `<R> Stream<R> map(Function<? super T, ? extends R> mapper)`_
* `IntStream mapToInt(ToIntFunction<? super T> mapper)`_
* `LongStream mapToLong(ToLongFunction<? super T> mapper)`_
* `DoubleStream mapToDouble(ToDoubleFunction<? super T> mapper)`_

* `<R> Stream<R> flatMap(Function<? super T, ? extends Stream<? extends R>> mapper)`_
* `IntStream flatMapToInt(Function<? super T, ? extends IntStream> mapper)`_
* `LongStream flatMapToLong(Function<? super T, ? extends LongStream> mapper)`_
* `DoubleStream flatMapToDouble(Function<? super T, ? extends DoubleStream> mapper)`_

* `Stream<T> peek(Consumer<? super T> action)`_

* `S sequential()`_
* `S parallel()`_
* `S unordered()`_
* `S onClose(Runnable closeHandler)`_

ステートフルな中間操作
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* `Stream<T> distinct()`_
* `Stream<T> sorted()`_
* `Stream<T> sorted(Comparator<? super T> comparator)`_



ステートフルな短絡中間操作
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* `Stream<T> limit(long maxSize)`_
* `Stream<T> skip(long n)`_



終端操作
------------------------------

* `void forEach(Consumer<? super T> action)`_
* `void forEachOrdered(Consumer<? super T> action)`_

* `Object [] toArray()`_
* `<A> A[] toArray(IntFunction<A[]> generator)`_

* `T reduce(T identity, BinaryOperator<T> accumulator)`_
* `Optional<T> reduce(BinaryOperator<T> accumulator)`_
* `<U> U reduce(U identity, BiFunction<U, ? super T, U> accumulator, BinaryOperator<U> combiner)`_

* `<R> R collect(Supplier<R> supplier, BiConsumer<R, ? super T> accumulator, BiConsumer<R, R> combiner)`_
* `<R, A> R collect(Collector<? super T, A, R> collector)`_

* `Optional<T> min(Comparator<? super T> comparator)`_
* `Optional<T> max(Comparator<? super T> comparator)`_
* `long count()`_

* `Iterator<T> iterator()`_
* `Spliterator<T> spliterator()`_



短絡終端操作
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* `boolean anyMatch(Predicate<? super T> predicate)`_
* `boolean allMatch(Predicate<? super T> predicate)`_
* `boolean noneMatch(Predicate<? super T> predicate)`_

* `Optional<T> findFirst()`_
* `Optional<T> findAny()`_



その他(中間操作・終端操作のどちらにも分類されないもの)
------------------------------------------------------------

* `boolean isParallel()`_
* `void close()`_



.. _<A> A[] toArray(IntFunction<A[]> generator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#toArray-java.util.function.IntFunction-
.. _<R, A> R collect(Collector<? super T, A, R> collector): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#collect-java.util.stream.Collector-
.. _<R> R collect(Supplier<R> supplier, BiConsumer<R, ? super T> accumulator, BiConsumer<R, R> combiner): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#collect-java.util.function.Supplier-java.util.function.BiConsumer-java.util.function.BiConsumer-
.. _<R> Stream<R> flatMap(Function<? super T, ? extends Stream<? extends R>> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#flatMap-java.util.function.Function-
.. _<R> Stream<R> map(Function<? super T, ? extends R> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#map-java.util.function.Function-
.. _<U> U reduce(U identity, BiFunction<U, ? super T, U> accumulator, BinaryOperator<U> combiner): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#reduce-U-java.util.function.BiFunction-java.util.function.BinaryOperator-
.. _BaseStream<T, S extends BaseStream<T, S>>: http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html
.. _boolean allMatch(Predicate<? super T> predicate): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#allMatch-java.util.function.Predicate-
.. _boolean anyMatch(Predicate<? super T> predicate): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#anyMatch-java.util.function.Predicate-
.. _boolean isParallel(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#isParallel--
.. _boolean noneMatch(Predicate<? super T> predicate): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#noneMatch-java.util.function.Predicate-
.. _DoubleStream flatMapToDouble(Function<? super T, ? extends DoubleStream> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#flatMapToDouble-java.util.function.Function-
.. _DoubleStream mapToDouble(ToDoubleFunction<? super T> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#mapToDouble-java.util.function.ToDoubleFunction-
.. _IntStream flatMapToInt(Function<? super T, ? extends IntStream> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#flatMapToInt-java.util.function.Function-
.. _IntStream mapToInt(ToIntFunction<? super T> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#mapToInt-java.util.function.ToIntFunction-
.. _Iterator<T> iterator(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#iterator--
.. _long count(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#count--
.. _LongStream flatMapToLong(Function<? super T, ? extends LongStream> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#flatMapToLong-java.util.function.Function-
.. _LongStream mapToLong(ToLongFunction<? super T> mapper): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#mapToLong-java.util.function.ToLongFunction-
.. _Object [] toArray(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#toArray--
.. _Optional<T> findAny(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#findAny--
.. _Optional<T> findFirst(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#findFirst--
.. _Optional<T> max(Comparator<? super T> comparator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#max-java.util.Comparator-
.. _Optional<T> min(Comparator<? super T> comparator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#min-java.util.Comparator-
.. _Optional<T> reduce(BinaryOperator<T> accumulator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#reduce-java.util.function.BinaryOperator-
.. _S onClose(Runnable closeHandler): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#onClose-java.lang.Runnable-
.. _S parallel(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#parallel--
.. _S sequential(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#sequential--
.. _S unordered(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#unordered--
.. _Spliterator<T> spliterator(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#spliterator--
.. _Stream<T> distinct(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#distinct--
.. _Stream<T> filter(Predicate<? super T> predicate): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#filter-java.util.function.Predicate-
.. _Stream<T> limit(long maxSize): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#limit-long-
.. _Stream<T> peek(Consumer<? super T> action): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#peek-java.util.function.Consumer-
.. _Stream<T> skip(long n): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#skip-long-
.. _Stream<T> sorted(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#sorted--
.. _Stream<T> sorted(Comparator<? super T> comparator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#sorted-java.util.Comparator-
.. _Stream<T>: http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html
.. _T reduce(T identity, BinaryOperator<T> accumulator): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#reduce-T-java.util.function.BinaryOperator-
.. _void close(): http://docs.oracle.com/javase/jp/8/api/java/util/stream/BaseStream.html#close--
.. _void forEach(Consumer<? super T> action): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#forEach-java.util.function.Consumer-
.. _void forEachOrdered(Consumer<? super T> action): http://docs.oracle.com/javase/jp/8/api/java/util/stream/Stream.html#forEachOrdered-java.util.function.Consumer-



.. author:: default
.. categories:: none
.. tags:: Java, Stream API
.. comments::
