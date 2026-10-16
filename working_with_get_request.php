<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <link href="style.css" rel="stylesheet">
    <title>GET-запрос</title>
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
    <h1>Работа с GET-запросом</h1>

    <?php
    if (isset($_GET['country'])) {
        print("Название страны, переданное в запросе: " . $_GET['country']);
        print("<br>");
    } else {
        print("Данные в параметре country через GET-запрос не переданы");
    }
    ?>
</main>

<footer>
    <?php print("МГТУ им. Н.Э. Баумана © Все права защищены"); ?>
</footer>
</body>
</html>