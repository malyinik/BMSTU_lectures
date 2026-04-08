= Ограничения накладываемые на шаблоны. Требования к шаблонам (requires). Концепты. Типы ограничений. Варианты определения шаблонов функций и классов с концептами.

== Ограничения накладываемые на шаблоны

/ Ограничение: это логическое условие на параметры шаблона.
  - Если условие истинно, шаблон участвует в перегрузке.
  - Если ложно, этот шаблон просто не считается подходящим (без "жёсткой" ошибки), пока есть другие кандидаты.

С приходом C++20 появилась возможность явно задавать ограничения на параметры шаблона. Это позволяет:
- Проверять требования к типу до компиляции тела шаблона.
- Выдавать более осмысленные сообщения об ошибках.
- Улучшать читаемость и поддержку кода.

Выражения внутри `requires`-выражения проверяются "безболезненно": если что-то не подходит, это превращается в "ограничение не выполнено", а не в лавину ошибок подстановки.

== Требования к шаблонам (`requires`)

Механизм `requires` в C++20 позволяет:
- Ограничить применимость шаблона только к тем типам, которые удовлетворяют определённым условиям.
- Использовать предикаты (выражения, вычисляемые во время компиляции) для уточнения допустимости типа.

=== Синтаксис `requires`

```cpp
// После списка параметров шаблона
template<typename T>
  requires std::integral<T>
T inc(T x)
{
    return x + 1;
}

// Или после заголовка функции (у классов только первый способ)
template<typename T>
T inc(T x) requires std::integral<T>
{
    return x + 1;
}
```

=== Что можно использовать в `requires`?

// - Константные выражения
// - `type_traits` и стандартные концепты (`std::same_as`, `std::convertible_to`, `std::is_integral_v<T>`)
// - Концепты собственного определения
// - Вложенные `requires`

После `requires` указывается одно *булево выражение*.

// ```cpp
// template<typename T>
// requires ( // принимает ЕДИНЫЙ булев предикат
//     std::copy_constructible<T> &&
//     requires (T a, T b) { // а тут может быть 4 типа требований
//         a + b;
//     }
// )
// class S {};
// ```
//
==== Имена концептов (concept-id)

```cpp
requires std::integral<T>;
requires std::same_as<U, V>;
requires std::derived_from<T, Base>;
```

==== Булевы константные выражения, зависящие от параметров

```cpp
requires (sizeof(T) <= 8);
requires std::is_trivially_copyable_v<T>;
requires noexcept(std::declval<T&>() = std::declval<const T&>());
```

==== Логические связки и скобки

```cpp
requires (std::integral<T> && (sizeof(T) >= 2)) || std::floating_point<T>;
requires (!std::copy_constructible<T>);
```

==== requires-выражение как единый операнд

```cpp
requires (requires (T a, T b) { a + b; });
```

=== Преимущества `requires`

- Проверка происходит до компиляции тела шаблона.
- Компилятор выдаёт краткие и понятные сообщения об ошибках.

=== Важная особенность

#rect(stroke: (left: red + 1.5pt), fill: red.lighten(80%))[
  `requires`~--- это ограничение, но не гарантия. Даже если тип прошёл проверку в `requires`, это не значит, что шаблон с ним обязательно скомпилируется. Ошибки всё ещё могут возникать при глубокой инстанциации (например, в теле функции).
]

== Концепты

/ Концепт: это именованное булево выражение времени компиляции о типах/значениях.

Введён в C++20, он:
- Определяет условия, которым должен соответствовать тип.
- Используется для ограничения параметров шаблона.

=== Синтаксис

```cpp
template <typename T>
concept ConceptName = <логическое или requires-выражение>;
```

==== Пример

```cpp
#include <concepts>
#include <type_traits>

template<typename T>
concept SmallSignedInt =
    std::signed_integral<T> && (sizeof(T) <= 4);

template <typename T>
concept Incrementable = requires(T t)
{
    {++t} -> same_as<T&>;
    {t++} -> same_as<T>;
}
```

=== Зачем нужны концепты?

- Позволяют повторно использовать ограничения (не писать `requires` каждый раз).
- Делают код самодокументируемым: `template <Sortable T>` читается гораздо понятнее, чем `requires ...`.

=== Концепты из стандартной библиотеки

#align(center, table(
  columns: (auto, auto),
  table.header([*Концепт*], [*Что проверяет*]),
  [`std::same_as<T, U>`], [Типы `T` и `U` идентичны],
  [`std::integral<T>`], [Тип `T` --- целочисленный],
  [`std::floating_point<T>`], [Тип --- с плавающей точкой],
  [`std::convertible_to<T, U>`], [`T` можно привести к `U`],
  [`std::derived_from<T, U>`], [`T` является производным от `U`],
  [`std::invocable<F, Args...>`], [`F(args...)` допустим],
))

== Типы ограничений (`requires`-выражений)

Ограничения в шаблонах делятся на разные типы в зависимости от того, что именно мы проверяем.

=== Простые выражения

Проверяется, допустимо ли выражение.

```cpp
requires(T a, T b) {
    a + b; // просто «существует оператор +»
};
```
=== Составные выражения

Проверяется тип результата выражения.

```cpp
requires(std::ostream& os, T t) {
    { os << t } -> std::same_as<std::ostream&>;  // тип результата
    { t.swap(t) } noexcept; // не бросает исключений
};
```

=== Требование к типу

Проверяется наличие вложенных типов.

```cpp
requires(T t) {
    typename T::value_type; // у T должен быть вложенный тип value_type
};
```

=== Вложенные `requires`

Всё выше перечисленное может быть объединено:

```cpp
// Как в функциях, имя параметра можно опустить, если оно не используется
requires(T)
{
    requires std::copy_constructible<T>; // любое constraint-выражение
    requires (sizeof(T) <= 64);
};
```

Комбинировать их можно свободно; итог~--- единое булево условие.

#rect(
  fill: gray.lighten(70%),
  stroke: gray,
  radius: 5pt,
  width: 100%,
)[*`constraint`-выражение*~--- это логическое условие, накладываемое на параметры шаблона.]


== Варианты определения шаблонов функций и классов с концептами

=== Функции

```cpp
// 1) Концепт в параметре шаблона
template<std::integral T>
T inc(T x) { return x + 1; }

// 2) requires (prefix или trailing)
template<typename T>
  requires std::integral<T>
T dec(T x) { return x - 1; }

template<typename T>
T mul(T a, T b) requires std::integral<T>
{
    return a * b;
}

// 3) «Сокращённая» форма с auto
auto add(std::integral auto a, std::integral auto b) { return a + b; }
```

=== Классы

```cpp
// 1) Через концепт в списке параметров
template<std::regular T>
class Box { /*...*/ };

// 2) Через requires после параметров
template<typename T>
  requires std::regular<T>
class Box { /*...*/ };
```

- Для класса "trailing requires" не бывает~--- только после параметров шаблона.

=== Ограничения членов класса

```cpp
template<typename T>
class Box
{
  public:
    // Метод
    void put(const T& v) requires std::copyable<T> { /*...*/ }

    // Конструктор
    Box(const T& v) requires std::movable<T> { /*...*/ }

    // Оператор преобразования
    template<class U>
      requires std::convertible_to<T, U>
    explicit operator U() const { return static_cast<U>(/*...*/); }

    // Статический метод
    template<class U>
    static void log(const U&) requires std::ostreamable<U> { /*...*/ }
};
```

=== Пример: концепт с несколькими параметрами

Концепт принимает два типа:

```cpp
template <typename T, typename U>
concept PairAddable = requires(T a, U b)
{
    { a + b } -> std::same_as<T>;
};
```

- Тогда использовать его напрямую как `template <PairAddable T>` невозможно, потому что непонятно, чем заполнить `U` --- компилятор подставит только первый аргумент (`T`), а `U` окажется неопределённым.
- Но можно явно указать второй параметр при использовании концепта:
  ```cpp
  template<class T>
  requires PairAddable<T, int>
  void f(T);
  ```
