let formElement = document.querySelector('form');
let welcomeUserElement = formElement.querySelector('.welcome-user');
let userNameElement    = formElement.querySelector('.contacts__form-input');
let userTextElement    = formElement.querySelector('.contacts__form-textarea');

function submitFormHandler(event) {
    event.preventDefault();
    welcomeUserElement.innerHTML = `Здравствуйте, ${userNameElement.value}! `;
    welcomeUserElement.innerHTML = welcomeUserElement.innerHTML + `Вы написали: "${userTextElement.value}"`;
    welcomeUserElement.innerHTML = welcomeUserElement.innerHTML + 'Хорошего дня!';
}


formElement.addEventListener('submit', submitFormHandler);
