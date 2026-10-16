<?php
// form.php

// Подключение к БД
$con = mysqli_connect("localhost", "joker", "joker", "world_data");

if ($con == false) {
    print("Ошибка подключения: " . mysqli_connect_error());
    die();
}

// Проверяем, были ли отправлены данные методом POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Получаем данные из формы
    $username = $_POST['username'] ?? '';
    $message = $_POST['message'] ?? '';

    // Безопасное сохранение в БД с помощью подготовленных выражений
    $sql = "INSERT INTO messages (username, message) VALUES (?, ?)";
    $stmt = mysqli_prepare($con, $sql);
    
    if ($stmt) {
        // Привязываем параметры (ss - две строки)
        mysqli_stmt_bind_param($stmt, 'ss', $username, $message);
        
        if (mysqli_stmt_execute($stmt)) {
            print("Имя: " . htmlspecialchars($username));
            print("<br>Сообщение: " . htmlspecialchars($message));
            print("<br>Сообщение успешно сохранено в БД!");
        } else {
            print("Ошибка при сохранении в БД: " . mysqli_error($con));
        }
        mysqli_stmt_close($stmt);
    } else {
        print("Ошибка подготовки запроса: " . mysqli_error($con));
    }

    // Проверяем, был ли загружен файл
    if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
        $file = $_FILES['avatar'];

        // Извлекаем имя файла и его размер
        $fileName = $file['name'];
        $fileSize = $file['size'];

        print("<br>Загруженный файл: " . htmlspecialchars($fileName));
        print("<br>Размер файла: " . $fileSize . " байт");

    } else {
        print("<br>Файл не был загружен или произошла ошибка.");
    }
}
?>