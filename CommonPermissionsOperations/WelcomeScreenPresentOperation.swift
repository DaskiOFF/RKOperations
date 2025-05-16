import UIKit
import RKWelcomeScreen
import RKOperations

/// Показывает привественный экран
final class WelcomeScreenPresentOperation: RKOperation, @unchecked Sendable {
    private weak var controller: UIViewController?
    private let model: RKWelcomeScreenViewController.Model
    
    init(controller: UIViewController, model: RKWelcomeScreenViewController.Model) {
        self.controller = controller
        self.model = model
        super.init()
    }
    
    override func execute() {
        DispatchQueue.main.async { [weak self] in
            self?.present()
        }
    }
}

// MARK: - Present

private extension WelcomeScreenPresentOperation {
    func present() {
        let buttonAction = self.model.button.action
        let model = RKWelcomeScreenViewController.Model(
            title: self.model.title,
            items: self.model.items,
            button: (self.model.button.title, { [weak self] in
                guard let self = self else { return }
                buttonAction()
                self.controller?.presentedViewController?.dismiss(animated: true, completion: nil)
                self.finish()
            }),
            appearance: self.model.appearance
        )
        
        let width = UIDevice.isIpad ? 375 : (controller?.view.frame.width ?? 375)
        let welcome = RKWelcomeScreenViewController(model: model, width: width)
        if UIDevice.isIpad {
            welcome.modalPresentationStyle = .formSheet
            welcome.isModalInPresentation = true
            welcome.preferredContentSize = CGSize(
                width: width,
                height: min(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.9, 600))
        } else {
            welcome.modalPresentationStyle = .fullScreen
        }
        controller?.present(welcome, animated: true, completion: nil)
    }
}
