import AppTrackingTransparency
import RKOperations

/// Запрашиваем доступ к отслеживанию в приложении (для получения IDFA)
final class AppTrackingTransparencyAlertOperation: RKOperation, @unchecked Sendable {
    private let handler: Handler?
    
    init(handler: Handler? = nil) {
        self.handler = handler
        super.init()
    }
    
    override func execute() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                guard let self = self else { return }
                self.handler?.onChangeStatus(status)
                self.finish()
            }
        } else {
            finish()
        }
    }
}

// MARK: - Handler

extension AppTrackingTransparencyAlertOperation {
    struct Handler {
        let onChangeStatus: (ATTrackingManager.AuthorizationStatus) -> Void
    }
}
