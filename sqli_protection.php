<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <link href="style.css" rel="stylesheet">
    <title>Защита от SQL-инъекций</title>
</head>
<body>
<header>
    <div class="logo">
        <img class="logo__image" src="img/logo_with_text.png" alt="Логотип МГТУ" width="275" height="70">
    </div>
    <div class="navigation">
        <ul class="navigation__list">
            <li class="navigation__list-item">
                <a class="navigation__link" href="index.php">Главная страница</a>
            </li>
            <li class="navigation__list-item">
                <a class="navigation__link" href="contacts.php">Контакты</a>
            </li>
        </ul>
    </div>
</header>

<main>
    <h1>Безопасная работа с БД</h1>

    <?php
    $con = mysqli_connect("localhost", "joker", "joker", "world_data");

    if ($con == false) {
        print("Ошибка подключения: " . mysqli_connect_error());
    } else {
        print("Соединение установлено<br/>");

        // Безопасное получение ID (приведение к числу)
        // Если ID не передан, используем 1 для примера
        $id = isset($_GET['id']) ? intval($_GET['id']) : 1;

        // ПОДГОТОВЛЕННОЕ ВЫРАЖЕНИЕ
        // 1. Шаблон запроса с плейсхолдером (?)
        $sql = "SELECT id, name, capital FROM countries WHERE id = ?";
        
        // 2. Подготовка выражения
        $stmt = mysqli_prepare($con, $sql);
        
        // 3. Привязка параметров (i - integer)
        mysqli_stmt_bind_param($stmt, 'i', $id);
        
        // 4. Выполнение
        mysqli_stmt_execute($stmt);
        
        // 5. Получение результата
        $res = mysqli_stmt_get_result($stmt);
        
        // 6. Обработка данных
        if ($res) {
            $rows = mysqli_fetch_all($res, MYSQLI_ASSOC);
            foreach ($rows as $row) {
                print("Страна: " . $row['name'] . " столица: " . $row['capital']);
                print("<br/>");
            }
        } else {
            print("Ошибка выполнения запроса");
        }
        
        // Закрытие выражения
        mysqli_stmt_close($stmt);
    }
    ?>
</main>

<footer>
    <?php print("МГТУ им. Н.Э. Баумана © Все права защищены"); ?>
</footer>
</body>
</html>