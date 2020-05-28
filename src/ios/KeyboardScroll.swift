/*
 * Notes: The @objc shows that this class & function should be exposed to Cordova.
 */
@objc(KeyboardScroll) class KeyboardScroll : CDVPlugin, UIScrollViewDelegate {
    var willShowCallbackId: String?
    var willHideCallbackId: String?
    var elementId: String?
    var keyboardResizeAfterShow: Bool?

    @objc override func pluginInitialize() {
        self.webView.scrollView.delegate = self;
        self.elementId = self.commandDelegate!.settings["keyboardscrollelementid"] as? String
        self.keyboardResizeAfterShow = self.commandDelegate!.settings["keyboardresizeaftershow"] as? String == "true" as String ? true : false

        // default values
        if self.elementId == nil {
          self.elementId = "ion-tabs"
        }
        if self.keyboardResizeAfterShow == nil {
          self.keyboardResizeAfterShow = false
        }
    }

    @objc(onKeyboardWillShow:)
    func onKeyboardWillShow(command: CDVInvokedUrlCommand) {
        self.willShowCallbackId = command.callbackId

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: self.keyboardResizeAfterShow ?? false ? NSNotification.Name.UIKeyboardDidShow : NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }

    @objc(onKeyboardWillHide:)
    func onKeyboardWillHide(command: CDVInvokedUrlCommand) {
        self.willHideCallbackId = command.callbackId

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    // Avoid scroll statusbar top when keyboard appears
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint.zero
    }

    // Notify keyboard will show and send keyboard height
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            // Set the plugin result to succeed.
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK, messageAs: [keyboardHeight.description, self.elementId as Any]);

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
