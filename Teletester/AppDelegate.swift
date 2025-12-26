import AppsFlyerLib
import UIKit
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppsFlyerLibDelegate, DeepLinkDelegate {
    // Shared variable to store APNs token
    static var sharedAPNSToken: Data?
    // MARK: - AppsFlyer DeepLinkDelegate
    func didResolveDeepLink(_ result: DeepLinkResult) {
        switch result.status {
        case .notFound:
            print("[AppsFlyer] Deep link not found")
            return
        case .failure:
            print("[AppsFlyer] Deep link error: \(String(describing: result.error))")
            return
        case .found:
            print("[AppsFlyer] Deep link found")
        }
        guard let deepLinkObj = result.deepLink else {
            print("[AppsFlyer] Could not extract deep link object")
            return
        }
        // Логируем параметры
        print("[AppsFlyer] DeepLink data: \(deepLinkObj.toString())")
        // Добавляем параметры deep link в conversionData
        var updatedData = ConversionDataStore.shared.conversionData ?? [:]
        for (key, value) in deepLinkObj.clickEvent {
            updatedData[key] = value
        }
        updatedData["deeplinkValue"] = deepLinkObj.deeplinkValue
        updatedData["isDeferred"] = deepLinkObj.isDeferred
        ConversionDataStore.shared.updateConversionData(updatedData)
    }
    // MARK: - AppsFlyer Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("[AppsFlyer] Deep Link Attribution Data:")
        for (key, value) in attributionData {
            print("\(key): \(value)")
        }
        // Добавляем параметры deep link в conversionData
        var updatedData = ConversionDataStore.shared.conversionData ?? [:]
        for (key, value) in attributionData {
            updatedData[key] = value
        }
        ConversionDataStore.shared.updateConversionData(updatedData)
    }

    func onAppOpenAttributionFailure(_ error: Error) {
        print("[AppsFlyer] Deep Link Attribution Failure: \(error)")
    }
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("[AppsFlyer] Conversion Data Success:")
        for (key, value) in conversionInfo {
            print("\(key): \(value)")
        }
        // Выводим JSON conversion data для отладки
        if let jsonData = try? JSONSerialization.data(withJSONObject: conversionInfo, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("[AppsFlyer] Conversion Data JSON:\n\(jsonString)")
        }
        // Save conversion data for later use
        ConversionDataStore.shared.updateConversionData(conversionInfo)
    }

    func onConversionDataFail(_ error: any Error) {
        print("[AppsFlyer] Conversion Data Fail: \(error)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Запрос разрешения на отслеживание (ATT)
        if #available(iOS 14, *) {            
            ATTrackingManager.requestTrackingAuthorization { status in
                print("ATT status: \(status.rawValue)")
                // После запроса ATT запускаем AppsFlyer
                self.startAppsFlyer()
            }
        } else {
            // Для iOS < 14 запускаем AppsFlyer сразу
            self.startAppsFlyer()
        }

        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Request authorization failed: \(error)")
                return
            }
            print("Notification permission granted: \(granted)")
        }
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }

        return true
    }
    // MARK: - Appsflyer
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Запуск AppsFlyer теперь происходит после запроса ATT
    }

    // MARK: - Запуск AppsFlyer после ATT
    func startAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "RrHw56XtM4Pax7QF8b4NeT"
        AppsFlyerLib.shared().appleAppID = "id6757008033"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().start()
    }

    // APNs token received from Apple — forward to FCM
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppDelegate.sharedAPNSToken = deviceToken
        print("APNs device token received and stored")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notifications while app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle user's response to the notification
        let userInfo = response.notification.request.content.userInfo
        print("User opened notification: \(userInfo)")
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveFCMToken = Notification.Name("didReceiveFCMToken")
}
