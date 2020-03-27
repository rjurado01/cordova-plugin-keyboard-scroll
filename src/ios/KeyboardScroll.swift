/*
 * Notes: The @objc shows that this class & function should be exposed to Cordova.
 */
@objc(KeyboardScroll) class KeyboardScroll : CDVPlugin, UIScrollViewDelegate {
    var willShowCallbackId: String?
    var willHideCallbackId: String?

    @objc override func pluginInitialize() {
      self.webView.scrollView.delegate = self;
    }

    @objc(onKeyboardWillShow:)
    func onKeyboardWillShow(command: CDVInvokedUrlCommand) {
        self.willShowCallbackId = command.callbackId

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    @objc(onKeyboardWillHide:)
    func onKeyboardWillHide(command: CDVInvokedUrlCommand) {
        self.willHideCallbackId = command.callbackId

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // Avoid scroll statusbar top when keyboard appears
    func scrollViewDidScroll(_ scrollView: UIScrollView!) {
        scrollView.contentOffset = CGPoint.zero
    }

    // Notify keyboard will show and send keyboard height
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            // Set the plugin result to succeed.
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK, messageAs: keyboardHeight.description);

            pluginResult?.setKeepCallbackAs(true);

            // Send the function result back to Cordova.
            self.commandDelegate!.send(pluginResult, callbackId: willShowCallbackId);
        }
    }

    // Notify keyboard will hide
    @objc func keyboardWillHide(_ notification: Notification) {
        // Set the plugin result to succeed.
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);

        pluginResult?.setKeepCallbackAs(true);

        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: willHideCallbackId);
    }
}
