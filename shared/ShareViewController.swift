//
//  ShareViewController.swift
//  shared
//
//  Created by Nevzat BOZKURT on 1.01.2024.
//
import UIKit

class ShareViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Get the shared items
        if let sharedItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in sharedItems {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        // Check if the attachment contains a URL
                        if attachment.hasItemConformingToTypeIdentifier("public.url") {
                            attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                                if let url = url as? URL {
                                    // Handle the received URL (print to console)
                                    //print("Received URL: \(url)")
                                    
                                    // Use NSExtensionContext to communicate with the host app
                                     if let appURL = URL(string: "nevzatbozkurtxdown://?url=\(url.absoluteString)") {
                                         _ = self.openURL(appURL)
                                     }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
}
