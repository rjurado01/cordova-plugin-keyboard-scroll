const exec = require('cordova/exec');

var Keyboard = {};

Keyboard.init = () => {
  const onKeyboardWillShow = result => {
    if (Keyboard.hideTimeout) {
      clearTimeout(Keyboard.hideTimeout);
      return;
    }

    const time = new Date().getTime() - Keyboard.lastHide;
    const screenSize = document.body.offsetHeight - result;

    // resize body to total size less keyboard (allow scroll)
    document.body.style.height = screenSize + 'px';

    if (document.activeElement.getBoundingClientRect().top > screenSize) {
      document.activeElement.scrollIntoView({block: 'center', behavior: "smooth"});
    }
  };

  const onKeyboardWillHide = result => {
    Keyboard.hideTimeout = setTimeout(() => {
      document.body.style.height = '';
      Keyboard.hideTimeout = null;
    }, 50);
  };

  exec(onKeyboardWillShow, console.error, 'KeyboardScroll', 'onKeyboardWillShow');
  exec(onKeyboardWillHide, console.error, 'KeyboardScroll', 'onKeyboardWillHide');
}

// Initialize plugin
document.addEventListener("deviceready", () => {
  if (cordova.platformId === 'ios') Keyboard.init();
});
