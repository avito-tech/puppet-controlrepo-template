# Шаблон Puppet control repo

В этом репозитории находится шаблон control repo, который мы в Авито используем в своей Puppet-инфраструктуре.

Выложен в ознакомительных целях к статье [«Инфраструктура как Код в Авито: уроки которые мы извлекли»](https://habr.com/ru/company/avito/blog/513008/). Разработка ведётся внутри Авито, этот репозиторий будет поддерживаться по мере возможностей.

## Структура репозитория

```
├── data                           # данные для hiera
├── Dockerfile.acceptance          # Dockerfile для тестирования Puppet кода в докере
├── docs                           # документация
│   └── avito-coding-standards.md  # Coding-standards для control repo
├── environment.conf               # настройки для работы Puppet окружений
├── Gemfile                        # ruby-зависимости для работы с проектом
├── hiera.yaml                     # конфиг файл для hiera
├── manifests
│   └── site.pp                    # здесь содержится логика применения ролей на ноды по данным из ENC
├── Puppetfile                     # здесь подключаются зависимые модули
├── Rakefile
├── README.md
├── scripts
│   └── config_version.rb          # логика генерации версии изменений (используется commit hashs)
├── site
│   ├── profile                    # профили кладутся сюда, структура директории аналогична структуре модуля
│   └── role                       # роли кладутся сюда, структура директории аналогична структуре модуля
├── spec                           # тесты (см. docs/puppet-code-testing.md)
│   ├── acceptance                 # acceptance тесты
│   ├── classes                    # юнит тесты (rspec-puppet)
│   ├── default_facts.yml          # факты для rspec-puppet
│   ├── fixtures                   # фикстуры для rspec-puppet
│   └── spec_helper.rb
├── .overcommit.yml                # настройки для overcommit (инструмент для запуска git хуков)
├── .fixtures.yml                  # фикстуры для puppet-rspec тестов
└── .kitchen.yml                   # конфигурация test-kitchen
```

## Использование шаблона в своей инфраструктуре

Для того, чтобы воспользоваться этим шаблоном в своём проекте потребуется его доработка — некоторые его части мы не стали выкладывать в opensource, т.к. они содержат вещи слишком специфичные для нашей инфраструктуры и вряд ли могут быть полезны в других проектах.

Те места, которые необходимо исправить при адаптировании шаблона в свою инфраструктуру помечены комментариями как FIXME.

### Настройка паппетсервера

Для использования шаблона в своих проектах нужно написать роль для самого паппетсервера (он также управляется паппетом), на который раскладывается этот код. Для этого неплохо подойдёт модуль [theforeman/puppet](https://forge.puppet.com/theforeman/puppet). Мы используем этот модуль у себя, написав модуль-обертку. Наш модуль устанавливает и настраивает puppetserver, доставляет ssh ключи для работы с VCS, устанавливает и настраивает компоненты для CD паппет кода. 

### Выкатка кода на паппетсервер

Из opensorce модулей для доставки кода можно воспользоваться модулем [puppet/r10k](https://forge.puppet.com/puppet/r10k). Для выкатки кода в этом модуле используется r10k и webhook, который принимает события от различных VCS и выкатывает окружения.

## Разработка control repo

Перед началом работы нужно установить все зависимости через bundler:

```
bundle install
```

### Валидация кода

Проверка синтаксиса:

```
bundle exec rake validate
```

Запуск puppet-линтера:

```
bundle exec rake lint
```

Запуск ruby-линтера:

```
bundle exec rake rubocop
```

Настройки ruby линтера находятся в .rubocop.yml

### Тестирование кода

#### Юнит-тестирование ([rspec-puppet](https://rspec-puppet.com)):

Юнит тесты находятся в директории spec/{classes, defines,functions}. Более подробно про юнит тесты можно прочитать по ссылкам:
- [Unit testing with rspec-puppet — for beginners](https://puppet.com/blog/unit-testing-rspec-puppet-for-beginners/)
- [Rspec-puppet official website](https://rspec-puppet.com/)
- [Rspec-puppet on github](https://github.com/rodjek/rspec-puppet)

Запуск юнит тестов:
```
bundle exec rake spec
```

Удаление фикстур:
```
bundle exec rake spec_clean
```

Подготовка фикстур:
```
bundle exec rake spec_prep
```

#### Acceptance тестирование ([testkitchen](https://github.com/test-kitchen/test-kitchen))

Acceptance тесты запускаются в Docker, настройки testkitchen находятся в файле .kitchen.yml.
Используется [Kitchen Puppet](https://github.com/neillturner/kitchen-puppet).

```
bundle exec kitchen test -t spec/acceptance
```

### Настройка git-хуков

Для управления git-хуками используется [overcommit](https://github.com/sds/overcommit).
Настройки git-хуков находятся в .overcommit.yml.


## См. также

[Puppet control repo coding standards](docs/avito-coding-standards.md) — стандарты кодирования для control repo в Avito
