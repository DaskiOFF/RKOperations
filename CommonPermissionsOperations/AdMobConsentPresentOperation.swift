import UIKit
import RKOperations
import Combine
import RKFunctional

final class AdMobConsentPresentOperation: RKOperation, @unchecked Sendable {
    private var cancellable: AnyCancellable?
    private weak var controller: UIViewController?
    private let adMobConsent: Privacy.Model
    private let handler: Handler
    
    init(controller: UIViewController, adMobConsent: Privacy.Model, handler: Handler) {
        self.controller = controller
        self.adMobConsent = adMobConsent
        self.handler = handler
        super.init()
    }
    
    override func execute() {
        cancellable = adMobConsent.status
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weak(self, AdMobConsentPresentOperation.presentFormIfNeeded))
    }
    
    override func finished(with errors: [Error]) {
        cancellable?.cancel()
        cancellable = nil
    }
}

// MARK: - Handler

extension AdMobConsentPresentOperation {
    struct Handler {
        let onAdsIsAllowed: (Bool) -> Void
    }
}

// MARK: - Form

private extension AdMobConsentPresentOperation {
    func presentFormIfNeeded(for status: Privacy.Status) {
        switch status {
        case .notLoadedYet, .available:
            break
        case .notNeeded:
            handle(obtain: true)
        case .loaded:
            if let controller = controller {
                adMobConsent.present(from: controller, completion: weak(self, AdMobConsentPresentOperation.handle))
            } else {
                assertionFailure()
                finish()
            }
        }
    }
    
    func handle(obtain: Bool) {
        handler.onAdsIsAllowed(obtain)
        finish()
    }
}
