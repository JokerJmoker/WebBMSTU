<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <link href="style.css" rel="stylesheet">
    <title>Работа с базой данных</title>
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
    <h1>Работа с базой данных</h1>

    <?php
    // Подключение к БД с вашими данными
    $con = mysqli_connect("localhost", "joker", "joker", "world_data");

    // Проверка подключения
    if ($con == false) {
        print("Ошибка подключения: " . mysqli_connect_error());
    } else {
        print("Соединение установлено");
        print("<br/>");

        // Запрос на модификацию (INSERT)
        $sql_insert = "INSERT INTO countries (name, capital, iso_code) VALUES ('Australia', 'Canberra', 'AU')";
        $result_insert = mysqli_query($con, $sql_insert);

        if (!$result_insert) {
            print("Ошибка MySQL: " . mysqli_error($con));
            print("<br/>");
        } else {
            print("Запись добавлена");
            print("<br/>");
        }

        // Запрос на чтение (SELECT)
        $sql_select = "SELECT id, name, capital FROM countries";
        $result_select = mysqli_query($con, $sql_select);

        if (!$result_select) {
            $error = mysqli_error($con);
            print("Ошибка MySQL: " . $error);
            print("<br/>");
        } else {
            // Преобразование ресурса в массив
            $rows = mysqli_fetch_all($result_select, MYSQLI_ASSOC);
            
            // Вывод данных
            foreach ($rows as $row) {
                print("Страна: " . $row['name'] . " столица: " . $row['capital']);
                print("<br/>");
            }
        }
    }
    ?>
</main>

<footer>
    <?php print("МГТУ им. Н.Э. Баумана © Все права защищены"); ?>
</footer>
</body>
</html>