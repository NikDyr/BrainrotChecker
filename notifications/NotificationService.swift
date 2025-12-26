//
//  NotificationService.swift
//  notifications
//
//  Created by MacBook on 26/12/2025.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Check for image URL in APNs payload ("image-url" key in aps or custom payload)
        if let imageURLString = request.content.userInfo["image-url"] as? String, let imageURL = URL(string: imageURLString) {
            downloadImage(from: imageURL) { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }
        private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
            let task = URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
                guard let downloadedUrl = downloadedUrl else {
                    completion(nil)
                    return
                }
                let fileManager = FileManager.default
                let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
                let uniqueURL = tmpDir.appendingPathComponent(UUID().uuidString + ".jpg")
                do {
                    try fileManager.moveItem(at: downloadedUrl, to: uniqueURL)
                    let attachment = try UNNotificationAttachment(identifier: "image", url: uniqueURL, options: nil)
                    completion(attachment)
                } catch {
                    completion(nil)
                }
            }
            task.resume()
        }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
