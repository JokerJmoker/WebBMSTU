# Настройка веб-сервера Apache + PHP + PostgreSQL в WSL

## 1. Быстрый запуск через Python (для проверки)

```bash
python -m http.server 8000
# Открыть: http://localhost/WebBMSTU/
```

---

## 2. Установка необходимых пакетов

```bash
# Apache + PHP
sudo apt install apache2 php libapache2-mod-php php-mysql

# PostgreSQL
sudo apt install postgresql postgresql-contrib
```

---

## 3. Активация виртуального окружения

Из верхней папки проекта:

```bash
source env/bin/activate
```

---

## 4. Создание симлинка для сайта

```bash
sudo ln -s /home/jokerjmoker/dev/sem7/AZIS/WebBMSTU /var/www/html/WebBMSTU
```

---

## 5. Выдача прав сервису

WSL запускается локально, поэтому это безопасно.

```bash
chmod o+x /home/jokerjmoker
```

### Проверка прав

```bash
namei -l /home/jokerjmoker/dev/sem7/AZIS/WebBMSTU
ls -la /var/www/html/
```

---

## 6. Запуск сервисов

```bash
# Apache
sudo service apache2 start

# PostgreSQL
sudo service postgresql start
```

---

## 7. Работа с PostgreSQL

### Вход в psql

```bash
sudo -u postgres psql
```

### Учётные данные

| Пользователь | Пароль     |
|--------------|------------|
| `postgres`   | `270961Ts` |
| `joker`      | `joker`    |



SELECT * FROM countries WHERE iso_code LIKE 'R%' - по совпадению
SELECT count(*) FROM countries WHERE name LIKE '%а%'

научиться работать с sql при опмощи php