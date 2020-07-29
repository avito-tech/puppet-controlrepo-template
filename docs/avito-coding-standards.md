# Puppet control repo coding standards

В статье описаны принципы, которыми должен руководствоваться разработчик Puppet кода в Авито.

Фиксируя опыт, который  был получен в Авито при работе с Puppet, они являются продолжением Coding Standards и Best Practices, использующихся в community и не противоречат им:
- [Control repo contents](https://github.com/puppetlabs/best-practices/blob/master/control-repo-contents.md)
- [Data escalation paths](https://github.com/puppetlabs/best-practices/blob/master/data-escalation-path.md)
- [Puppet control repo template](https://github.com/puppetlabs/control-repo)
- [The roles and profiles method](https://puppet.com/docs/pe/2018.1/the_roles_and_profiles_method.html)
- [Roles and profiles: A complete example](https://puppet.com/docs/pe/2017.2/r_n_p_full_example.html)

## 1. Общие принципы
### 1.1 Специфичную логику выноси в control repo

Под специфичными требованиями и логикой в данном контексте понимаются:
- требования, кототорые исходят от заказчиков инфраструктуры
- требования по интеграции с другими компонентами инфраструктуры Авито

Если код модуля решает задачу в общем виде (для лучшей переиспользуемости), то в контрол репе хранится логика, реализующая site-специфичную функциональность.

### 1.2 Мы используем паттерн roles/profiles/components

> Подробнее про использование этого паттерна можно прочитать в статьях:
> - [The roles and profiles method](https://puppet.com/docs/pe/2018.1/the_roles_and_profiles_method.html)
> - [Puppet code abstraction: profiles](https://github.com/puppetlabs/best-practices/blob/master/puppet-code-abstraction-profiles.md)
> - [Puppet code abstraction: roles](https://github.com/puppetlabs/best-practices/blob/master/puppet-code-abstraction-roles.md)

Для организации кода в control repo мы используем паттерн roles/profiles/components. Он позволяет выстроить несколько слоёв абстракции и свести более сложные интерфейсы модулей к более простым и специфичным. В конечном итоге все сводится к роли – сущности, абстрагирующей имя ноды от ей конфигурации. Подробнее про назначение ролей и профилей см. ниже в разделе Структура проекта.

Проиллюстрируем это следующим примером. Модуль k8s предоставляет огромный интерфейс, состоящий из более 100 параметров:
```
class k8s(
  String                                   $cluster_name,
  Array[String]                            $master_nodes,
  String                                   $dns_cluster_ip,
  String                                   $version,
  Stdlib::IP::Address::V4::CIDR            $pod_ip_pool,
  String                                   $service_cluster_ip_range,
  Optional[Array[String]]                  $cluster_admin_groups,
  String                                   $haproxy_dnsname,
 
  # kube-apiserver          
  Integer                                  $kube_apiserver_count,
  Integer                                  $kube_apiserver_audit_log_maxsize,
  Integer                                  $kube_apiserver_audit_log_maxage,
  String                                   $kube_apiserver_audit_log_path,
  String                                   $kube_apiserver_audit_policy_file,
  Integer                                  $kube_apiserver_secure_port,
  String                                   $kube_apiserver_token_auth_file,
  Array[String]                            $kube_apiserver_enable_admission_plugins,
  Boolean                                  $kube_apiserver_use_admission_control_config,
  Array[String]                            $kube_apiserver_authorization_mode,
# и ещё около 100 параметров
```

Эти параметры охватывают различные аспекты конфигурации кубернетес кластера. Но модуль имеет вполне разумные умолчания, которые нас устраивают. Поэтому когда мы оборачиваем его в профиль, мы оставляем только те параметры, которые нам в данные момент необходимы:

```
class profile::k8s (
    Array[String]                            $master_nodes,
    String                                   $cluster_name,
    Stdlib::IP::Address::Nosubnet            $dns_cluster_ip,
    Stdlib::IP::Address::V4::CIDR            $service_cluster_ip_range,
    Stdlib::IP::Address::V4::CIDR            $pod_ip_pool,
    Optional[Hash[String, Hash]]             $addons,
    Optional[Boolean]                        $navigator_enabled,
    Optional[Array[String]]                  $navigator_extra_clusters,
    Optional[String]                         $navigator_version,
  ) {
 
  # секреты для мастеров
  $master_secrets = [ "kube-${cluster_name}-api-s.crt",
                      "kube-${cluster_name}-api-s.key",
                      "kube-${cluster_name}-etcd-all.crt",
                      "kube-${cluster_name}-etcd-all.key",
                      "kube-${cluster_name}-etcd-api-c.crt",
```

## 2. Структура кода
### 2.1 Роли

> Best practices по ролям описаны в статье
> - [Puppet Code Abstraction - Roles](https://github.com/puppetlabs/best-practices/blob/master/puppet-code-abstraction-roles.md)

Класс контейнер, содержащий [include-like](https://puppet.com/docs/puppet/latest/lang_classes.html#include-like-behavior) объявления профилей и компонентов (модулей). Не должен содержать никакой логики и не должен принимать никаких параметров. Каждая нода должна иметь роль, причём только одну.


#### 2.1.1 Правила именования

Имя роли должно быть специфичным для той задачи, которая решается и в тоже время достаточно коротким.

> Например, если мы требуется развернуть кластер редиса для сервиса favourites, то подходящим именем для роли будет role::redis_cluster_favorites.

Другими словами имя роли должно отражать принятое и понятное в компании название для этой части инфраструктуры.

Это требование важно потому, что в ENC хранится привязка нода-роль, и понятные роли позволят сразу понимать для какой задачи используется та или иная машина.

Цитата из Puppet Code Abstraction - Roles:

> Roles shall be named generically according to machine "type" (e.g. role::application_server, role::database_server,role::middleware_host).
>
> Roles shall not be named after specific technologies (e.g. role::tomcat, role::jboss) because the specificity is in direct conflict with the purpose of "Profile" wrapper classes.

#### 2.1.2 Одна роль на ноде

Запрещается применять более одной роли на ноду.

#### 2.1.3 Используй только include

В роли можно использовать только [include-like](https://puppet.com/docs/puppet/latest/lang_classes.html#include-like-behavior) объявления. В отдельных случаях допускается условная логика, определяющая то, какой профиль применить в зависимости от фактов, таких как версия дистрибутива или имя датацентра. В общем случае таких вещей следует избегать.

#### 2.1.4 Роль может содержать модули

При условии, что модуль содержит только один публичный класс, который инклюдится в роли.

#### 2.1.5 Параметры

Роли не должны иметь входных параметров.

### 2.2 Профили
> Best practices по профилям описаны в статье
>
> - [Puppet Code Abstraction - Profiles](https://github.com/puppetlabs/best-practices/blob/master/puppet-code-abstraction-profiles)

Профиль – это абстракция, класс-обёртка над модулями, которая реализует какой то стек технологий. Может включать в себя несколько компонентов и произвольные ресурсы. Профиль реализует свой интерфейс, для того, чтобы свести сложный интерфейс модулей к более простому и специфичному.

Если такой необходимости нет допускается использовать модули прямо в роли, при условии что это не нарушает правила, описанные в разделе Роли

#### 2.2.1 Правила именования

Название профиля должно содержать имя технологии, которая в нем используется.

#### 2.2.2 Вложенные классы

Допускается использовать вложенные классы, если это улучшает читаемость. При этом, вложенные профили не допускается использовать в роли, их можно использовать только для улучшения структуры кода.

Профиль может содержать функции на Puppet или ruby.

#### 2.2.3 Параметры

> Подробнее про выбор способа передачи параметров в статье
>
> - [Hiera, data and Puppet code: your path to the right data decisions](https://puppet.com/blog/hiera-data-and-puppet-code-your-path-right-data-decisions)

Профиль владеет всеми параметрами модулей, которые он включает. Это значит, что классы из модулей не должны самостоятельно брать значения из hiera – передача параметров в модули, минуя API профилей не допускается.

Есть несколько вариантов указания параметров классов в профили: хардкод внутри профиля, вынесение в параметры профиля и lookup в hiera, формирование параметров в коде профиля. Цитата из официальной документации:

> There are three ways a profile can get the information it needs to configure component classes:
>
> If your business will always use the same value for a given parameter, hardcode it.
>
> If you can't hardcode it, try to compute it based on information you already have.
>
> Finally, if you can't compute it, look it up in your data. To reduce lookups, identify cases where multiple parameters can be derived from the answer to a single question.
>
> This is a game of trade-offs. Hardcoded parameters are the easiest to read, and also the least flexible. Putting values in your Hiera data is very flexible, but can be very difficult to read: you might have to look through a lot of files (or run a lot of lookup commands) to see what the profile is actually doing. Using conditional logic to derive a value is a middle-ground. Aim for the most readable option you can get away with.

Параметры в профили должны передаваться **только** через hiera. Иерархия hiera в control repo содержит слой roles, который определяет в какую роль передать параметры профилей.

## 3. Тестирование кода
### 3.1 Юнит тесты

Обязательны юнит тесты для всех профилей и ролей. Параметры для юнит тестов можно брать из hiera контрол репы:
```
# spec_helper.rb
module_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
c.hiera_config = File.join(module_path, 'hiera.yaml')
```