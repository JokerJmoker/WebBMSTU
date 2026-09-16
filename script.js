let headingElement = document.querySelector('h1');

headingElement.textContent =
    'Вы хотите связаться с нами? Заполните форму ниже!';

headingElement.style.color = 'red';

let formButton = document.querySelector('.contacts__form-submit');

function getRandomColor() {
    let letters = '0123456789ABCDEF';
    let color = '#';

    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }

    return color;
}

let mainElement = document.querySelector('main');

formButton.onclick = function(event) {
    event.preventDefault();

    headingElement.style.color = getRandomColor();
    mainElement.style.backgroundColor = getRandomColor();
};