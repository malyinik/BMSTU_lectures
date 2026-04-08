= Порождающие паттерны: фабричный метод (Factory Method), абстрактная фабрика (Abstract Factory), строитель (Builder). Их преимущества и недостатки.

== Порождающие паттерны

Все порождающие паттерны имеют одну основную цель~--- модификация программы без изменения уже написанного кода. Вместо явного создания объектов для полиморфных классов выделяются роли/объекты, которые принимают решение, какой экземпляр создавать, и порождают его, тем самым очищая код от конкретных типов. Такой перенос ответственности делает выбор типа централизованным и контролируемым.

== Фабричный метод (Factory Method)

- Фабричный метод~--- это порождающий паттерн, который инкапсулирует создание объектов~--- вместо прямого вызова конструктора в коде используется метод. Клиент работает с интерфейсом продукта и не знает (и не должен знать) конкретного класса, создаваемого фабричным методом.
- Основная идея: избавить прикладной код от явного создания конкретных объектов полиморфных классов. Класс, называемый фабрикой или креатором, принимает решение, какой конструктор вызывать и какой экземпляр вернуть.
\
- При работе с полиморфизмом не следует явно в коде создавать объекты производных классов~--- это неудобно для модификации кода.
- Решение о том, какой объект создавать, выносится в отдельную сущность `Solution`.
- В идеале, чтобы невозможным было создание объекта напрямую, делают конструкторы производных классов `protected`~--- тогда создавать их может только фабрика.
- Чтобы полностью закрыть доступ к конструктору за пределами фабрики, используют идиому прокси-класса для доступа к protected-конструктору.

#figure(
    image("attachments/factory-uml.jpg"),
)

=== Идиома невиртуального интерфейса (NVI)

- NVI~--- это когда публичный метод в базовом классе не является виртуальным, но внутри него вызывается защищённый виртуальный метод, который реализуют производные классы.
    - Пример: публичный метод `getProd()` не виртуален, а внутри него вызывается защищённый виртуальный метод (`createProd()` и т.п.), который реализует логику в производных классах.

==== Зачем это нужно

- Позволяет базовому классу держать под контролем общий алгоритм, не давая производным полностью подменять поведение.
- Базовый класс может реализовать общие проверки, кеширование, логику повторного использования, а производный класс реализует только создание или обработку специфического продукта.

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Очищение клиентского кода от создания конкретных объектов: клиент код становится независимым от конкретных типов, его легко модифицировать.
    - Безопасность: программисты не могут напрямую создавать объекты производных классов, защищая код от ошибок.
    - Гибкость: можно менять создаваемый тип на этапе выполнения, можно разносить решение и создание по разным частям кода и во времени.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Нужно "таскать" по коду указатель/ссылку на фабрику/креатор, если из разных мест нужно создать объекты~--- это бывает неудобно.
    - Когда по фабричному методу мы создаём объект в одном месте, а потом в другом месте нам нужен точно такой же объект, происходит следующее: если мы каждый раз вызываем фабрику, она создаст новый объект. Это проблема, особенно если это тяжёлый объект.
    - Если необходимо создавать объекты с разными параметрами, стандартная реализация становится громоздкой (разные данные~--- разные конструкторы, нужен шаблон).
    - В коде появляются дополнительные классы-фабрики, что усложняет структуру программы.
]

=== Пример

```cpp
#include <concepts>
#include <iostream>
#include <memory>

using namespace std;

template <typename Derived, typename Base>
concept Derivative = is_abstract_v<Base> && is_base_of_v<Base, Derived>;

template <typename Type>
concept NotAbstract = !is_abstract_v<Type>;

template <typename Type>
concept DefaultConstructible = is_default_constructible_v<Type>;

class Car;

class CarCreator
{
  public:
    virtual ~CarCreator() = default;
    virtual unique_ptr<Car> create() const = 0;
};

template <Derivative<Car> TCar>
    requires NotAbstract<TCar> && DefaultConstructible<TCar>
class ConcreteCarCreator : public CarCreator
{
  public:
    unique_ptr<Car> create() const override { return make_unique<TCar>(); }
};

class Car
{
  public:
    virtual ~Car() = default;
    virtual void drive() = 0;
};

class Sedan : public Car
{
  public:
    Sedan() { cout << "Sedan constructor called\n"; }
    ~Sedan() override { cout << "Sedan destructor called\n"; }
    void drive() override { cout << "Driving sedan\n"; }
};

class User
{
  public:
    void use(const shared_ptr<CarCreator>& creator)
    {
        shared_ptr<Car> car = creator->create();

        car->drive();
    }
};

int main()
{
    shared_ptr<CarCreator> creator = make_shared<ConcreteCarCreator<Sedan>>();

    User{}.use(creator);
}
```

== Абстрактная фабрика (Abstract Factory)

- Абстрактная фабрика объединяет несколько креаторов в одном классе для создания объектов, относящихся к одному семейству.
- Нужно, чтобы создавались объекты только одного семейства, например, для графических библиотек: `Graphics`, `Pen`, `Brush` и т.д.
- Не стоит использовать объекты из разных семейств вместе, чтобы избежать ошибок совместимости.

#image("attachments/abstract-factory-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Гарантируется совместимость создаваемых объектов (создаются только объекты одного семейства).
    - Упрощается конфигурирование системы: достаточно выбрать одну фабрику — и все компоненты будут подходящими друг к другу.
    - Упрощается поддержка и расширяемость: вся логика создания семейства объектов локализована в одной фабрике.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Главный недостаток тот же, что и у фабричного метода: нужно "таскать" фабрику везде, где создаются объекты, это не всегда удобно.
    - В разных семействах могут быть неравносильные составы объектов (в каком-то семействе может не быть конкретного продукта)~--- приходится решать эту проблему, например, созданием фиктивных объектов.
    - Абстрактная фабрика, как и другие креаторы, может "разрастаться" из-за увеличения числа продуктов и их вариантов.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class Image { };
class Color { };

class BaseGraphics
{
  public:
    virtual ~BaseGraphics() = 0;
};
BaseGraphics::~BaseGraphics()
{
}

class BasePen { };
class BaseBrush { };

class QtGraphics : public BaseGraphics
{
  public:
    QtGraphics(shared_ptr<Image> im) { cout << "Calling the QtGraphics constructor;\n"; }
    ~QtGraphics() override { cout << "Calling the QtGraphics destructor;\n"; }
};

class QtPen : public BasePen { };
class QtBrush : public BaseBrush { };

class AbstractGraphFactory
{
  public:
    virtual ~AbstractGraphFactory() = default;

    virtual unique_ptr<BaseGraphics> createGraphics(shared_ptr<Image> im) = 0;
    virtual unique_ptr<BasePen> createPen(shared_ptr<Color> cl) = 0;
    virtual unique_ptr<BaseBrush> createBrush(shared_ptr<Color> cl) = 0;
};

class QtGraphFactory : public AbstractGraphFactory
{
  public:
    unique_ptr<BaseGraphics> createGraphics(shared_ptr<Image> im) override { return make_unique<QtGraphics>(im); }

    unique_ptr<BasePen> createPen(shared_ptr<Color> cl) override { return make_unique<QtPen>(); }

    unique_ptr<BaseBrush> createBrush(shared_ptr<Color> cl) override { return make_unique<QtBrush>(); }
};

class User
{
  public:
    void use(shared_ptr<AbstractGraphFactory>& cr)
    {
        shared_ptr<Image> image = make_shared<Image>();
        auto graphics = cr->createGraphics(image);
    }
};

int main()
{
    shared_ptr<AbstractGraphFactory> grfactory = make_shared<QtGraphFactory>();

    unique_ptr<User> us = make_unique<User>();

    us->use(grfactory);
}
```

== Строитель (Builder)

- Строитель~--- это порождающий паттерн для поэтапного создания сложного объекта, когда для его сборки нужно выполнить несколько действий последовательно и осмысленно организовать процесс создания.
- Выделяется класс "строитель (`Builder`)", у которого есть какие-то этапы строительства, как на реальной стройке, где работы идут по шагам. \
    Эти этапы определяют порядок и способ сборки целевого объекта, оставаясь внутри ответственности строителя.
- Кто-то должен вызывать эти методы, кто-то должен контролировать выполнение этих этапов~--- вводится роль "директор (`Director`)". \
    Задача директора~--- проконтролировать выполнение этих этапов и вернуть созданный объект, причём у директора должен быть метод `create`, который запускает сборку и отдаёт результат.
- Типичная ошибка: директор "подносит кирпичи строителю", то есть сам делает то, что обязан делать строитель.
    - Директор может передавать какие-то данные, но он не должен выполнять этапы строительства.

#image("attachments/builder-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Разделяет создание сложного объекта на этапы, делая процесс прозрачным и управляемым через строитель с последовательными шагами.
    - Вводит директора, который контролирует выполнение этапов и возвращает созданный объект через метод `create`, удерживая процесс создания в одном месте.
    - Можно включить директора в общую иерархию создателей, то есть сделать директора наследником креатора, чтобы единообразно вызывать `create` для простых и сложных случаев, скрывая различие реализации за общим интерфейсом.

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Паттерн предполагает дополнительные роли и этапы по сравнению с простым креатором, что увеличивает структурную сложность ради корректной поэтапной сборки.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class Product
{
  public:
    virtual ~Product() = default;

    virtual void run() = 0;
};

class ConProd1 : public Product
{
  public:
    ConProd1() { cout << "Calling the ConProd1 constructor;\n"; }
    ~ConProd1() override { cout << "Calling the ConProd1 destructor;\n"; }

    void run() override { cout << "Calling the run method;\n"; }
};

class Builder
{
  public:
    virtual ~Builder() = default;

    virtual bool buildPart1() = 0;
    virtual bool buildPart2() = 0;

    shared_ptr<Product> getProduct();

  protected:
    virtual shared_ptr<Product> createProduct() = 0;

    shared_ptr<Product> product{nullptr};
    size_t part{0};
};

class ConBuilder : public Builder
{
  public:
    bool buildPart1() override
    {
        if (!part) {
            ++part;
        }
        if (part != 1) {
            return false;
        }

        cout << "Completed part: " << part << ";\n";
        return true;
    }
    bool buildPart2() override
    {
        if (part == 1) {
            ++part;
        }
        if (part != 2) {
            return false;
        }

        cout << "Completed part: " << part << ";\n";
        return true;
    }

  protected:
    shared_ptr<Product> createProduct() override;
};

class Creator
{
  public:
    virtual ~Creator() = default;

    virtual shared_ptr<Product> create() = 0;
};

class Director : public Creator
{
  public:
    Director(shared_ptr<Builder> builder) : br(builder) {}

    shared_ptr<Product> create() override
    {
        if (br->buildPart1() && br->buildPart2()) {
            return br->getProduct();
        }

        return nullptr;
    }

  private:
    shared_ptr<Builder> br;
};

shared_ptr<Product> Builder::getProduct()
{
    if (!product) {
        product = createProduct();
    }
    return product;
}

shared_ptr<Product> ConBuilder::createProduct()
{
    if (part == 2) {
        product = make_shared<ConProd1>();
    }
    return product;
}

class User
{
  public:
    void use(shared_ptr<Creator>& cr)
    {
        shared_ptr<Product> prod = cr->create();
        if (prod) {
            prod->run();
        }
    }
};

int main()
{
    shared_ptr<Builder> builder = make_shared<ConBuilder>();
    shared_ptr<Creator> cr = make_shared<Director>(builder);

    User{}.use(cr);
}
```
