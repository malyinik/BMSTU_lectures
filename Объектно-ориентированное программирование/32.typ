= Паттерны поведения: посетитель (Visitor), опекун (Memento), шаблонный метод (Template Method), хранитель (Holder), итератор (Iterator), свойство (Property). Их преимущества и недостатки

== Паттерны поведения

- Это подход, где мы выносим изменяемые части поведения (реализации алгоритмов/методов) из сущности в отдельные сущности и подставляем их при работе.
- Формулировка через сравнение: "вырожденный мост"~--- это паттерн поведения; если мост отделяет сущность от реализации "в целом", то в поведенческом подходе отделяется реализация одного конкретного метода (алгоритма).

== Посетитель (Visitor)

=== Идея и цель

- Избавиться от привязки к конкретной реализации и не плодить множество иерархий стратегий для каждой сущности.
- Объединить стратегии для разных сущностей (модель, камера, источник света и т. п.) в одну иерархию посетителей.

=== Как устроен (по словам лектора)

- У посетителя определяются методы, перегруженные по конкретным типам объектов.
- Сущность должна иметь указатель на посетителя; вводится простой метод `accept`, который принимает посетителя и инициирует вызов нужного метода у него.

#image("attachments/visitor-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Объединяет кучу иерархий стратегий в одну иерархию визитёров, уменьшая разрастание классов.
    - Помогает избавиться от реализации в том смысле, что операции над разными сущностями сводятся к единому интерфейсу посетителя и выбираются по конкретному типу аргумента (перегрузка).
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - При развитии иерархии и появлении новых сущностей нужно модифицировать всех посетителей~--- это плохо.
    - Метод должен иметь доступ к реализации~--- дружба: необходимость `friend`-связей~--- "не очень", но используется ради упрощения иерархии.
]

=== Пример

```cpp
#include <iostream>
#include <memory>
#include <vector>

using namespace std;

class Circle;
class Rectangle;

class Visitor
{
  public:
    virtual ~Visitor() = default;

    virtual void visit(Circle& ref) = 0;
    virtual void visit(Rectangle& ref) = 0;
};

class Shape
{
  public:
    virtual ~Shape() = default;

    virtual void accept(shared_ptr<Visitor> visitor) = 0;
};

class Circle : public Shape
{
  public:
    void accept(shared_ptr<Visitor> visitor) override { visitor->visit(*this); }
};

class Rectangle : public Shape
{
  public:
    void accept(shared_ptr<Visitor> visitor) override { visitor->visit(*this); }
};

class ConVisitor : public Visitor
{
  public:
    void visit(Circle& ref) override { cout << "Circle;\n"; }
    void visit(Rectangle& ref) override { cout << "Rectangle;\n"; }
};

class Figure : public Shape
{
    using Shapes = vector<shared_ptr<Shape>>;

  private:
    Shapes shapes;

  public:
    Figure(initializer_list<shared_ptr<Shape>> list)
    {
        for (auto&& elem : list) {
            shapes.emplace_back(elem);
        }
    }

    void accept(shared_ptr<Visitor> visitor) override
    {
        for (auto& elem : shapes) {
            elem->accept(visitor);
        }
    }
};

int main()
{
    shared_ptr<Shape> figure = make_shared<Figure>(
        initializer_list<shared_ptr<Shape>>({
            make_shared<Circle>(),
            make_shared<Rectangle>(),
            make_shared<Circle>()
            }));

    shared_ptr<Visitor> visitor = make_shared<ConVisitor>();

    figure->accept(visitor);
}
```

== Опекун (Memento)

- Очень часто в задачах, особенно в программах, нужно выполнять действия и иметь возможность вернуться в предыдущее состояние.
- Задача: реализовать механизм отката к предыдущим состояниям объекта.
- Реализация не должна возлагать обязанность хранения предыдущих состояний на сам изменяемый объект, потому что на любой объект должна быть возложена только одна обязанность. Поэтому создаётся отдельный объект, который хранит состояния другого объекта~--- это и есть паттерн "Опекун" (Memento).
- Опекун (англ. Memento~--- снимок/кадр): объект, который может сохранить внутреннее состояние другого объекта, чтобы восстановить его позже.

=== Идея

- Внутренние данные объекта, которые определяют его состояние, оборачиваются в отдельный объект~--- "снимок" (`memento`). Этот снимок возвращается по запросу и используется для восстановления состояния.
- В дополнение к основному интерфейсу объекта добавляется метод(-ы) для возврата и восстановления состояния на основе снимка.

=== Как устроена архитектура

- Есть основной объект, в котором помимо стандартного интерфейса появляется возможность возвращать “снимок состояния”.
- Опекун отвечает за хранение снимков состояний. Он хранит коллекцию снимков (часто реализуется как контейнер, например стек).
- Снимков может быть сколько угодно, они могут быть полными или частичными, и логика их хранения (сколько, как долго, какие именно) определяется отдельно. Например, можно ограничивать хранение по времени, по количеству, хранить только опорные снимки, а остальные восстанавливать на лету.
- Управляет процессом отката отдельный управляющий компонент, который обращается к опекуну за нужным снимком. Таким образом, ни основной объект, ни опекун не управляют самим процессом возврата; опекун просто хранит снимки и возвращает их по запросу, а управление внешнее.
- Для хранения снимков может использоваться контейнер (например, стек). Опекун должен реализовывать внутреннюю (часто абстрактную) логику хранения снимков, от которой можно наследоваться для расширенного функционала (например, ограничение числа снимков, фильтрация одинаковых снимков, хранение только опорных, и т.п.).

#image("attachments/memento-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Позволяет откатываться к предыдущим состояниям объектов без изменения самого объекта.
    - Разделяет ответственность: объект занимается своим состоянием, а хранение вынесено отдельно.
    - Гибкая структура хранения: можно реализовывать различные логики хранения состояния.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Может быть тяжёлым по памяти, если хранить множество или полные снимки (особенно для "тяжёлых" объектов).
    - Реализация сложной логики хранения (например, фильтрация одинаковых снимков, оптимизация числа снимков) требует дополнительной архитектурной работы.
    - Не подходит для объектов, содержащих внешние ресурсы или состояние, не представленное простыми полями (например, открытые дескрипторы файлов, соединения с БД).
    - Для сложных объектов может быть сложно корректно формализовать их состояние для снимка.
]

=== Пример

```cpp
#include <iostream>
#include <list>
#include <memory>

using namespace std;

class Memento;

class Caretaker
{
  public:
    unique_ptr<Memento> getMemento();
    void setMemento(unique_ptr<Memento> memento);

  private:
    list<unique_ptr<Memento>> mementos;
};

class Originator
{
  public:
    Originator(int s) : state(s) {}

    const int getState() const { return state; }
    void setState(int s) { state = s; }

    std::unique_ptr<Memento> createMemento() { return make_unique<Memento>(*this); }
    void restoreMemento(std::unique_ptr<Memento> memento);

  private:
    int state;
};

class Memento
{
    friend class Originator;

  public:
    Memento(Originator o) : originator(o) {}

  private:
    void setOriginator(Originator o) { originator = o; }
    Originator getOriginator() { return originator; }

  private:
    Originator originator;
};

void Caretaker::setMemento(unique_ptr<Memento> memento)
{
    mementos.push_back(move(memento));
}

unique_ptr<Memento> Caretaker::getMemento()
{
    unique_ptr<Memento> last = move(mementos.back());
    mementos.pop_back();
    return last;
}

void Originator::restoreMemento(std::unique_ptr<Memento> memento)
{
    *this = memento->getOriginator();
}

int main()
{
    auto originator = make_unique<Originator>(1);
    auto caretaker = make_unique<Caretaker>();

    cout << "State = " << originator->getState() << endl;
    caretaker->setMemento(originator->createMemento());

    originator->setState(2);
    cout << "State = " << originator->getState() << endl;
    caretaker->setMemento(originator->createMemento());
    originator->setState(3);
    cout << "State = " << originator->getState() << endl;
    caretaker->setMemento(originator->createMemento());

    originator->restoreMemento(caretaker->getMemento());
    cout << "State = " << originator->getState() << endl;
    originator->restoreMemento(caretaker->getMemento());
    cout << "State = " << originator->getState() << endl;
    originator->restoreMemento(caretaker->getMemento());
    cout << "State = " << originator->getState() << endl;
}
```
== Шаблонный метод (Template Method)

Шаблонный метод~--- это класс, который решает задачу, разбивая её на последовательные этапы с чёткими входами и выходами, и позволяет наблюдать и анализировать результат каждого этапа.

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Гибкость за счёт вынесения реализаций этапов в стратегии; «каждый этап — своя стратегия».
    - Простые структурные варианты: один класс со стратегиями или иерархия с подменой.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Внесение изменений в общую структуру алгоритма может потребовать соответствующих изменений во всех подклассах.
    - При значительном увеличении числа этапов алгоритма класс может стать слишком сложным и трудным для поддержки и понимания
]

=== Пример

```cpp
#include <iostream>

using namespace std;

class AbstractClass
{
  public:
    void templateMethod()
    {
        primitiveOperation();
        concreteOperation();
        hook();
    }
    virtual ~AbstractClass() = default;

  protected:
    virtual void primitiveOperation() = 0;
    void concreteOperation() { cout << "concreteOperation;\n"; }
    virtual void hook() { cout << "hook Base;\n"; }
};

class ConClassA : public AbstractClass
{
  protected:
    void primitiveOperation() override { cout << "primitiveOperation A;\n"; }
};

class ConClassB : public AbstractClass
{
  protected:
    void primitiveOperation() override { cout << "primitiveOperation B;\n"; }
    void hook() override { cout << "hook B;\n"; }
};

int main()
{
    ConClassA ca;
    ConClassB cb;

    ca.templateMethod();
    cb.templateMethod();
}
```

== Хранитель (Holder)

Это концептуальный прототип умного указателя, разработанный для устранения проблем ручного управления памятью. Он реализует принцип RAII: объект `Holder<T>` хранит `T*`, а при разрушении сам вызывает `delete`.

=== Идея

- Указатель помещается в оболочку, которая:
    - располагается на стеке;
    - управляет временем жизни объекта;
    - при уничтожении удаляет объект.
- Интерфейс `Holder` --- максимально прозрачный, с перегрузкой `->`, `*`, `bool` и др.
- Обязательные компоненты:
    - запрет на копирование (нельзя допустить двойное удаление);
    - разрешение перемещения (`move`-семантика);
    - передача владения через методы `get()`, `release()`, `reset()`.
- `Holder`~--- концепция, которая ближе к `unique_ptr`.

=== Пример использования

```cpp
Holder<A> obj(new A{});
obj->f();  // безопасный вызов
```

Даже если `f()` выбросит исключение, `Holder` вызовет `delete` в своём деструкторе.


=== Пример

```cpp
template <typename T>
class Holder
{
    T* ptr = nullptr;
  public:
    explicit Holder(T* p = nullptr) noexcept : ptr(p) {}
    ~Holder() { delete ptr; }

    Holder(const Holder&) = delete;
    Holder& operator=(const Holder&) = delete;

    Holder(Holder&& other) noexcept :
        ptr(std::exchange(other.ptr, nullptr)) {}
    Holder& operator=(Holder&& other) noexcept
    {
        if (this != &other) {
            delete ptr;
            ptr = std::exchange(other.ptr, nullptr);
        }
        return *this;
    }

    T* get()        const noexcept { return ptr; }
    T& operator*()  const noexcept { return *ptr; }
    T* operator->() const noexcept { return ptr; }
    operator bool() const noexcept { return ptr != nullptr; }

    T* release() noexcept // отдать владение
    {
        return std::exchange(ptr, nullptr);
    }
    void reset(T* p = nullptr) noexcept
    {
        if (ptr != p) {
            delete ptr;
            ptr = p;
        }
    }
};
```

== Итератор (Iterator)

Итератор предоставляет способ последовательного доступа ко всем элементам составного объекта, не раскрывая его внутреннего представления.

=== Решаемые задачи

- Сохранение инкапсуляции объектов при переборе в структуре данных.
- Поддержка нескольких активных обходов одного и того же агрегированного (составленного из подобъектов) объекта.
- Предоставление единообразного интерфейса с целью обхода различных агрегированных структур (поддержка полиморфной итерации).

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Упрощение работы со структурами данных: обход элементов без знания об особенностях внутренней реализации структуры данных.
    - Возможность работать с различными типами структур данных независимо от их реализации.
    - Возможность реализовывать различные алгоритмы обработки структур данных.

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Добавление новых типов структур данных может потребовать изменения кода итератора.
]

=== Пример

```cpp
```

== Свойство (Property)

- В современных языках программирования появляется понятие "свойство", которое по существу объединяет методы `get` и `set`.
- Мы не должны давать прямой доступ к членам данных класса, однако работать с ними обычно требуется.
- Для этого реализуются методы, чтобы обезопасить целостность объекта, чтобы никто извне её не нарушил.
- Мы работаем как с членом, а реально вызываются методы, мы этого не видим.

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Удобство доступа: можно работать с данными, как с обычными членами класса, при этом реально под капотом вызываются методы (инкапсуляция, скрытие реализации).
    - Защищённость целостности данных: внешний код не может напрямую изменить данные, только через контролируемые "свойства".
    - Унификация работы с атрибутами: свойства реализуют как чтение, так и запись данных с возможностью добавления дополнительной логики.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Не во всех языках свойства реализованы как часть синтаксиса (например, в #box([C++]) это нужно делать вручную).
    - Вручную реализованные свойства сложнее и громоздче, чем встроенные средства языков.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

template <typename Owner, typename Type>
class Property
{
    using Getter = Type (Owner::*)() const;
    using Setter = void (Owner::*)(const Type&);

  private:
    Owner* owner;
    Getter methodGet;
    Setter methodSet;

  public:
    Property() = default;
    Property(Owner* const owr, Getter getmethod, Setter setmethod)
        : owner(owr), methodGet(getmethod), methodSet(setmethod)
    {
    }

    void init(Owner* const owr, Getter getmethod, Setter setmethod)
    {
        owner = owr;
        methodGet = getmethod;
        methodSet = setmethod;
    }

    operator Type() { return (owner->*methodGet)(); } // Getter
    void operator=(const Type& data) { (owner->*methodSet)(data); } // Setter

    //	Property(const Property&) = delete;
    //	Property& operator=(const Property&) = delete;
};

class Object
{
  private:
    double value;

  public:
    Object(double v) : value(v) { Value.init(this, &Object::getValue, &Object::setValue); }

    double getValue() const { return value; }
    void setValue(const double& v) { value = v; }

    Property<Object, double> Value;
};

int main()
{
    Object obj(5.);
    cout << "value = " << obj.Value << endl;

    obj.Value = 10.;
    cout << "value = " << obj.Value << endl;

    unique_ptr<Object> ptr = make_unique<Object>(15.);
    cout << "value =" << ptr->Value << endl;

    obj = *ptr;
    obj.Value = ptr->Value;
}
```
