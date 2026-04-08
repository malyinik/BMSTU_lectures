= Паттерны поведения: стратегия (Strategy), команда (Command), цепочка обязанностей (Chain of Responsibility), подписчик-издатель (Publish-Subscribe), посредник (Mediator). Их преимущества и недостатки.

== Паттерны поведения

=== Что такое паттерны поведения

- Это подход, где мы выносим изменяемые части поведения (реализации алгоритмов/методов) из сущности в отдельные сущности и подставляем их при работе.
- Формулировка через сравнение: "вырожденный мост"~--- это паттерн поведения; если мост отделяет сущность от реализации "в целом", то в поведенческом подходе отделяется реализация одного конкретного метода (алгоритма).

=== Зачем они нужны (какие проблемы решают)

- Уход от реализации: позволяют уйти от реализации в смысле разрастания иерархий за счет разных производных, когда методы по‑разному реализуются. Вместо расширения иерарии~--- выносим то, что меняем, в отдельные сущности поведения.
- Борьба с разрастанием иерархии и дублированием кода: изменения концентрируются в "поведении", базовая сущность не плодит наследников и не копирует одинаковые куски.
- Гибкость: легко менять поведение объекта во время выполнения (подменой поведения).
- Переиспользование: одно и то же "поведение" можно применять в разных ролях/для разных сущностей.

== Стратегия (Strategy)

=== Главная идея паттерна

Всё, что меняется (например, алгоритм), выносится в отдельный объект стратегии. Можно легко поменять поведение объекта во время выполнения, просто подменяя стратегию.

=== Пример с сортировкой (классическая реализация)

- В языке Cи: чтобы отсортировать, например, студентов по различным признакам, передаётся указатель на функцию сравнения~--- это callback-функция.
- Но с функциями работать мы не будем, а будем оборачивать функцию в класс~--- вот это и есть паттерн стратегия.

=== Роль стратегии

- Выносит конкретную реализацию метода (алгоритма) в отдельную сущность.
- У одного объекта может быть несколько методов, и для каждого~--- отдельная иерархия стратегий.
- Всё изменение поведения происходит за счёт стратегий~--- "нам не нужно разрастание иерархии сущностей, весь функционал выносим в стратегии".

#image("attachments/strategy-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])

    - Позволяет легко менять поведение объекта во время выполнения.
    - Избавляет от дублирования кода.
    - Избавляет от разрастания иерархии классов.
    - Одну и ту же стратегию можно использовать для разных ролей и сущностей.
    - Позволяет реализовать гибкое расширение поведения, альтернативу традиционному наследованию.

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])

    - Происходит разрастание числа классов для стратегий.
    - Все изменения функциональности привязаны к стратегиям~--- возможны сложности с их организацией и поддержкой.
    - Иерархия стратегий может быть громоздкой, если для каждого метода нужна своя стратегия.
    - Конкретная стратегия может не работать с данными определенного класса, что приводит к появлению зависимостей между конкретными сущностями и стратегиями.
]

=== Пример

```cpp
#include <iostream>
#include <memory>

using namespace std;

class Strategy
{
  public:
    virtual ~Strategy() = default;

    virtual void algorithm() = 0;
};

class ConStrategy1 : public Strategy
{
  public:
    void algorithm() override { cout << "Algorithm 1;" << endl; }
};

class ConStrategy2 : public Strategy
{
  public:
    void algorithm() override { cout << "Algorithm 2;" << endl; }
};

class Context
{
  protected:
    unique_ptr<Strategy> strategy;

  public:
    explicit Context(unique_ptr<Strategy> ptr = make_unique<ConStrategy1>()) : strategy(move(ptr)) {}
    virtual ~Context() = default;

    virtual void algorithmStrategy() = 0;
};

class Client1 : public Context
{
  public:
    using Context::Context;

    void algorithmStrategy() override { strategy->algorithm(); }
};

int main()
{
    shared_ptr<Context> obj = make_shared<Client1>(make_unique<ConStrategy2>());

    obj->algorithmStrategy();
}
```

== Команда (Command)

=== Что такое "Команда"

- Наиболее распространённый паттерн для работы с запросами.
- Каждый запрос~--- переносчик данных. При формировании команды в ней "зашивается" метод, который нужно вызвать (и, по крайней мере, к какому классу относится адресат).
- Выполнение команды~--- это вызов одного метода. По сути "команда~--- это один метод".

=== Как устроено выполнение

- Формируем запрос/команду, передаём её "ответственному", который может её выполнить; он берёт и выполняет, т.е. вызывает нужный метод.
- Обычно объект-адресат либо подставляется перед выполнением (до вызова метода), либо передаётся прямо в метод исполнения.

=== Данные и параметры

- Данные команды передаются при создании (в конструктор).
- Параметры можно передавать; чаще всего~--- это сам объект, для которого вызывается метод.

=== Составные команды

- Можно создавать "сложные команды", включающие подкоманды.
    - Пример (графика): "повернуть объект" нажатой кнопкой = очистить окно $->$ повернуть объект $->$ нарисовать.
- Составная команда~--- фактически контейнер под простые команды; важен чёткий порядок выполнения. Специальной сложной манипуляции подкомандами обычно не требуется~--- главное, чтобы порядок был фиксирован.

=== Работа с выполнением

- Команду не обязательно выполнять сразу: можно поставить в очередь, выполнить позже или даже проигнорировать (логика обработки может быть произвольной).

#image("attachments/command-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Простота исполнения: выполнение~--- вызов одного метода.
    - Можно ставить команды в очередь, откладывать или игнорировать.
    - Есть возможность собирать сложные команды из простых с гарантированным порядком выполнения.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - "Команда~--- очень жёсткий паттерн": метод, который нужно вызвать, должен быть зашит в команде~--- "жёсткая связка с прикладным доменом " и с конкретным методом.
    - Рассчитано на одного адресата: если запрос должен выполняться несколькими объектами, это выходит за рамки Команды (нужна "Цепочка обязанностей").
    - На практике часто приходится знать не только метод, но и объект-адресат (его передают заранее или в момент вызова).

]

=== Пример

```cpp
#include <initializer_list>
#include <iostream>
#include <memory>
#include <vector>

using namespace std;

class Command
{
  public:
    virtual ~Command() = default;

    virtual void execute() = 0;
};

template <typename Receiver>
class SimpleCommand : public Command
{
    using Action = void (Receiver::*)();
    using Pair = pair<shared_ptr<Receiver>, Action>;

  private:
    Pair call;

  public:
    SimpleCommand(shared_ptr<Receiver> r, Action a) : call(r, a) {}

    void execute() override { ((*call.first).*call.second)(); }
};

class CompoundCommand : public Command
{
    using VectorCommand = vector<shared_ptr<Command>>;

  private:
    VectorCommand vec;

  public:
    CompoundCommand(initializer_list<shared_ptr<Command>> lt);

    void execute() override;
};

CompoundCommand::CompoundCommand(initializer_list<shared_ptr<Command>> lt)
{
    for (auto&& elem : lt) {
        vec.push_back(elem);
    }
}

void CompoundCommand::execute()
{
    for (auto& com : vec) {
        com->execute();
    }
}

class Object
{
  public:
    void run() { cout << "Run method;" << endl; }
};

int main()
{
    shared_ptr<Object> obj = make_shared<Object>();
    shared_ptr<Command> command = make_shared<SimpleCommand<Object>>(obj, &Object::run);

    command->execute();

    shared_ptr<Command> complex(new CompoundCommand{
         make_shared<SimpleCommand<Object>>(obj, &Object::run),
         make_shared<SimpleCommand<Object>>(obj, &Object::run)
         });

    complex->execute();
}
```


== Цепочка обязанностей (Chain of Responsibility)

=== Определение и идея

- Идея: из тех, кто может обработать запрос, формируется список (цепочка). Мы формируем запрос и отдаём его по списку.
- Первый в списке принимает запрос, смотрит, может ли он его выполнить. Дальше варианты:
    + может обработать и передать дальше;
    + может обработать и не передавать дальше;
    + может не обрабатывать и передать дальше.
- Запрос передаётся по цепочке, пока не будет обработан (или не дойдёт до конца).

=== Отвязка от конкретных обработчиков

- Мы чётко отвязываемся: просто формируем запрос и передаём его без привязки к конкретному объекту/методу.
- Запрос~--- это по существу данные (возможно с какой-то информацией о том, кто бы мог обработать).
- В отличие от "команды", где всё равно есть жёсткая привязка к конкретному методу, здесь хотим полностью отвязаться от конкретного объекта и метода, потому что могут выполнять разные объекты.

=== Динамика и порядок

- Мы можем динамически формировать тех, кто может обрабатывать запрос: обработчики могут появляться и исчезать, их можно убирать/добавлять в список.
- От порядка обработки (порядка формирования списка) может изменяться результат~--- это важный момент.

=== Изменяемость запроса

Запрос может видоизменяться, "обрастать" данными по мере прохождения по цепочке: один обработчик добавил информацию~--- дальше она уже идёт в обогащённом виде.

==== Пример (камеры фотовидеофиксации)

- Есть факт прохождения транспортного средства. Сервер распознавания (на столбе) выдаёт один или несколько кадров, пытается распознать ГРЗ, марку автомобиля; в пакет обычно включают также скорость.
- Далее по цепочке возможны обработки:
    - проверка превышения скорости;
    - обращение к базе ГИБДД (сверка распознанной марки и номера);
    - проверка по базе розыска;
    - фильтр на ТС, представляющие оперативный интерес (оперативный сотрудник получает уведомление).
- Если, например, марка не распозналась, обработчик, работающий с базой ГИБДД, просто пропускает запрос дальше.

=== Замечание о невыполнении

- В "команде" в любом случае будет вызван метод конкретного класса (команда выполнится).
- В "цепочке обязанностей" запрос может не выполниться (никто его не обработает).

=== Структурные заметки (как хранить цепочку)

- Обработчик можно рассматривать как узел списка, который "обрабатывает и передаёт следующему".
- Или рассматривать обработчик как информационную часть узла, а сам список~--- как контейнер.
- Удобно, что формируем свой контейнер и интерфейс под него:
    - операции добавления/удаления обработчиков;
    - метод "принять запрос";
    - метод, который возвращает данные/признак, на основе которых понимаем~--- обрабатываем запрос или нет.
- По цепочке запрос может "обрастать" новой информацией (например, добавились данные из ГИБДД, затем~--- о владельце ТС и т.д.).

#image("attachments/chain-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Отвязка: запрос формируется и передаётся без жёсткой привязки к конкретному объекту/методу.
    - Динамика: можно динамически формировать список обработчиков (добавлять/убирать).
    - Расширяемость данных: запрос может видоизменяться, "обрастать" информацией по мере прохождения цепочки.
    - Удобство реализации: собственный контейнер и интерфейс под нужные операции.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Запрос может не выполниться (никто из обработчиков его не обработает).
    - Результат зависит от порядка обработки (изменение порядка может менять поведение/итог).
]

=== Пример

```cpp
#include <initializer_list>
#include <iostream>
#include <memory>

using namespace std;

class AbstractHandler
{
    using PtrAbstractHandler = shared_ptr<AbstractHandler>;

  protected:
    PtrAbstractHandler next;

    virtual bool run() = 0;

  public:
    using Default = shared_ptr<AbstractHandler>;

    virtual ~AbstractHandler() = default;

    virtual bool handle() = 0;

    void add(PtrAbstractHandler node);
    void add(initializer_list<PtrAbstractHandler> list);
};

class ConHandler : public AbstractHandler
{
  private:
    bool condition{false};

  protected:
    bool run() override
    {
        cout << "Method run;\n";
        return true;
    }

  public:
    ConHandler() : ConHandler(false) {}
    ConHandler(bool c) : condition(c) { cout << "Constructor;\n"; }
    ~ConHandler() override { cout << "Destructor;\n"; }

    bool handle() override
    {
        if (!condition) {
            return next ? next->handle() : false;
        }

        return run();
    }
};

void AbstractHandler::add(PtrAbstractHandler node)
{
    if (next) {
        next->add(node);
    } else {
        next = node;
    }
}

void AbstractHandler::add(initializer_list<PtrAbstractHandler> list)
{
    for (auto elem : list) {
        add(elem);
    }
}

int main()
{
    shared_ptr<AbstractHandler> chain = make_shared<ConHandler>();

    chain->add({
            make_shared<ConHandler>(false),
            make_shared<ConHandler>(true),
            make_shared<ConHandler>(true)
            });

    cout << boolalpha << "Result = " << chain->handle() << ";\n";
}
```

== Подписчик-издатель (Publish-Subscribe)

=== Основная идея

Есть два класса~--- издатель и подписчик. Подписчик может подписываться на какие-то события или данные от издателя..

=== Принцип работы

Чтобы получать информацию (например, журнал), нужно "подписаться"~--- предоставить о себе информацию издателю. Издатель должен держать у себя пару: объект и метод, который нужно вызвать у этого подписчика.

=== Реализация подписки

- Есть специальный метод (например, `subscribe`), которым подписчик передаёт издателю свои данные, чтобы получать уведомления о событиях.
- Издатель может уведомлять много подписчиков. Для этого он вызывает нужный метод у каждого подписчика.
- Подписка может быть реализована через абстрактный или конкретный класс подписчика.

=== Ссылки и жизненный цикл объектов

Издатель может держать умный указатель (`weak_ptr` или `shared_ptr`) на подписчика, чтобы отслеживать его существование и избежать утечек памяти. Если подписчику больше не нужно событие~--- он должен явно отписаться (`unsubscribe`).

=== Возможные кольцевые зависимости

Если подписчик одновременно становится издателем (и наоборот), могут образоваться кольца~--- большое количество объектов взаимно ссылаются друг на друга. Это приводит к потенциальным утечкам памяти.

=== Проблема со списками подписчиков

Каждый издатель должен держать список пар (объект + метод). Если множество объектов и связей между ними, список становится очень большим, что приводит к неудобствам разработки и эксплуатации.

#image("attachments/publisher-subscriber-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Позволяет легко масштабировать систему по числу подписчиков и событий.
    - Подходит для построения асинхронных и событийных систем.
    - Каждый подписчик и издатель могут быть реализованы независимо.
    - Возможна динамическая подписка/отписка~--- подписчики могут появляться и исчезать во время выполнения программы.
]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Кольцевые ссылки (когда подписчики и издатели ссылаются друг на друга) могут привести к утечкам памяти (особенно при использовании `shared_ptr`).
    - Каждый издатель вынужден держать у себя список объектов и методов~--- это расход памяти, рост сложности.
    - Если не реализовать правильно механизм отписки, подписчик может получать уведомления даже тогда, когда это больше не нужно.
]

=== Пример

```cpp
#include <iostream>
#include <memory>
#include <vector>

using namespace std;

class Subscriber;

using Receiver = Subscriber;

class Publisher
{
    using Action = void (Receiver::*)();
    using Pair = pair<shared_ptr<Receiver>, Action>;

  private:
    vector<Pair> callback;

    int indexOf(shared_ptr<Receiver> r);

  public:
    bool subscribe(shared_ptr<Receiver> r, Action a);
    bool unsubscribe(shared_ptr<Receiver> r);
    void run();
};

class Subscriber
{
  public:
    virtual ~Subscriber() = default;

    virtual void method() = 0;
};

class ConSubscriber : public Subscriber
{
  public:
    void method() override { cout << "method;\n"; }
};

bool Publisher::subscribe(shared_ptr<Receiver> r, Action a)
{
    if (indexOf(r) != -1) {
        return false;
    }

    Pair pr(r, a);
    callback.push_back(pr);

    return true;
}

bool Publisher::unsubscribe(shared_ptr<Receiver> r)
{
    int pos = indexOf(r);
    if (pos != -1) {
        callback.erase(callback.begin() + pos);
    }

    return pos != -1;
}

void Publisher::run()
{
    cout << "Run:\n";
    for (auto& elem : callback) {
        ((*elem.first).*(elem.second))();
    }
}

int Publisher::indexOf(shared_ptr<Receiver> r)
{
    int i = 0;
    for (auto it = callback.begin(); it != callback.end() && r != (*it).first; i++, ++it) {}

    return i < callback.size() ? i : -1;
}

int main()
{
    shared_ptr<Subscriber> subscriber1 = make_shared<ConSubscriber>();
    shared_ptr<Subscriber> subscriber2 = make_shared<ConSubscriber>();
    shared_ptr<Publisher> publisher = make_shared<Publisher>();

    publisher->subscribe(subscriber1, &Subscriber::method);
    if (publisher->subscribe(subscriber2, &Subscriber::method)) {
        publisher->unsubscribe(subscriber1);
    }

    publisher->run();
}
```

== Посредник (Mediator)

=== Идея паттерна "Посредник"

- Все эти связи подписчик-издатель вынести на один объект. Этот объект будет держать все связи, все списки, а объекты будут взаимодействовать только с ним. Соответственно, объекты не держат списков подписчиков или обработчиков~--- у них связь только с посредником, а посредник, получив сообщение/запрос, решает, кому его отправить.
- Мы разрываем кольцо связей между объектами, у нас один объект-посредник, который знает обо всех, а остальные объекты знают только о посреднике.

=== Что делает посредник

- Объекты подписываются на посредника, чтобы отправлять запросы.
- Посредник хранит информацию о том, кому и какое сообщение нужно передать.
- Посредник реализует метод, который получает запрос/сообщение и решает, кому его перенаправить.

=== Возможны проблемы

- У посредника может быть достаточно сложная логика, ведь теперь он отвечает за правильную маршрутизацию запросов.
- Всё равно необходим некий список (например, кто от кого может принимать запросы), и требуется следить за тем, существуют ли нужные объекты.
- Проблем, связанных с замыканиями и утечками памяти, как у подписчика-издателя, здесь уже нет, поскольку нет замкнутых ссылок.
- Посредник~--- это решение проблемы жёсткой связанности и кольцевых ссылок. Но за это приходится платить повышенной сложностью объекта-посредника, который теперь должен знать всю логику пересылки сообщений между объектами.

#image("attachments/mediator-uml.png")

=== Преимущества

#[
    #set list(marker: [#text(fill: green, weight: "extrabold")[+]])
    - Разорваны "кольца" ссылок между объектами~--- нет прямых или взаимных ссылок между всеми элементами системы.
    - Все управляющие списки сосредоточены в одном месте.
    - Нет проблем с утечкой памяти, характерных для схем подписчик-издатель.

]

=== Недостатки

#[
    #set list(marker: [#text(fill: red, weight: "extrabold")[#sym.minus]])
    - Сложная логика внутри посредника, он становится "узким местом", т.к. должен реализовать все маршруты обмена.
    - При больших иерархиях объектов количество логики и связей в посреднике становится большим, это затрудняет сопровождение системы.
]

=== Пример

```cpp
#include <iostream>
#include <list>
#include <memory>

using namespace std;

class Message
{
}; // Request

class Mediator;

class Colleague
{
  private:
    weak_ptr<Mediator> mediator;

  public:
    virtual ~Colleague() = default;

    void setMediator(shared_ptr<Mediator> mdr) { mediator = mdr; }

    virtual bool send(shared_ptr<Message> msg);
    virtual void receive(shared_ptr<Message> msg) = 0;
};

class ColleagueLeft : public Colleague
{
  public:
    void receive(shared_ptr<Message> msg) override { cout << "Right - > Left;" << endl; }
};

class ColleagueRight : public Colleague
{
  public:
    void receive(shared_ptr<Message> msg) override { cout << "Left - > Right;" << endl; }
};

class Mediator
{
  protected:
    list<shared_ptr<Colleague>> colleagues;

  public:
    virtual ~Mediator() = default;

    virtual bool send(const Colleague* coleague, shared_ptr<Message> msg) = 0;

    static bool add(shared_ptr<Mediator> mediator, initializer_list<shared_ptr<Colleague>> list);
};

class ConMediator : public Mediator
{
  public:
    bool send(const Colleague* coleague, shared_ptr<Message> msg) override;
};

bool Colleague::send(shared_ptr<Message> msg)
{
    shared_ptr<Mediator> mdr = mediator.lock();

    return mdr ? mdr->send(this, msg) : false;
}

bool Mediator::add(shared_ptr<Mediator> mediator, initializer_list<shared_ptr<Colleague>> list)
{
    if (!mediator || list.size() == 0) {
        return false;
    }

    for (auto elem : list) {
        mediator->colleagues.push_back(elem);
        elem->setMediator(mediator);
    }

    return true;
}

bool ConMediator::send(const Colleague* colleague, shared_ptr<Message> msg)
{
    bool flag = false;
    for (auto&& elem : colleagues) {
        if (dynamic_cast<const ColleagueLeft*>(colleague) && dynamic_cast<ColleagueRight*>(elem.get())) {
            elem->receive(msg);
            flag = true;
        } else if (dynamic_cast<const ColleagueRight*>(colleague) && dynamic_cast<ColleagueLeft*>(elem.get())) {
            elem->receive(msg);
            flag = true;
        }
    }

    return flag;
}

int main()
{
    shared_ptr<Mediator> mediator = make_shared<ConMediator>();

    shared_ptr<Colleague> col1 = make_shared<ColleagueLeft>();
    shared_ptr<Colleague> col2 = make_shared<ColleagueRight>();
    shared_ptr<Colleague> col3 = make_shared<ColleagueLeft>();
    shared_ptr<Colleague> col4 = make_shared<ColleagueLeft>();

    Mediator::add(mediator, {col1, col2, col3, col4});

    shared_ptr<Message> msg = make_shared<Message>();

    col1->send(msg);
    col2->send(msg);
}
```
