import UIKit
import RKOperations

/// Показывает алерт на старте приложения с политикой, условиями использования и кнопкой принять
///
/// Алерт будет показываться до тех пор, пока не будет нажата кнопка "Принять"
final class PrivacyPolicyAlertOperation: RKOperation, @unchecked Sendable {
    private weak var controller: UIViewController?
    private let context: Context
    private let handler: Handler
    
    init(controller: UIViewController, context: Context, handler: Handler) {
        self.controller = controller
        self.context = context
        self.handler = handler
        super.init()
    }
    
    override func execute() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert()
        }
    }
}

// MARK: - Context and Handler

extension PrivacyPolicyAlertOperation {
    struct Context {
        let privacyPolicyURL: URL
        let termsOfUseURL: URL
    }
    
    struct Handler {
        let onPrivacyAccepted: () -> Void
        let openURL: (URL) -> Void
    }
}

// MARK: - Alert

private extension PrivacyPolicyAlertOperation {
    func showAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("privacy_alert_title", comment: ""),
            message: NSLocalizedString("privacy_alert_message", comment: ""),
            preferredStyle: .alert
        )
        
        let context = context
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("privacy_alert_terms_of_use_button", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.handler.openURL(context.termsOfUseURL)
                self.showAlert()
            }
        ))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("privacy_alert_privacy_policy_button", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.handler.openURL(context.privacyPolicyURL)
                self.showAlert()
            }
        ))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("privacy_alert_accept_button", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.handler.onPrivacyAccepted()
                self.finish()
            }
        ))
        
        controller?.present(alert, animated: true, completion: nil)
    }
}
