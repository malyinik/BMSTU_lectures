= Структурные паттерны: адаптер (Adapter), декоратор (Decorator), компоновщик (Composite), мост (Bridge), заместитель (Proxy), фасад (Facade). Их преимущества и недостатки.

== Структурные паттерны

Структурные паттерны~--- это группа шаблонов проектирования, которая решает задачи, связанные с организацией классов и объектов в более крупные структуры.

== Адаптер (Adapter)

+ В одном месте программы с сущностью работают через один интерфейс, в другом~--- через другой. Это делается адаптерами. Программист, модифицируя свою часть, не трогает саму сущность~--- он работает только со "своим" интерфейсом (своим адаптером). Остальные части кода не страдают, всё продолжает работать.
    - Если сущность меняется, для неё делают новые адаптеры. Каждый у себя создаёт адаптер~--- написанный код не трогается.
+ Второе использование адаптера: на одну роль могут возлагаться несколько обязанностей; возникает потребность менять каждую обязанность независимо. Тогда для каждой обязанности делают адаптер.
+ Проблема абстрактной фабрики/семейств: хотим подменять одно семейство объектов на другое (например, `Pen` из разных графических библиотек), но у них нет общей базы. \
    Идея: сделать адаптер "над `Pen`-ом" одной библиотеки и адаптер~--- над другой, связать их общей абстракцией. Тогда можно подменять объекты между библиотеками.
    - Жёсткое правило: если используем нестандартную библиотеку, работать с её сущностями нужно только через адаптер. Библиотеку могут перестать поддерживать; найдём лучше~--- заменим. Через адаптеры это делается легко, без выпиливания по всему коду, не изменяя написанный код.
+ Ещё одна важная проблема~--- "реализация" в наследниках (добавляем методы, которых нет в базовой абстракции)~--- это плохо. Как работать с расширенным интерфейсом, не меняя базовую абстракцию и не переписывая иерархию? Идея: расширять интерфейс за счёт адаптера.
    - Адаптер может адаптировать целую иерархию (добавить функционал сразу всем).
    - Уходим от дублирования кода и от проблем с приведением типов (спрашивать "ты кто" и поддерживаешь ли интерфейс~--- не нужно).
    - Через адаптер можно "расширенно" работать с любой сущностью.

#image("attachments/adapter-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Изоляция изменений: программист меняет только свой интерфейс (свой адаптер), сущность и чужие части кода не трогаются; написанный код не изменяется.
    - Лёгкая подмена библиотек и семейств: через адаптеры связываем разные реализации общей абстракцией и подменяем без переписывания.
    - Расширение интерфейса без изменения иерархии: можно добавить функционал через адаптер, сразу для всей иерархии.
    - Уходим от проблем с приведением типов и от дублирования (в случае добавления общего функционала через один адаптер).

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Резкое увеличение числа классов-обёрток.
    - Всё держится на полиморфизме~--- это влияет на время выполнения, причём резко.
    - При нескольких ролях интерфейсы могут пересекаться~--- дублирование кода.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class BaseAdaptee
{
  public:
    virtual ~BaseAdaptee() = default;

    virtual void specificRequest() = 0;
};

class ConAdaptee : public BaseAdaptee
{
  public:
    void specificRequest() override {}
};

class Adapter
{
  public:
    virtual ~Adapter() = default;

    virtual void request() = 0;
};

class ConAdapter : public Adapter
{
  private:
    shared_ptr<BaseAdaptee> adaptee;

  public:
    ConAdapter(shared_ptr<BaseAdaptee> ad) : adaptee(ad) {}

    void request() override;
};

void ConAdapter::request()
{
    cout << "Adapter: ";

    if (adaptee) {
        adaptee->specificRequest();
    } else {
        cout << "Empty!" << endl;
    }
}

int main()
{
    shared_ptr<BaseAdaptee> adaptee = make_shared<ConAdaptee>();
    shared_ptr<Adapter> adapter = make_shared<ConAdapter>(adaptee);

    adapter->request();
}
```

== Декоратор (Decorator)

=== Контекст проблемы (почему нужен)

При рекурсивном дизайне мы наследуемся и добавляем поведение в производных классах (до/после базового метода). Это ведет к разрастанию иерархии и дублированию кода, особенно если одно и то же "добавление" нужно ко многим сущностям или в разных комбинациях.

=== Идея и определение

- То, что "добавляем", выносим в отдельную сущность того же класса, которая будет добавлять поведение к каждой конкретной сущности.
- Паттерн Декоратор: имеет тот же интерфейс, что и базовый компонент, и содержит указатель на компонент. Мы "оборачиваем" объект и добавляем нужное поведение.

=== Структура и как работает

- Декоратор~--- производный от компонента (тот же интерфейс) и держит указатель на этот компонент.
- Можно декорировать декоратор: декоратор сам может быть ещё чем-то продекорирован. Таким образом, можно наращивать функциональность цепочкой.
- Добавления до и после базового вызова лучше разносить в разные декораторы.
- Декоратор не обязан вызывать метод базового компонента. Пример: "закрыть" объект~--- сам объект тогда не будет рисоваться (декоратор может перехватить и не вызывать базовый метод).
- В коде мы фактически заменяем прямое обращение к объекту на обращение через указатель на компонент (который может указывать на декорированный объект).

=== Использование

- Объект создаем "креатором" (фабрикой) как обычно, а декорировать можем на этапе выполнения: поведение объекта может меняться во время выполнения программы.
- Можно легко "мигрировать" поведение: не нужно перегонять объект из одного класса в другой~--- просто продекорировали.
- Можно менять декораторы или "переназначать" указатель на другой объект~--- и тот окажется продекорирован.

=== Замечания по проектированию

- Декоратор часто делают абстрактным, а конкретные "добавления"~--- отдельными конкретными декораторами.
- Нужен "главный решала", кто принимает решение и знает, как именно и в какой последовательности декорировать (эту логику надо учитывать в креаторах).

#image("attachments/decorator-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Нет разрастания иерархии: то, что добавляем, выносим в декораторы.
    - Нет дублирования кода: общее добавление реализуется один раз в декораторе.
    - Гибкость: можно декорировать во время выполнения, поведение объекта меняется динамически.
    - Можно декорировать декоратор (комбинаторика добавлений).
    - Декоратор может перехватывать вызовы и не вызывать базовый метод (например, «закрыть» отрисовку объекта).
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Создание продекорированных объектов~--- "не простой" креатор: нужна правильная последовательность декорирования, это сложная логика, её надо учитывать в фабриках; должен быть «главный решала».
    - Нельзя просто «выкинуть один декоратор из середины» цепочки: чтобы исключить декоратор, нужно заново продекорировать объект.
    - Производительность: всё на полиморфизме и виртуальных таблицах; цепочка декораторов~--- куча виртуальных таблиц, проход по ним замедляет выполнение.
    - Риск ошибок конфигурации: «программисту доверять нельзя»~--- легко неправильно собрать цепочку, если не централизовать решение.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class Component
{
  public:
    virtual ~Component() = default;

    virtual void operation() = 0;
};

class ConComponent : public Component
{
  public:
    void operation() override { cout << "ConComponent; "; }
};

class Decorator : public Component
{
  protected:
    shared_ptr<Component> component;

  public:
    Decorator(shared_ptr<Component> comp) : component(comp) {}
};

class ConDecorator : public Decorator
{
  public:
    using Decorator::Decorator;

    void operation() override;
};

void ConDecorator::operation()
{
    if (component) {
        component->operation();
        cout << "ConDecorator; ";
    }
}

int main()
{
    shared_ptr<Component> component = make_shared<ConComponent>();
    shared_ptr<Component> decorator1 = make_shared<ConDecorator>(component);

    decorator1->operation();
    cout << endl;

    shared_ptr<Component> decorator2 = make_shared<ConDecorator>(decorator1);

    decorator2->operation();
    cout << endl;
}
```

== Компоновщик (Composite)

=== Основные идеи компоновщика

- Компоновщик (`Composite`) нужен, когда есть объекты, которые могут объединяться в группы и над которыми нужно выполнять одинаковые операции.
- Компоновщик сам является компонентом, то есть `Composite` наследуется от того же интерфейса/абстракции, что и отдельные компоненты. Благодаря этому над композитом можно выполнять те же действия (например, повернуть, перенести), что и над отдельным компонентом.
- Содержит коллекцию компонентов. Для этого в компоновщике используется контейнер (чаще всего стандартный контейнер типа `vector`, `list`):
- С композитом можно работать так же, как и с отдельными элементами, не погружаясь в детали и структуру вложенности~--- это главное преимущество.

=== Особенности интерфейса

- Абстракция (интерфейс компонента) должна предусматривать методы для работы с группами (например, добавить, удалить компонент, получить доступ к компоненту), хотя отдельный компонент эти методы реализовать не может.
- Для типизации всегда добавляют метод, позволяющий отличить композит от простого компонента:
- Один и тот же объект может входить в разные композиты. Изменение объекта в одном композите приведёт к изменению и в других.
- Это удобно для проектирования и позволяет строить иерархии объектов разного уровня вложенности.

=== Примеры компоновщиков

- Машина: это композит из двигателя, коробки передач, и других частей, которые, в свою очередь, могут быть тоже композитами.
- Один и тот же объект может быть частью разных композитов (например, компонент двигателя и компонент всей машины).

#image("attachments/composite-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Прячутся циклы: работа с коллекциями компонентов организована через компоновщик (внутри), снаружи же пользователь работает с композитом как с обычным объектом.
    - Гибкое добавление и удаление компонентов: можно легко расширять систему, добавляя новые виды компонентов и композитов.
    - Удобство проектирования и расширяемость: можно создавать разветвлённые и иерархические структуры произвольной глубины.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Вызовы по виртуальным функциям: обращение происходит через виртуальный интерфейс, что может накладывать издержки на производительность.
    - Необходимость итерирования по композиту: для некоторых задач (например, удержание фокуса на отдельном объекте) требуется обход и итерирование внутри композита, что может усложнять логику.
    - Один и тот же объект в разных композитах требует особого внимания~--- изменение объекта в одном месте влияет и на все остальные композиты с этим объектом.
    - Некоторые методы интерфейса (добавление/удаление компонента) бессмысленны для простых компонентов: их приходится реализовывать как пустые или "заглушки", чтобы соответствовать общему интерфейсу.
]

=== Пример

```cpp
#include <initializer_list>
#include <iostream>
#include <memory>
#include <vector>

using namespace std;

class Component;

using PtrComponent = shared_ptr<Component>;
using VectorComponent = vector<PtrComponent>;

class Component
{
  public:
    using value_type = Component;
    using size_type = size_t;
    using iterator = VectorComponent::const_iterator;
    using const_iterator = VectorComponent::const_iterator;

    virtual ~Component() = default;

    virtual void operation() = 0;

    virtual bool isComposite() const { return false; }
    virtual bool add(initializer_list<PtrComponent> comp) { return false; }
    virtual bool remove(const iterator& it) { return false; }
    virtual iterator begin() const { return iterator(); }
    virtual iterator end() const { return iterator(); }
};

class Figure : public Component
{
  public:
    virtual void operation() override { cout << "Figure method;" << endl; }
};

class Camera : public Component
{
  public:
    virtual void operation() override { cout << "Camera method;" << endl; }
};

class Composite : public Component
{
  private:
    VectorComponent vec;

  public:
    Composite() = default;
    Composite(PtrComponent first, ...);

    void operation() override;

    bool isComposite() const override { return true; }
    bool add(initializer_list<PtrComponent> list) override;
    bool remove(const iterator& it) override
    {
        vec.erase(it);
        return true;
    }
    iterator begin() const override { return vec.begin(); }
    iterator end() const override { return vec.end(); }
};

Composite::Composite(PtrComponent first, ...)
{
    for (shared_ptr<Component>* ptr = &first; *ptr; ++ptr) {
        vec.push_back(*ptr);
    }
}

void Composite::operation()
{
    cout << "Composite method:" << endl;
    for (auto elem : vec) {
        elem->operation();
    }
}

bool Composite::add(initializer_list<PtrComponent> list)
{
    for (auto elem : list) {
        vec.push_back(elem);
    }
    return true;
}

int main()
{
    using Default = shared_ptr<Component>;
    PtrComponent fig = make_shared<Figure>();
    PtrComponent cam = make_shared<Camera>();
    auto composite1 = make_shared<Composite>(fig, cam, Default{});

    composite1->add({make_shared<Figure>(), make_shared<Camera>()});
    composite1->operation();
    cout << endl;

    auto it = composite1->begin();

    composite1->remove(++it);
    composite1->operation();
    cout << endl;

    auto composite2 = make_shared<Composite>(make_shared<Figure>(), composite1, Default());

    composite2->operation();
}
```

== Мост (Bridge)

=== Определение и основная идея

Паттерн "Мост" предназначен для того, чтобы разделить сущность и её реализацию, что позволяет независимо изменять и сущность, и реализацию.

=== Зачем нужен паттерн Мост

- Когда у объекта есть несколько возможных реализаций, и эти реализации могут меняться независимо от самой абстракции.
- Если мы заранее понимаем, что реализация может меняться, используем Мост.
    - Пример: модель можно представлять списком вершин и рёбер или в виде матрицы смежности~--- объект остаётся тем же, реализация~--- разная.

=== Реализация

- Обычно изображают схемой (диаграммой): одна ветка~--- абстракция, другая~--- реализация, между ними устанавливается связь.
- Не всегда удается свести к дереву базовых абстракций, потому что реализации не обязаны быть древовидными.
- Иногда понимание использования "моста" видно по суффиксу `Impl` (implementation) в названиях методов и объектов.

=== Эффект от применения

- Мы можем легко порождать новые производные классы, а также новые реализации~--- то есть, расширяемость по двум измерениям сразу.
- В коде становится очевидно, что сущность отделена от своей реализации~--- так повышается гибкость.

#image("attachments/bridge-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Гибкость архитектуры: мы можем независимо менять сущность и независимо менять реализацию.
    - Легко добавлять новые реализации без изменения существующих абстракций.
    - Обеспечивает удобную структуру для поддержки множества вариантов реализации.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Этот паттерн довольно сложный, он требует более сложного проектирования.
    - На практике не всегда удается свести к связи базовых абстракций, потому что реализация не всегда выглядит в виде дерева.
    - Может появиться избыточность связей, если архитектура проекта не требует такой гибкости.
    - Приводит к усложнению кода и необходимости тщательнее проектировать и следить за структурой системы.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class Implementor
{
  public:
    virtual ~Implementor() = default;

    virtual void operationImp() = 0;
};

class Abstraction
{
  protected:
    shared_ptr<Implementor> implementor;

  public:
    Abstraction(shared_ptr<Implementor> imp) : implementor(imp) {}
    virtual ~Abstraction() = default;

    virtual void operation() = 0;
};

class ConImplementor : public Implementor
{
  public:
    void operationImp() override { cout << "Implementor;\n"; }
};

class Entity : public Abstraction
{
  public:
    using Abstraction::Abstraction;

    void operation() override
    {
        cout << "Entity: ";
        implementor->operationImp();
    }
};

int main()
{
    shared_ptr<Implementor> implementor = make_shared<ConImplementor>();
    shared_ptr<Abstraction> abstraction = make_shared<Entity>(implementor);

    abstraction->operation();
}
```

== Заместитель (Proxy)

- Мы создаём объект, через который будем получать доступ к нашим объектам.
- Заместитель, или прокси (`proxy`), входит в общую иерархию с объектом и через него мы обращаемся к нашему объекту.
+ Прокси нужен для того, чтобы, например, реализовать функцию кэширования запросов:
    - Когда мы делаем какой-то запрос через `proxy`, он смотрит: был такой запрос или нет.
    - Если такой запрос уже был, `proxy` даёт уже сохранённый ответ, не обращаясь к самому объекту.
    - Однако есть нюанс: объект мог измениться, и старые ответы уже нерелевантны~--- тогда надо снова обращаться к объекту.
+ `Proxy` также может фильтровать запросы, т.е. не все запросы допускать до реального объекта (например, фильтрация по правам пользователя).
+ `Proxy` может выполнять шифрование и дешифрование запросов и ответов.
+ Можно использовать `proxy` для сбора статистики, аналитики по обращениям к объекту и других служебных функций.
+ `Proxy` может отвечать за жизненный цикл объекта:
    - Иногда объекты "тяжёлые", поэтому их не стоит создавать сразу~--- `proxy` может сам управлять созданием, когда это действительно потребуется.
    - Важно понимать ситуацию, что объекта ещё нет или он уже отсутствует, а `proxy` возвращает, будто он есть.

#image("attachments/proxy-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Экономия ресурсов: позволяет кэшировать запросы и повторно использовать уже полученные результаты.
    - Обеспечивает фильтрацию или разграничение доступа к объекту за счёт дополнительных проверок на уровне `proxy`.
    - Расширение функционала без изменения кода "основного объекта": может брать на себя функции шифрования, дешифрования, сбора статистики, аналитики.
    - Управляет жизненным циклом тяжелых объектов: создаёт их только тогда, когда это необходимо.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Необходимость учитывать, что данные в proxy могут устаревать (если основной объект изменился).
    - Иногда приводит к усложнению архитектуры за счёт необходимости отслеживать актуальность кэшированных данных и состояния реального объекта.
    - Увеличивается время выполнения операций: каждый запрос идёт через дополнительный уровень (proxy).
]

=== Пример

```cpp
#include <iostream>
#include <map>
#include <memory>
#include <random>

using namespace std;

class Subject
{
  public:
    virtual ~Subject() = default;

    virtual pair<bool, double> request(size_t index) = 0;
    virtual bool changed() { return true; }
};

class RealSubject : public Subject
{
  private:
    bool flag{false};
    size_t counter{0};

  public:
    pair<bool, double> request(size_t index) override;
    bool changed() override;
};

class Proxy : public Subject
{
  protected:
    shared_ptr<RealSubject> realsubject;

  public:
    Proxy(shared_ptr<RealSubject> real) : realsubject(real) {}
};

class ConProxy : public Proxy
{
  private:
    map<size_t, double> cache;

  public:
    using Proxy::Proxy;

    pair<bool, double> request(size_t index) override;
};

bool RealSubject::changed()
{
    if (counter == 0) {
        flag = true;
    }
    if (++counter == 7) {
        counter = 0;
        flag = false;
    }
    return flag;
}

pair<bool, double> RealSubject::request(size_t index)
{
    random_device rd;
    mt19937 gen(rd());

    return pair<bool, double>(true, generate_canonical<double, 10>(gen));
}

pair<bool, double> ConProxy::request(size_t index)
{
    pair<bool, double> result;

    if (!realsubject) {
        cache.clear();
        result = pair<bool, double>(false, 0.);
    } else if (!realsubject->changed()) {
        cache.clear();
        result = realsubject->request(index);
        cache.insert(map<size_t, double>::value_type(index, result.second));
    } else {
        map<size_t, double>::const_iterator it = cache.find(index);

        if (it != cache.end()) {
            result = pair<bool, double>(true, it->second);
        } else {
            result = realsubject->request(index);
            cache.insert(map<size_t, double>::value_type(index, result.second));
        }
    }

    return result;
}

int main()
{
    shared_ptr<RealSubject> subject = make_shared<RealSubject>();
    shared_ptr<Subject> proxy = make_shared<ConProxy>(subject);

    for (size_t i = 0; i < 21; ++i) {
        cout << "( " << i + 1 << ", " << proxy->request(i % 3).second << " )\n";

        if ((i + 1) % 3 == 0) {
            cout << endl;
        }
    }
}
```

== Фасад (Facade)

- Представим, что у нас не один объект, а "мир объектов", между которыми существуют связи, и часто нужно следить за этими связями, за целостностью этих объектов.
- Паттерн "Фасад" похож на паттерн "Адаптер", но это не адаптер. Фасад скрывает от нас множество объектов. \
    #text(fill: gray)[
        Я (лектор) общаюсь с вами сейчас как раз через фасад~--- не взаимодействую с каждым из вас по отдельности, а работаю с вашим обобщённым интерфейсом (фасадом).
    ]
- Фасад скрывает внутреннюю реализацию множества объектов и их связей.
- Задача фасада~--- упростить взаимодействие с "миром объектов" и чётко выделить интерфейс этого мира.
- Функция фасада~--- обеспечить целостность мира. \
    #text(fill: gray)[
        Я (лектор) взаимодействую с вами через фасад, который не даёт мне "разрушить вашу целостность".
    ]
- Важно проектировать систему так, чтобы извне нельзя было нарушить целостность: ничего не должно торчать наружу.
- Фасад выступает в роли оболочки.

#image("attachments/facade-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Облегчает взаимодействие с системой, предоставляя единый, простой интерфейс.
    - Скрывает сложную внутреннюю структуру множества объектов и их связей.
    - Обеспечивает целостность внутреннего мира объектов — защищает объекты от некорректного внешнего воздействия.
    - Внешний код не может "разрушить" или "нарушить" внутреннюю структуру, если взаимодействует только через фасад.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Если что-то торчит наружу, то есть интерфейс неудачно спроектирован, то фасад теряет смысл — целостность может быть нарушена.
    - Фасад не всегда предотвращает попытки пользователя "ворваться" в систему, особенно если изначально не был чётко выделен внешний интерфейс.
]

=== Пример

```cpp
#include <iostream>
#include <string>

// --- Подсистемы ---
class Amplifier
{
  public:
    void on() { std::cout << "Amplifier: on\n"; }
    void off() { std::cout << "Amplifier: off\n"; }
    void setVolume(int v) { std::cout << "Amplifier: volume " << v << "\n"; }
};

class DvdPlayer
{
  public:
    void on() { std::cout << "DVD: on\n"; }
    void off() { std::cout << "DVD: off\n"; }
    void play(const std::string& title) { std::cout << "DVD: play \"" << title << "\"\n"; }
    void stop() { std::cout << "DVD: stop\n"; }
};

class Projector
{
  public:
    void on() { std::cout << "Projector: on\n"; }
    void off() { std::cout << "Projector: off\n"; }
    void wideMode() { std::cout << "Projector: wide mode\n"; }
};

class Screen
{
  public:
    void down() { std::cout << "Screen: down\n"; }
    void up() { std::cout << "Screen: up\n"; }
};

class Lights
{
  public:
    void dim(int level) { std::cout << "Lights: dim to " << level << "%\n"; }
    void on() { std::cout << "Lights: on\n"; }
};

// --- Фасад ---
class HomeTheaterFacade
{
    Amplifier amp;
    DvdPlayer dvd;
    Projector projector;
    Screen screen;
    Lights lights;

  public:
    // Сценарий «посмотреть фильм»
    void watchMovie(const std::string& title)
    {
        std::cout << "\n== Watch movie ==\n";
        lights.dim(20);
        screen.down();
        projector.on();
        projector.wideMode();
        amp.on();
        amp.setVolume(7);
        dvd.on();
        dvd.play(title);
        std::cout << "== Enjoy! ==\n\n";
    }

    // Сценарий «закончить просмотр»
    void endMovie()
    {
        std::cout << "== End movie ==\n";
        dvd.stop();
        dvd.off();
        amp.off();
        projector.off();
        screen.up();
        lights.on();
        std::cout << "== Done ==\n\n";
    }
};

// --- Клиент ---
int main()
{
    HomeTheaterFacade theater;
    theater.watchMovie("Inception");
    theater.endMovie();
}
```
