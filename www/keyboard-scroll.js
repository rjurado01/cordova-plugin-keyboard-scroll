const exec = require('cordova/exec');

var Keyboard = {
  isVisible: false, // needed in emulator
  hideTimout: null // needed in real devices
};

Keyboard.init = () => {
  const onKeyboardWillShow = opts => {
    // get variables
    const keyboardHeight = opts[0];
    const elementID = opts[1]

    // avoid run when keyboard is opened and click other input (event WillShow is fired)
    if (Keyboard.isVisible || Keyboard.hideTimeout) {
      clearTimeout(Keyboard.hideTimeout);
      return;
    }

    const time = new Date().getTime() - Keyboard.lastHide;
    const screenSize = document.body.offsetHeight - keyboardHeight;
    
    // get closest element size
    let element_size = 0;
    if (elementID) {
        const element = document.activeElement.closest(elementID);
        if (element) {
            element_size = element.lastChild.offsetHeight;
        }
    }

    // resize body to total size less keyboard (allow scroll)
    document.body.style.height = screenSize + element_size + 'px';
    Keyboard.isVisible = true;

    if (document.activeElement.getBoundingClientRect().bottom > screenSize) {
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
