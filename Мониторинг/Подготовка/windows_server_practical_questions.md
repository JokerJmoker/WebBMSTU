```markdown
# Практический конспект по Windows Server

## Содержание

1. Базовые модули и объекты в Windows Server
2. LDAP-запросы
3. Работа с параметрами через CMD и PowerShell: валидация и синтаксис
4. Создание пользователей, групп и управление членством (локальные и доменные)
5. Локальные, групповые и доменные политики
6. Журналы Windows Server: где какие логи находятся
7. Где какие записи появляются: привязка событий к действиям
8. Сводная практическая схема
9. Команды для практической работы
10. Что нужно уметь объяснить на защите
11. Минимальный сценарий практической демонстрации

---

# 1. Базовые модули и объекты в Windows Server

## 1.1. Что такое модуль в PowerShell

**Модуль** — это пакет командлетов, функций, переменных и других элементов, объединённых по функциональному признаку.

Основные команды для работы с модулями:

| Задача | Команда |
|---|---|
| Загруженные модули | `Get-Module` |
| Все установленные модули | `Get-Module -ListAvailable` |
| Командлеты в модуле | `Get-Command -Module <Имя>` |
| Загрузить модуль | `Import-Module <Имя>` |

Примеры:

```powershell
Get-Module -ListAvailable
Get-Module -ListAvailable -Name ActiveDirectory
Get-Module -ListAvailable *AD*
Import-Module ActiveDirectory
```

## 1.2. Ключевые модули Windows Server

| Модуль | Назначение |
|---|---|
| `Microsoft.PowerShell.Management` | Управление системой: процессы, службы, файлы |
| `Microsoft.PowerShell.Core` | Ядро PowerShell: модули, команды, справка |
| `ActiveDirectory` | Работа с объектами AD: пользователи, группы, компьютеры |
| `GroupPolicy` | Работа с GPO |
| `LocalAccounts` | Локальные пользователи и группы |
| `NetTCPIP` | Сетевые настройки TCP/IP |
| `SmbShare` | Сетевые ресурсы |
| `DnsServer` | Управление DNS |
| `DhcpServer` | Управление DHCP |

## 1.3. Командлет (Cmdlet)

**Командлет** — это лёгкая команда PowerShell, написанная на .NET (обычно на C#), которая выполняет одну конкретную функцию. Она подчиняется строгому правилу именования: **`Глагол-Существительное`** (Verb-Noun).

Примеры:
- `Get-Process` — получить процессы
- `Get-Module` — получить модули
- `Get-ADUser` — получить пользователя AD
- `New-ADUser` — создать пользователя AD
- `Remove-Item` — удалить элемент

## 1.4. Одобренные глаголы (Approved Verbs)

Список рекомендованных глаголов определён Microsoft. Его можно посмотреть командой:

```powershell
Get-Verb
```

Эта команда вернёт таблицу всех одобренных глаголов с группировкой по категориям:

| Глагол | Категория | Что делает |
|---|---|---|
| `Get` | Common | Получить данные |
| `Set` | Common | Изменить данные |
| `New` | Common | Создать новый объект |
| `Remove` | Common | Удалить объект |
| `Start` | Lifecycle | Запустить |
| `Stop` | Lifecycle | Остановить |
| `Restart` | Lifecycle | Перезапустить |
| `Add` | Common | Добавить |
| `Clear` | Common | Очистить |
| `Enable` | Lifecycle | Включить |
| `Disable` | Lifecycle | Отключить |
| `Import` | Data | Импортировать |
| `Export` | Data | Экспортировать |
| `Test` | Diagnostic | Проверить |
| `Measure` | Diagnostic | Измерить |
| `Select` | Common | Выбрать |
| `Where` | Common | Отфильтровать |
| `ForEach` | Common | Обработать каждый |

Полный список — около 100 глаголов, сгруппированных по категориям: Common, Communications, Data, Diagnostic, Lifecycle, Security, Other.

## 1.5. Объекты Active Directory

В AD хранятся объекты, например:

- пользователь;
- группа;
- компьютер;
- организационное подразделение (OU);
- объект групповой политики и другие объекты каталога.

Пример структуры:

```text
DC=toros,DC=local
|
+-- OU=Users
|   +-- CN=aboba
|   +-- CN=admin
|
+-- OU=Computers
|   +-- CN=WIN10
|
+-- OU=Groups
    +-- CN=Students
```

## 1.6. DN — Distinguished Name

Каждый объект AD имеет уникальное Distinguished Name (DN).

Пример:

```text
CN=aboba,OU=Users,DC=toros,DC=local
```

Обозначения:

- `CN` — Common Name;
- `OU` — Organizational Unit;
- `DC` — Domain Component.

DN описывает положение объекта в иерархии каталога.

## 1.7. Базовые команды для исследования

| Что нужно | Команда |
|---|---|
| Все глаголы | `Get-Verb` |
| Все команды с глаголом `Get` | `Get-Command -Verb Get` |
| Все команды с существительным `ADUser` | `Get-Command -Noun ADUser` |
| Все командлеты в модуле | `Get-Command -Module <Имя>` |
| Тип объекта | `<команда> \| Get-Member` |
| Синтаксис команды | `Get-Command <Имя> -Syntax` |
| Справка | `Get-Help <Имя> -Full` |

Примеры:

```powershell
Get-Command -Verb Get
Get-Command -Noun *User*
Get-Command -Noun *Process*
Get-Command -Noun AD*
Get-Command -CommandType Cmdlet
Show-Command
```

## 1.8. Как найти нужную команду, если забыл

**1. Найти все команды в конкретном модуле:**

```powershell
Get-Command -Module ActiveDirectory
```

**2. Найти команды по началу названия:**

```powershell
Get-Command -Noun AD*
Get-Command Get-AD*
```

**3. Найти команды по конкретному параметру:**

```powershell
Get-Command -ParameterName *Auth*
```

**4. Показать синтаксис команды:**

```powershell
Get-Command Get-ADUser -Syntax
```

**5. Получить полную справку:**

```powershell
Get-Help Get-ADUser -Full
Get-Help Get-ADUser -Examples
```

**6. Встроенная справка по фильтрам AD:**

```powershell
Get-Help about_ActiveDirectory_Filter
```

## 1.9. Типы объектов

Узнать тип возвращаемого объекта:

```powershell
Get-Process | Get-Member
Get-Module | Get-Member
Get-ADUser aboba | Get-Member
```

| Команда | Модуль | Тип объекта |
|---|---|---|
| `Get-Process` | `Microsoft.PowerShell.Management` | `System.Diagnostics.Process` |
| `Get-Module` | `Microsoft.PowerShell.Core` | `System.Management.Automation.PSModuleInfo` |
| `Get-ADUser` | `ActiveDirectory` | `Microsoft.ActiveDirectory.Management.ADUser` |
| `Get-ChildItem` | `Microsoft.PowerShell.Management` | `System.IO.FileInfo` / `DirectoryInfo` |

---

# 2. LDAP-запросы

## 2.1. Что такое LDAP

LDAP (Lightweight Directory Access Protocol) — протокол доступа к службам каталогов.

В Windows Server LDAP используется прежде всего для обращения к Active Directory Domain Services (AD DS).

Важно различать:

- **Active Directory** — служба каталога, хранящая объекты домена;
- **LDAP** — протокол, через который можно обращаться к каталогу;
- **Domain Controller (DC)** — сервер, на котором работает AD DS и который обслуживает домен.

Упрощённо:

```text
Клиент
   |
   | LDAP-запрос
   v
Domain Controller
   |
   v
Active Directory
   |
   +-- Users
   +-- Groups
   +-- Computers
   +-- OUs
```

### Порты LDAP

| Порт | Назначение |
|---|---|
| `389/tcp` | LDAP |
| `636/tcp` | LDAPS (LDAP over SSL) |
| `3268/tcp` | Global Catalog LDAP |
| `3269/tcp` | Global Catalog LDAPS |

## 2.2. LDAP-фильтры

LDAP-запрос может использовать фильтр поиска.

Поиск пользователя:

```text
(&(objectClass=user)(sAMAccountName=aboba))
```

Здесь:

- `&` — логическое AND;
- `objectClass=user` — объект является пользователем;
- `sAMAccountName=aboba` — имя пользователя `aboba`.

Поиск групп:

```text
(objectClass=group)
```

Поиск компьютеров:

```text
(objectClass=computer)
```

Поиск объектов категории person:

```text
(objectCategory=person)
```

Поиск отключённых пользователей (побитовое сравнение):

```text
(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))
```

## 2.3. Атрибуты объектов

Объект AD состоит из атрибутов. Для пользователя можно встретить:

```text
cn
distinguishedName
objectClass
objectGUID
sAMAccountName
userPrincipalName
memberOf
whenCreated
whenChanged
```

Например:

```text
sAMAccountName = aboba
userPrincipalName = aboba@toros.local
```

## 2.4. Из чего состоит LDAP-запрос на поиск

LDAP-запрос на поиск (SearchRequest) — это структурированное сообщение, которое клиент отправляет серверу каталога. Оно включает следующие обязательные элементы:

| Элемент | Назначение | Пример |
|---|---|---|
| **baseObject** | База поиска — точка в дереве каталога, откуда начинается поиск (DN) | `DC=domain,DC=local` |
| **scope** | Глубина поиска: `baseObject`, `singleLevel`, `wholeSubtree` | `wholeSubtree` |
| **derefAliases** | Политика обработки алиасов | `neverDerefAliases` |
| **sizeLimit** | Максимальное число возвращаемых записей (0 — без ограничений) | 0 |
| **timeLimit** | Максимальное время выполнения запроса в секундах | 0 |
| **typesOnly** | Флаг: только имена атрибутов или имена + значения | `false` |
| **filter** | Критерий отбора записей (логическое выражение) | `(objectClass=user)` |
| **attributes** | Список атрибутов для возврата | пусто или конкретные поля |

## 2.5. Как это работает на практике

1. **Клиент** формирует LDAP-сообщение `SearchRequest` с указанными параметрами.
2. **Клиент подключается** к контроллеру домена (LDAP-порт 389 или 636) и отправляет запрос.
3. **Сервер AD** выполняет поиск в своей базе данных, применяя фильтр к записям в указанной области.
4. **Сервер возвращает** поток результатов:
   - `SearchResultEntry` — по одной на каждую найденную запись (содержит DN и запрошенные атрибуты)
   - `SearchResultDone` — финальное сообщение о завершении поиска

## 2.6. Где выполняются LDAP-запросы

LDAP-запросы выполняются на любой клиентской машине или сервере, который может установить сетевое соединение с контроллером домена. Это не обязательно должен быть сам контроллер домена — достаточно, чтобы с рабочей станции был доступ к портам LDAP.

**Инструменты для выполнения LDAP-запросов:**

| Инструмент | Тип | Описание |
|---|---|---|
| **LDP.exe** | GUI | Легковесный графический клиент от Microsoft для диагностики и проверки соединения |
| **ADSI Edit** | GUI (MMC) | Просмотр и редактирование атрибутов объектов AD |
| **AD Explorer** | GUI (Sysinternals) | Продвинутая навигация по AD, создание снимков состояния |
| **dsquery** | CMD | Утилита командной строки с упрощённым синтаксисом фильтров |
| **ldapsearch** | CLI | Классическая консольная утилита из мира Unix |
| **Get-ADObject** | PowerShell | Командлет модуля ActiveDirectory |
| **DirectorySearcher** | .NET | Класс для прямого выполнения LDAP-запросов в скриптах |

---

# 3. Работа с параметрами через CMD и PowerShell: валидация и синтаксис

## 3.1. CMD

`cmd.exe` — классическая командная оболочка Windows.

Она используется для:

- запуска системных утилит;
- выполнения команд;
- запуска `.bat` и `.cmd` файлов;
- администрирования через традиционные консольные программы.

Примеры:

```cmd
ipconfig
ping 10.74.16.1
hostname
whoami
systeminfo
tasklist
netstat -ano
```

### Валидация параметров в CMD

В CMD нет встроенной системы валидации. Проверка корректности выполняется:

- самими утилитами (выводят ошибку при неверном синтаксисе);
- вручную через `if errorlevel` в batch-скриптах.

Пример:

```cmd
net user student Password123 /add
if %errorlevel% neq 0 (
    echo Ошибка создания пользователя
)
```

## 3.2. PowerShell

PowerShell — командная оболочка и язык автоматизации.

Ключевое отличие:

```text
CMD        -> преимущественно текстовый вывод
PowerShell -> объекты .NET/PowerShell
```

Например:

```powershell
Get-Process
```

возвращает объекты процессов, которые можно передавать по конвейеру:

```powershell
Get-Process | Where-Object {$_.CPU -gt 100}
```

Схема:

```text
Get-Process
     |
     v
объекты процессов
     |
     v
Where-Object
     |
     v
отфильтрованные объекты
```

### Валидация параметров в PowerShell

PowerShell проверяет параметры автоматически:

- типы данных (строка, число, массив);
- обязательность параметров;
- допустимые значения (ValidateSet);
- диапазоны (ValidateRange).

Пример ошибки при неверном параметре:

```powershell
Get-ADUser aboba -Properties
# Ошибка: Missing an argument for parameter 'Properties'
```

Правильно:

```powershell
Get-ADUser aboba -Properties *
Get-ADUser aboba -Properties Department, Title
```

### Основные операторы сравнения

| Оператор | Значение |
|---|---|
| `-eq` | равно |
| `-ne` | не равно |
| `-gt` | больше |
| `-lt` | меньше |
| `-ge` | больше или равно |
| `-le` | меньше или равно |
| `-like` | соответствует шаблону |
| `-match` | соответствует регулярному выражению |
| `-contains` | содержит |

### Условные конструкции

```powershell
if ($User.Enabled -eq $true) {
    Write-Host "Пользователь включён"
} else {
    Write-Host "Пользователь отключён"
}
```

### Циклы

```powershell
foreach ($user in Get-ADUser -Filter *) {
    Write-Host $user.SamAccountName
}
```

### Конвейер (Pipeline)

**Конвейер** — это механизм передачи объектов от одной команды к другой. Символ `|` (pipe) разделяет команды.

```powershell
Get-Process | Where-Object {$_.CPU -gt 100} | Sort-Object CPU -Descending | Select-Object -First 10
```

### Переменные

Переменные в PowerShell начинаются с символа `$`:

```powershell
$User = Get-ADUser aboba
$User.SamAccountName
$User.Name
```

### Форматирование вывода

```powershell
Get-ADUser aboba -Properties * | Format-List *
Get-Process | Format-Table Name, CPU, Memory -AutoSize
Get-Service | Select-Object Name, Status, DisplayName
```

## 3.3. Сравнение команд CMD и PowerShell

| Задача | CMD | PowerShell |
|---|---|---|
| IP-адреса | `ipconfig` | `Get-NetIPAddress` |
| Процессы | `tasklist` | `Get-Process` |
| Службы | `sc query` | `Get-Service` |
| Локальные пользователи | `net user` | `Get-LocalUser` |
| Локальные группы | `net localgroup` | `Get-LocalGroup` |
| Сетевые соединения | `netstat -ano` | `Get-NetTCPConnection` |
| Имя компьютера | `hostname` | `$env:COMPUTERNAME` |
| Сведения о системе | `systeminfo` | `Get-ComputerInfo` |

---

# 4. Создание пользователей, групп и управление членством (локальные и доменные)

## 4.1. Локальные и доменные учётные записи

Это принципиально важно.

```text
Локальная учётная запись
        |
        v
Локальная база SAM

Доменная учётная запись
        |
        v
Active Directory
```

`net user` без дополнительных параметров показывает локальных пользователей.

```cmd
net user
```

PowerShell:

```powershell
Get-LocalUser
```

Для доменных пользователей используется модуль Active Directory:

```powershell
Get-ADUser -Filter *
```

## 4.2. Создание локального пользователя через CMD

```cmd
net user student Password123 /add
```

Проверка:

```cmd
net user student
```

Удаление:

```cmd
net user student /delete
```

Создание локальной группы:

```cmd
net localgroup Students /add
```

Добавление пользователя:

```cmd
net localgroup Students student /add
```

## 4.3. Создание локального пользователя через PowerShell

```powershell
$Password = Read-Host -AsSecureString

New-LocalUser `
    -Name "student" `
    -Password $Password
```

Получить пользователей:

```powershell
Get-LocalUser
```

Получить группы:

```powershell
Get-LocalGroup
```

Добавить пользователя в группу:

```powershell
Add-LocalGroupMember `
    -Group "Students" `
    -Member "student"
```

## 4.4. Создание доменного пользователя

После установки роли AD DS можно создавать доменные учётные записи через PowerShell.

```powershell
$Password = Read-Host -AsSecureString

New-ADUser `
    -Name "Ivan Ivanov" `
    -SamAccountName "ivanov" `
    -UserPrincipalName "ivanov@toros.local" `
    -AccountPassword $Password `
    -Enabled $true
```

Добавление в группу:

```powershell
Add-ADGroupMember `
    -Identity "Students" `
    -Members "ivanov"
```

Проверка:

```powershell
Get-ADUser ivanov
```

Группы пользователя:

```powershell
Get-ADPrincipalGroupMembership ivanov
```

### Добавление доменного пользователя в группу через CMD

```cmd
net group "Students" ivanov /add /domain
```

Проверка участников:

```cmd
net group "Students" /domain
```

## 4.5. Создание домена

Установка роли AD DS:

```powershell
Install-WindowsFeature AD-Domain-Services
```

Создание нового леса, например:

```powershell
Install-ADDSForest -DomainName "toros.local"
```

После настройки сервер становится контроллером домена.

```text
Windows Server
      |
      v
AD DS
      |
      v
Domain Controller
      |
      v
toros.local
      |
      +-- Users
      +-- Groups
      +-- Computers
      +-- OUs
```

## 4.6. Просмотр созданных групп

### Локальные группы

**CMD:**

```cmd
net localgroup
net localgroup Students
```

**PowerShell:**

```powershell
Get-LocalGroup
Get-LocalGroupMember -Group "Students"
```

### Доменные группы

**CMD:**

```cmd
net group /domain
net group "Students" /domain
```

**PowerShell:**

```powershell
Get-ADGroup -Filter *
Get-ADGroup -Identity "Students"
Get-ADGroupMember -Identity "Students"
Get-ADPrincipalGroupMembership -Identity aboba
```

### Сводная таблица

| Что нужно | CMD | PowerShell |
|---|---|---|
| Локальные группы | `net localgroup` | `Get-LocalGroup` |
| Участники локальной группы | `net localgroup Students` | `Get-LocalGroupMember -Group "Students"` |
| Доменные группы | `net group /domain` | `Get-ADGroup -Filter *` |
| Участники доменной группы | `net group "Students" /domain` | `Get-ADGroupMember -Identity "Students"` |
| Группы пользователя | — | `Get-ADPrincipalGroupMembership aboba` |

## 4.7. Где возникают логи при работе с пользователями

Изменения Active Directory при соответствующем аудите фиксируются прежде всего на Domain Controller в:

```text
Event Viewer
  -> Windows Logs
     -> Security
```

Важные события:

| Event ID | Значение |
|---:|---|
| 4720 | Создана учётная запись пользователя |
| 4722 | Учётная запись включена |
| 4723 | Попытка изменения собственного пароля |
| 4724 | Попытка сброса пароля |
| 4725 | Учётная запись отключена |
| 4726 | Пользователь удалён |
| 4738 | Учётная запись изменена |
| 4727 | Создана группа |
| 4728 | Пользователь добавлен в глобальную группу |
| 4732 | Пользователь добавлен в локальную группу |
| 4740 | Учётная запись заблокирована |

Фактическая регистрация событий зависит от настроек политики аудита.

---

# 5. Локальные, групповые и доменные политики

## 5.1. Что такое GPO

GPO (Group Policy Object) — объект групповой политики.

GPO используется для централизованной настройки:

- компьютеров;
- пользователей;
- безопасности;
- программ;
- служб;
- рабочего окружения;
- ограничений;
- скриптов.

Пример:

```text
Domain
 |
 +-- OU=Students
     |
     +-- User1
     +-- User2
     +-- Computer1

GPO "Students Policy"
          |
          v
     OU=Students
```

## 5.2. Уровни политик

```text
Локальные политики
        |
        v
Политики сайта
        |
        v
Политики домена
        |
        v
Политики OU
```

Порядок применения: **Local → Site → Domain → OU**. Последняя применённая политика имеет приоритет.

## 5.3. Основные разделы GPO

```text
GPO
+-- Computer Configuration
+-- User Configuration
```

### Computer Configuration

Настройки, применяемые к компьютеру.

Например:

```text
Computer Configuration
+-- Policies
    +-- Windows Settings
    +-- Administrative Templates
```

### User Configuration

Настройки, применяемые к пользователю:

```text
User Configuration
+-- Policies
    +-- Windows Settings
    +-- Administrative Templates
```

## 5.4. Свойства GPO

GPO имеет:

- Display Name;
- GUID;
- владельца;
- разрешения доступа;
- Computer Configuration;
- User Configuration;
- связи с доменом, сайтом или OU;
- состояние GPO.

Пример GUID:

```text
{6AC1786C-016F-11D2-945F-00C04FB984F9}
```

### Ключевые атрибуты GPO

| Атрибут | Описание |
|---|---|
| `gPCFileSysPath` | Путь к файлам GPO в SYSVOL |
| `gPCMachineExtensionNames` | Список CSE-расширений для компьютеров |
| `gPCUserExtensionNames` | Список CSE-расширений для пользователей |
| `versionNumber` | Версия GPO |

## 5.5. Где хранится GPO

GPO состоит из двух связанных частей:

1. объекта в Active Directory;
2. файловой части в SYSVOL.

Упрощённо:

```text
Active Directory
      |
      +-- объект GPO
              |
              +-- GUID

SYSVOL
      |
      +-- Policies
              |
              +-- {GUID}
```

Поэтому GPO нельзя рассматривать только как один файл.

## 5.6. Просмотр GPO

Графический инструмент:

```cmd
gpmc.msc
```

PowerShell:

```powershell
Get-GPO -All
```

Конкретная политика:

```powershell
Get-GPO -Name "Default Domain Policy"
```

Применённые политики:

```cmd
gpresult /r
```

Подробный HTML-отчёт:

```cmd
gpresult /h report.html
```

## 5.7. AppLocker

AppLocker — это механизм контроля приложений в Windows, который позволяет администратору определять, какие программы, скрипты и установщики разрешено запускать на компьютере.

**Основная задача:** реализация подхода «белого списка» (allowlist). Разрешаются только доверенные приложения, всё остальное блокируется.

**Что можно контролировать (коллекции правил):**

| Коллекция | Типы файлов |
|---|---|
| Исполняемые файлы | `.exe`, `.com` |
| Скрипты | `.ps1`, `.bat`, `.cmd`, `.vbs`, `.js` |
| Установщики Windows | `.msi`, `.msp`, `.mst` |
| Упакованные приложения | `.appx`, `.msix` |
| Библиотеки DLL | `.dll`, `.ocx` (по умолчанию отключено) |

**На чём основываются правила:**

1. **Издатель (Publisher)** — по цифровой подписи разработчика.
2. **Путь (Path)** — по расположению файла.
3. **Хеш файла (File Hash)** — по уникальному отпечатку.

**Режимы работы:**

- **Только аудит (Audit-only)** — приложения запускаются, но события записываются в журнал.
- **Принудительно (Enforce)** — правила реально блокируют запуск.

AppLocker доступен в редакциях Windows Enterprise, Ultimate и Windows Server.

---

# 6. Журналы Windows Server: где какие логи находятся

## 6.1. Сколько журналов в Windows

Нельзя корректно назвать одно фиксированное число журналов для любого Windows Server.

Есть стандартные журналы, а также большое количество специализированных журналов компонентов.

В Event Viewer основные категории находятся здесь:

```text
Event Viewer
  -> Windows Logs
```

Стандартно здесь можно встретить:

- Application;
- Security;
- Setup;
- System;
- Forwarded Events.

Кроме них существуют:

```text
Applications and Services Logs
```

где находятся специализированные каналы отдельных компонентов.

Поэтому ответ на вопрос «сколько журналов?» должен быть сформулирован так:

> В Windows Server нет единственного фиксированного небольшого количества журналов. Есть несколько основных журналов Windows и множество дополнительных журналов и каналов событий для отдельных компонентов.

На типичном Windows Server можно увидеть **300+ зарегистрированных log-провайдеров**.

### Просмотр списка всех журналов

**PowerShell (рекомендуемый способ):**

```powershell
Get-WinEvent -ListLog * |
    Select-Object LogName, RecordCount, IsEnabled |
    Sort-Object LogName
```

**Проверка конкретного журнала:**

```powershell
Get-WinEvent -ListLog Security |
    Select-Object LogName, RecordCount, MaximumSizeInBytes
```

## 6.2. Application

Журнал приложений.

Может содержать:

- ошибки программ;
- предупреждения;
- события приложений;
- события отдельных программных компонентов.

## 6.3. Security

Основной журнал для событий безопасности и аудита.

Может содержать:

- успешные входы;
- неуспешные входы;
- создание пользователей;
- удаление пользователей;
- изменение учётных записей;
- изменение групп;
- блокировки;
- создание процессов.

Важные события:

```text
4624 — успешный вход
4625 — неуспешный вход
4688 — создание процесса
4720 — создание пользователя
4726 — удаление пользователя
4738 — изменение пользователя
4740 — блокировка пользователя
```

## 6.4. System

Журнал работы компонентов операционной системы.

Может содержать события:

- служб;
- драйверов;
- оборудования;
- загрузки;
- системных ошибок.

## 6.5. Setup

События установки и настройки Windows и её компонентов.

## 6.6. Forwarded Events

События, пересланные с других компьютеров средствами централизованного сбора событий Windows.

## 6.7. Applications and Services Logs

Здесь находятся специализированные журналы компонентов Windows.

Например:

```text
Applications and Services Logs
  +-- Microsoft
      +-- Windows
          +-- PowerShell
          +-- GroupPolicy
          +-- DNS-Server
          +-- DHCP-Server
          +-- ActiveDirectory_DomainService
          +-- Windows Defender
          +-- AppLocker
          +-- другие компоненты
```

Конкретный набор каналов зависит от установленной роли Windows Server, версии ОС и включённых компонентов.

### Ключевые специализированные журналы

| Журнал | Что содержит |
|---|---|
| `PowerShell` | События выполнения PowerShell-скриптов |
| `GroupPolicy` | Применение групповых политик |
| `ActiveDirectory_DomainService` | События службы AD DS |
| `DNS-Server` | События DNS-сервера |
| `DHCP-Server` | События DHCP-сервера |
| `AppLocker` | События блокировки приложений |

---

# 7. Где какие записи появляются: привязка событий к действиям

## 7.1. Создание пользователя

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Создана учётная запись | 4720 | Security | Domain Controller |
| Учётная запись включена | 4722 | Security | Domain Controller |
| Учётная запись отключена | 4725 | Security | Domain Controller |
| Пользователь удалён | 4726 | Security | Domain Controller |
| Учётная запись изменена | 4738 | Security | Domain Controller |

## 7.2. Работа с группами

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Создана группа | 4727 | Security | Domain Controller |
| Пользователь добавлен в глобальную группу | 4728 | Security | Domain Controller |
| Пользователь добавлен в локальную группу | 4732 | Security | Domain Controller |
| Пользователь удалён из группы | 4729, 4733 | Security | Domain Controller |

## 7.3. Аутентификация

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Успешный вход | 4624 | Security | DC / рабочая станция |
| Неуспешный вход | 4625 | Security | DC / рабочая станция |
| Блокировка учётной записи | 4740 | Security | PDC Emulator |
| Разблокировка учётной записи | 4767 | Security | Domain Controller |

## 7.4. Пароли

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Попытка изменения собственного пароля | 4723 | Security | Domain Controller |
| Сброс пароля | 4724 | Security | Domain Controller |

## 7.5. Процессы

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Создание процесса | 4688 | Security | Локальный компьютер |

## 7.6. Групповые политики

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Применение GPO | Различные | GroupPolicy | Applications and Services Logs |
| Ошибка применения GPO | Различные | GroupPolicy | Applications and Services Logs |

## 7.7. AppLocker

| Действие | Event ID | Журнал | Где смотреть |
|---|---|---|---|
| Заблокирован запуск приложения | 8004 | AppLocker | Applications and Services Logs |
| Разрешён запуск приложения | 8003 | AppLocker | Applications and Services Logs |

## 7.8. Блокировка учётной записи: алгоритм расследования

```text
aboba заблокирован
       |
       v
DC -> Security -> 4740
       |
       v
Caller Computer Name = WIN10
       |
       v
WIN10 -> поиск 4625
       |
       v
анализ неуспешных попыток входа
```

### Алгоритм поиска источника блокировки

1. Найти PDC Emulator:

```powershell
netdom query fsmo
```

2. Проверить Security log на PDC для Event ID **4740**.

3. В свойствах события 4740 посмотреть **Caller Computer Name** — это машина-источник блокировки.

4. Для детализации проверить Event ID **4625** на этой машине, искать **Caller Process Name**.

### PowerShell-запрос для поиска событий блокировки

```powershell
Get-WinEvent -ComputerName $PDC `
    -FilterHashtable @{LogName='Security';Id=4740} |
    Where-Object {$_.Properties[2].Value -match $UserSID} |
    Select-Object TimeCreated,
        @{n='User';e={$_.Properties[0].Value}},
        @{n='Source';e={$_.Properties[1].Value}}
```

## 7.9. LockoutViewer

Инструменты для анализа блокировок помогают централизованно искать сведения о заблокированных учётных записях и источниках блокировки.

При практическом анализе нужно установить:

1. какая учётная запись заблокирована;
2. время блокировки;
3. какой контроллер домена зарегистрировал событие;
4. какой компьютер указан как источник;
5. какие неуспешные события аутентификации предшествовали блокировке.

Важно: LockoutViewer является инструментом анализа; первичным источником событий остаются журналы Windows на контроллерах домена и соответствующих компьютерах.

---

# 8. Сводная практическая схема

Все вопросы можно связать в одну последовательность:

```text
                       Active Directory
                              |
                +-------------+-------------+
                |             |             |
              Users         Groups       Computers
                |             |             |
                +-------------+-------------+
                              |
                            LDAP
                              |
                  +-----------+-----------+
                  |                       |
             PowerShell                 GUI
                  |                       |
             Get-ADUser               ADUC
             New-ADUser               GPMC
             Add-ADGroupMember        AD Explorer
                  |
                  v
             изменение AD
                  |
                  v
            Domain Controller
                  |
                  v
             Event Viewer
                  |
        +---------+---------+
        |         |         |
    Security   System   Application
        |
        +-- 4624 — успешный вход
        +-- 4625 — неуспешный вход
        +-- 4720 — создание пользователя
        +-- 4726 — удаление пользователя
        +-- 4738 — изменение пользователя
        +-- 4740 — блокировка
```

GPO является механизмом централизованного управления:

```text
Domain
  |
  +-- Users
  +-- Groups
  +-- Computers
  |
  +-- GPO
       |
       +-- Computer Configuration
       +-- User Configuration
```

---

# 9. Команды для практической работы

## 9.1. CMD

```cmd
hostname
whoami
ipconfig
systeminfo
tasklist
netstat -ano
net user
net user student
net localgroup
net localgroup Students
```

Создать локального пользователя:

```cmd
net user student Password123 /add
```

Создать группу:

```cmd
net localgroup Students /add
```

Добавить пользователя в локальную группу:

```cmd
net localgroup Students student /add
```

Добавить пользователя в доменную группу:

```cmd
net group "Students" student /add /domain
```

## 9.2. PowerShell — локальная система

```powershell
Get-ComputerInfo
Get-Process
Get-Service
Get-LocalUser
Get-LocalGroup
Get-NetIPAddress
Get-NetTCPConnection
```

## 9.3. PowerShell — Active Directory

```powershell
Get-ADUser -Filter *
Get-ADGroup -Filter *
Get-ADComputer -Filter *
Get-ADOrganizationalUnit -Filter *
```

Конкретный пользователь:

```powershell
Get-ADUser aboba -Properties *
```

Группы пользователя:

```powershell
Get-ADPrincipalGroupMembership aboba
```

Все GPO:

```powershell
Get-GPO -All
```

## 9.4. GPO

Открыть Group Policy Management:

```cmd
gpmc.msc
```

Посмотреть применённые политики:

```cmd
gpresult /r
```

Создать HTML-отчёт:

```cmd
gpresult /h report.html
```

## 9.5. Поиск событий через PowerShell

Успешные входы:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4624
}
```

Неуспешные входы:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4625
}
```

Блокировки:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4740
}
```

Создание пользователей:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4720
}
```

---

# 10. Что нужно уметь объяснить на защите

## Базовые модули и объекты

```text
Модуль — пакет командлетов
Командлет — команда вида Глагол-Существительное
Объект AD — пользователь, группа, компьютер, OU, GPO
DN — уникальное имя/путь объекта
```

## LDAP

```text
LDAP = протокол доступа к каталогу
AD = служба каталога
DN = уникальное имя/путь объекта
LDAP filter = условие поиска объекта
```

## CMD и PowerShell

Главное различие:

```text
CMD        -> классическая командная оболочка
PowerShell -> оболочка + язык автоматизации + объектная модель
```

Базовые конструкции PowerShell:

```text
Командлет (Cmdlet) — команда вида Глагол-Существительное
Модуль (Module) — пакет командлетов
Конвейер (Pipeline) — передача объектов через |
Переменные — $Variable
Одобренные глаголы — Get-Verb
```

## Active Directory

Нужно различать:

```text
User
Group
Computer
OU
Domain
Domain Controller
```

## GPO

Нужно знать:

```text
GPO
+-- Computer Configuration
+-- User Configuration
```

и понимать связь:

```text
GPO <-> Active Directory <-> SYSVOL
```

## Блокировка

Основное событие:

```text
4740 — Account Lockout
```

Для анализа входов:

```text
4624 — успешный вход
4625 — неуспешный вход
```

## Журналы

Основные категории:

```text
Application
Security
Setup
System
Forwarded Events
```

Дополнительно:

```text
Applications and Services Logs
```

Для практической работы с AD и безопасностью особенно важны:

```text
Security
GroupPolicy
ActiveDirectory_DomainService
PowerShell
System
AppLocker
```

---

# 11. Минимальный сценарий практической демонстрации

Для демонстрации работы Windows Server можно последовательно выполнить:

1. Проверить имя сервера:

```cmd
hostname
```

2. Проверить текущую учётную запись:

```cmd
whoami
```

3. Посмотреть локальных пользователей:

```cmd
net user
```

4. Посмотреть доменных пользователей:

```powershell
Get-ADUser -Filter *
```

5. Посмотреть группы:

```powershell
Get-ADGroup -Filter *
```

6. Посмотреть группы конкретного пользователя:

```powershell
Get-ADPrincipalGroupMembership aboba
```

7. Посмотреть GPO:

```powershell
Get-GPO -All
```

8. Посмотреть применённые политики:

```cmd
gpresult /r
```

9. Открыть Event Viewer и перейти:

```text
Windows Logs -> Security
```

10. Найти ключевые события:

```text
4624 — успешный вход
4625 — неуспешный вход
4720 — создание пользователя
4726 — удаление пользователя
4738 — изменение пользователя
4740 — блокировка пользователя
```

Таким образом, практическая работа связывает управление Active Directory, командные оболочки Windows, групповые политики и аудит событий в единую систему администрирования Windows Server.
```