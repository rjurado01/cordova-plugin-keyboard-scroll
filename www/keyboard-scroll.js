const exec = require('cordova/exec');

var Keyboard = {
  isVisible: false, // needed in emulator
  hideTimout: null // needed in real devices
};

Keyboard.init = () => {
  const onKeyboardWillShow = keyboardHeight => {
    // avoid run when keyboard is opened and click other input (event WillShow is fired)
    if (Keyboard.isVisible || Keyboard.hideTimeout) {
      clearTimeout(Keyboard.hideTimeout);
      return;
    }

    const time = new Date().getTime() - Keyboard.lastHide;
    const screenSize = document.body.offsetHeight - keyboardHeight;

    // resize body to total size less keyboard (allow scroll)
    document.body.style.height = screenSize + 'px';
    Keyboard.isVisible = true;

    if (document.activeElement.getBoundingClientRect().top > screenSize) {
      document.activeElement.scrollIntoView({block: 'center', behavior: "smooth"});
    }
  };

  const onKeyboardWillHide = () => {
    Keyboard.hideTimeout = setTimeout(() => {
      document.body.style.height = '';
      Keyboard.hideTimeout = null;
      Keyboard.isVisible = false;
    }, 50);
  };

  exec(onKeyboardWillShow, console.error, 'KeyboardScroll', 'onKeyboardWillShow');
  exec(onKeyboardWillHide, console.error, 'KeyboardScroll', 'onKeyboardWillHide');
}

// Initialize plugin
document.addEventListener("deviceready", () => {
  if (cordova.platformId === 'ios') Keyboard.init();
});
