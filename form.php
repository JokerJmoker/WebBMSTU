<?php
// form.php

// Проверяем, были ли отправлены данные методом POST
if (isset($_POST)) {
    // Выводим имя пользователя
    print("Имя: " . $_POST['username']);
    print("<br>Сообщение: " . $_POST['message']);

    // Проверяем, был ли загружен файл
    if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
        $file = $_FILES['avatar'];

        // Извлекаем имя файла и его размер
        $fileName = $file['name'];
        $fileSize = $file['size'];

        print("<br>Загруженный файл: " . $fileName);
        print("<br>Размер файла: " . $fileSize . " байт");

    } else {
        print("<br>Файл не был загружен или произошла ошибка.");
    }
}
?>