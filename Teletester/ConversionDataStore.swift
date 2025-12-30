import Foundation
import AppsFlyerLib

class ConversionDataStore: ObservableObject {
    static let shared = ConversionDataStore()

    // Тестовые данные для запроса (на время тестов)
    init() {
        #if DEBUG
        self.conversionData = [
            "af_status": "Non-organic",
            "bundle_id": "com.bobka.abobka",
            "os": "iOS",
            "store_id": "id6757008033",
            "locale": "en_US"
        ]
        #endif
    }
    @Published var conversionData: [AnyHashable: Any]? = nil
    @Published var webViewURL: String? = nil

    func updateConversionData(_ data: [AnyHashable: Any]) {
        var merged = conversionData ?? [:]
        for (key, value) in data {
            merged[key] = value
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
        // Add APNs token if available
        if let apnsToken = AppDelegate.sharedAPNSToken {
            let tokenString = apnsToken.map { String(format: "%02.2hhx", $0) }.joined()
            conversionData["apns_token"] = tokenString
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
