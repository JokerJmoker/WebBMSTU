```markdown
# Настройка веб-сервера Apache + PHP + MySQL в WSL

## 1. Быстрый запуск через Python (для проверки)

```bash
python -m http.server 8000
# Открыть: http://localhost/WebBMSTU/
```

---

## 2. Установка необходимых пакетов

```bash
# Apache + PHP + MySQL
sudo apt install apache2 php libapache2-mod-php php-mysql mysql-server
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

# MYSQL
sudo service mysql start
```

---

## 7. Работа с MySQL

### Вход в mysql

```bash
sudo mysql
```

### Учётные данные

| Пользователь | Пароль     |
|--------------|------------|
| `root`       | `270961Ts` |
| `joker`      | `joker`    |

### Примеры SQL-запросов

```sql
SELECT * FROM countries WHERE iso_code LIKE 'R%';
SELECT count(*) FROM countries WHERE name LIKE '%а%';
```
