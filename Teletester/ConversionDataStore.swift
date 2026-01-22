import Foundation
import AppsFlyerLib

class ConversionDataStore: ObservableObject {
    static let shared = ConversionDataStore()

    // Тестовые данные для запроса (на время тестов)
    init() {
        #if DEBUG
        var testData: [AnyHashable: Any] = [
            "af_status": "Non-organic",
            "os": "iOS",
            "locale": Locale.current.identifier
        ]
        if let bundleId = Bundle.main.bundleIdentifier {
            testData["bundle_id"] = bundleId
        }
        // Попытка получить store_id из Info.plist (App Store ID)
        if let storeId = Bundle.main.object(forInfoDictionaryKey: "AppStoreID") as? String {
            testData["store_id"] = storeId
        } else {
            testData["store_id"] = nil
        }
        self.conversionData = testData
        #endif
    }
    @Published var conversionData: [AnyHashable: Any]? = nil
    @Published var webViewURL: String? = nil

    func updateConversionData(_ data: [AnyHashable: Any]) {
        var merged = conversionData ?? [:]
        for (key, value) in data {
            merged[key] = value
        }
        // bundle_id всегда из Bundle.main.bundleIdentifier
        if let bundleId = Bundle.main.bundleIdentifier {
            merged["bundle_id"] = bundleId
        }
        // Ensure required keys exist (even if nil)
        let requiredKeys: [String] = [
            "os", "country", "external_id", "push_token", "locale", "bundle_id"
        ]
        for key in requiredKeys {
            if merged[key] == nil {
                merged[key] = nil
            }
        }
        // Map apns_project_id and apns_token if present
        if let apnsProjectId = merged["apns_project_id"] {
            merged["external_id"] = apnsProjectId
        }
        if let apnsToken = merged["apns_token"] {
            merged["push_token"] = apnsToken
        }
        conversionData = merged

        // Если webViewURL еще не получен, запрашиваем его после получения conversionData
        if webViewURL == nil {
            fetchWebViewURL { _ in }
        }
    }

    func fetchWebViewURL(completion: @escaping (String?) -> Void) {
        guard var conversionData = conversionData else {
            completion(nil)
            return
        }
        // bundle_id всегда из Bundle.main.bundleIdentifier
        if let bundleId = Bundle.main.bundleIdentifier {
            conversionData["bundle_id"] = bundleId
        }
        // Add APNs token if available
        if let apnsToken = AppDelegate.sharedAPNSToken {
            let tokenString = apnsToken.map { String(format: "%02.2hhx", $0) }.joined()
            conversionData["apns_token"] = tokenString
            conversionData["push_token"] = tokenString
        }
        // Map apns_project_id to external_id if present
        if let apnsProjectId = conversionData["apns_project_id"] {
            conversionData["external_id"] = apnsProjectId
        }
        // Ensure required keys exist (even if nil)
        let requiredKeys: [String] = [
            "os", "country", "external_id", "push_token", "locale", "bundle_id"
        ]
        for key in requiredKeys {
            if conversionData[key] == nil {
                conversionData[key] = nil
            }
        }
        guard let url = URL(string: "https://brainrotcheck.com/config.php") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[ConversionDataStore] JSON payload for POST:\n\(jsonString)")
            }
            request.httpBody = jsonData
        } catch {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            // Парсим JSON и берём поле url
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let ok = json["ok"] as? Bool, ok {
                if let urlString = json["url"] as? String, !urlString.isEmpty {
                    DispatchQueue.main.async {
                        self.webViewURL = urlString
                        completion(urlString)
                    }
                } else {
                    // ok == true, но url нет — явно ошибка, показываем специальное сообщение
                    DispatchQueue.main.async {
                        self.webViewURL = "__NO_URL__"
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
