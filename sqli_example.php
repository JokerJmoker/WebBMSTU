<?php
// УЯЗВИМЫЙ КОД (демонстрация SQL-инъекции)
$con = mysqli_connect("localhost", "joker", "joker", "world_data");

if ($con == false) {
    print("Ошибка подключения: " . mysqli_connect_error());
    die();
}

// Получаем ID из GET-запроса
$id = $_GET['ID'];

// ОПАСНО: Прямая подстановка данных пользователя в SQL-запрос
$sql = "DELETE FROM countries WHERE ID = '$id'";
$result = mysqli_query($con, $sql);

if (!$result) {
    print("Ошибка MySQL: " . mysqli_error($con));
} else {
    print("Запрос выполнен. Запись удалена.");
}
?>