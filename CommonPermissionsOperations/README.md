# Common Permissions Operations

# Шаг 1. Проверить доступность формы для GDPR

https://apps.admob.com/v2/privacymessaging/gdpr/education?_ga=2.232494495.1255054913.1645042919-509983612.1645042919&_gl=1*1b98d9n*_ga*NTA5OTgzNjEyLjE2NDUwNDI5MTk.*_ga_6R1K8XRD9P*MTY0NTA0MjkxOC4xLjAuMTY0NTA0MjkxOS4w

# Шаг 2. Добавить зависимости

1. `RKOperations`
2. `RKFunctional`

# Шаг 3. Добавить строки для локализации

### English

```
"privacy_alert_title" = "Important notice";
"privacy_alert_message" = "To continue the app, please agree to the updated Terms of Use and Privacy Policy.";
"privacy_alert_terms_of_use_button" = "Terms of Use";
"privacy_alert_privacy_policy_button" = "Privacy Policy";
"privacy_alert_accept_button" = "Accept";
```

### Russian

```
"privacy_alert_title" = "Важная информация";
"privacy_alert_message" = "Для продолжения Вам необходимо согласиться с Условиями использования и Политикой конфиденциальности";
"privacy_alert_terms_of_use_button" = "Условия пользования";
"privacy_alert_privacy_policy_button" = "Политика конфиденциальности";
"privacy_alert_accept_button" = "Принять";
```

# Шаг 4. Добавить Flow для запроса разрешений

После показа контроллера, желательно все алерты на старте встроить в этот флоу

### Пример:

```swift
import RKOperations
import UIKit

final class RequestPermissionsFlow {
    private let operationsQueue = RKOperationQueue()
    
    func start(from controller: UIViewController, session: Session) {
        var operations: [RKOperation] = []
        
        if !session.serviceSettings.isPrivacyAccepted {
            let policyOperation = PrivacyPolicyAlertOperation(
                controller: controller,
                context: .init(
                    privacyPolicyURL: session.config.privacyPolicyURL,
                    termsOfUseURL: session.config.termsOfUseURL),
                handler: .init(
                    onPrivacyAccepted: { session.serviceSettings.isPrivacyAccepted = true },
                    openURL: { UIApplication.shared.open($0) })
            )
            operations.append(policyOperation)
        }
        
        let appTrackingOperation = AppTrackingTransparencyAlertOperation()
        _ = operations.last.flatMap { $0 <- appTrackingOperation }
        operations.append(appTrackingOperation)
        
        if session.serviceSettings.isConsentShowed {
            let adMobConsentOperation = AdMobConsentPresentOperation(
                controller: controller,
                adMobConsent: session.adMobConsent,
                handler: .init(onAdsIsAllowed: { [weak session] obtain in
                    guard let session = session else { return }
                    session.serviceSettings.isConsentShowed = true
                })
            )
            operations.append(adMobConsentOperation)
            
            appTrackingOperation <- adMobConsentOperation
        }
        
        operationsQueue.addOperations(operations, waitUntilFinished: false)
    }
}
```
