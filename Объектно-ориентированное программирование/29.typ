= Порождающие паттерны: одиночка (Singleton), прототип (Prototype), пул объектов (Object Pool). Их преимущества и недостатки.

== Порождающие паттерны

Все порождающие паттерны имеют одну основную цель~--- модификация программы без изменения уже написанного кода. Вместо явного создания объектов для полиморфных классов выделяются роли/объекты, которые принимают решение, какой экземпляр создавать, и порождают его, тем самым очищая код от конкретных типов. Такой перенос ответственности делает выбор типа централизованным и контролируемым.

== Одиночка (Singleton)

- Класс-одиночка запрещает создание своих экземпляров привычным способом (отсутствуют `public`-конструкторы), а вместо этого имеет статический член, который держит объект, что гарантирует один объект будет один для конкретного типа.
- Получение ссылки/указателя на этот объект осуществляется только через имя класса, то есть через статический метод.
- `Singleton` называют антипаттерном, потому что вызов через имя класса фактически даёт глобальный вызов.

=== Альтернатива

- Вместо одиночки можно создать креатора, который будет держать указатель на объект~--- современный подход склоняется к такому решению.
- Однако "это взламывается"~--- можно создать второй конкретный креатор и породить второй объект, то есть гарантия единственности нарушается при наличии нескольких конкретных создателей.
- Таким образом, реальная гарантия опирается на организационную дисциплину кода, а не на жёсткое свойство конструкции.

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Гарантирует наличие лишь единственного экземпляра конкретного типа за счёт статического члена, который держит объект.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Считается антипаттерном: доступ к объекту через имя класса фактически даёт глобальный доступ.
    - Теряется возможность контроля жизненного цикла объекта.
    - Тип создаваемого объекта определяется на этапе компиляции.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

class Product
{
  public:
    static shared_ptr<Product> instance()
    {
        class Proxy : public Product {};

        static std::shared_ptr<Product> myInstance = std::make_shared<Proxy>();

        return myInstance;
    }
    ~Product() {}

    void f() {}

    Product(const Product&) = delete;
    Product& operator=(const Product&) = delete;

  private:
    Product() {}
};

int main()
{
    shared_ptr<Product> ptr(Product::instance());

    ptr->f();
}
```

== Прототип (Prototype)

- Возлагаем ответственность за создание новых экземпляров на сам продукт, чтобы он мог создавать копию себя.
- В класс добавляется виртуальный метод `clone()`, который возвращает копию себя.
- Важно, чтобы `clone()` возвращал объект корректного типа.
- Проблема: если в наследуемом классе не реализовать свой метод `clone()`, вызовется базовый, и скопируется не тот, что нужен. Поэтому реализация `clone()` во всех производных классах обязательна.
- Для контроля правильности клонирования может использоваться идиома не виртуального интерфейса (non-virtual interface, NVI):
    - Создать не виртуальный `public`-метод, который внутри вызывает виртуальный `protected`-метод.
    - Тогда можно внутри базовой реализации контролировать процесс копирования, например, сверить тип объекта.

#image("attachments/prototype-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Позволяет создавать новые объекты на основе уже имеющихся без необходимости знать их точный класс.
    - Позволяет копировать сложные конфигурации объектов.
    - Упрощает создание копий (особенно когда процесс создания объекта сложен или ресурсоёмок).
    - Помогает реализовать повторное использование объектов без лишней зависимости от системы создания новых экземпляров.

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Необходимость корректно реализовывать метод `clone()` во всех наследуемых типах~--- если в каком-то классе забыть сделать свою реализацию, будет ошибка: скопируется не тот тип.
    - Проблемы могут возникать при копировании сложных объектов с нестандартными связями~--- нужно аккуратно реализовывать глубокое/поверхностное копирование и следить за корректностью работы метода `clone()`.
]

=== Пример

```cpp
#include <exception>
#include <iostream>
#include <memory>

using namespace std;

class BaseObject
{
  public:
    virtual ~BaseObject() = default;

    unique_ptr<BaseObject> clone();

  private:
    virtual unique_ptr<BaseObject> doClone() = 0;
};

class Object1 : public BaseObject
{
  public:
    Object1() {}
    Object1(const Object1& obj) {}
    ~Object1() override {}

  private:
    unique_ptr<BaseObject> doClone() override
    {
        return make_unique<Object1>(*this);
    }
};

class Object11 : public Object1
{
};

unique_ptr<BaseObject> BaseObject::clone()
{
    unique_ptr<BaseObject> objclone = doClone();

    if (typeid(*objclone) != typeid(*this)) {
        throw runtime_error("Error clone!");
    }

    return objclone;
}

class User
{
  public:
    void use(shared_ptr<BaseObject>& obj) { auto obj1 = obj->clone(); }
};

int main()
{
    try {
        shared_ptr<BaseObject> obj = make_shared<Object11>();
        User{}.use(obj);
    } catch (exception& err) {
        cout << err.what() << endl;
    }
}
```

== Пул объектов (Object Pool)

- Пул объектов~--- это структура, которая держит не один, а много заранее созданных экземпляров "тяжёлых" объектов, чтобы их не создавать заново при каждой надобности.
- Пул хранит набор объектов; по запросу возвращает один и помечает его как занятый, чтобы параллельно им никто другой не пользовался.
- После завершения работы объект явно "отдают" обратно в пул, и он переходит в состояние свободного (состояние должно изменяться именно пулом).
- Пул может быть фиксированного размера или расширяемым; на практике часто нужен именно фиксированный лимит ресурсов.

*Откуда берётся необходимость*\
Повторное создание тяжёлых объектов "каждый раз" долго и затратно, особенно если сопровождается выделением памяти и системными вызовами. Для одного объекта можно держать указатель в креаторе и не пересоздавать его, но если требуется несколько таких объектов, их следует держать сразу "несколько" и переиспользовать~--- это и решает пул.

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Снижает число повторных созданий "тяжёлых" объектов, экономит время и издержки на выделение памяти и системные вызовы.
    - Обеспечивает повторное использование уже созданных экземпляров в разных местах программы.
    - Позволяет явно ограничивать количество одновременно используемых ресурсов (фиксированный пул).
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Требуется явное управление состоянием объектов в пуле (занят/свободен).
    - При фиксированном размере, если "все номера заняты", новые запросы не получают объект~--- ресурс исчерпан до освобождения.
    - Если объект не очищается или его состояние не сбрасывается перед возвращением в пул, может возникнуть утечка информации. Например, если объект содержит конфиденциальные данные или ссылки на другие объекты, эта информация может остаться в объекте после его возврата в пул.
]

=== Пример

```cpp
#include <concepts>
#include <iostream>
#include <memory>
#include <vector>

using namespace std;

template <typename T>
concept PoolObject = requires(T t) { t.clear(); };

class Product
{
  private:
    static size_t count;

  public:
    Product() { ++count; }
    ~Product() { count--; }

    void clear() {}
};

size_t Product::count = 0;

template <PoolObject Type>
class Pool
{
  public:
    static shared_ptr<Pool<Type>> instance();

    shared_ptr<Type> getObject();
    bool releaseObject(shared_ptr<Type>& obj);
    size_t count() const { return pool.size(); }

    Pool(const Pool&) = delete;
    Pool& operator=(const Pool&) = delete;

  private:
    vector<pair<bool, shared_ptr<Type>>> pool;

    Pool() {}

    pair<bool, shared_ptr<Type>> create();
};

template <PoolObject Type>
shared_ptr<Pool<Type>> Pool<Type>::instance()
{
    static shared_ptr<Pool<Type>> myInstance(new Pool<Type>());

    return myInstance;
}

template <PoolObject Type>
shared_ptr<Type> Pool<Type>::getObject()
{
    size_t i = 0;
    while (i < pool.size() && pool[i].first) {
        ++i;
    }

    if (i < pool.size()) {
        pool[i].first = true;
    } else {
        pool.push_back(create());
    }

    return pool[i].second;
}

template <PoolObject Type>
bool Pool<Type>::releaseObject(shared_ptr<Type>& obj)
{
    size_t i = 0;
    for (pool[i].second != obj && i < pool.size()) {
        ++i;
    }

    if (i == pool.size()) {
        return false;
    }

    obj.reset();
    pool[i].first = false;
    pool[i].second->clear();

    return true;
}

template <PoolObject Type>
pair<bool, shared_ptr<Type>> Pool<Type>::create()
{
    return {true, make_shared<Type>()};
}

int main()
{
    shared_ptr<Pool<Product>> pool = Pool<Product>::instance();

    vector<shared_ptr<Product>> vec(4);

    for (auto& elem : vec) {
        elem = pool->getObject();
    }

    pool->releaseObject(vec[1]);
}
```
