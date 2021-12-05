//
//  WebView.swift
//  Jade
//
//  Created by Nindi Gill on 2/12/21.
//

import Foundation
import WebKit

class WebView: NSObject, ObservableObject {

    enum JamfURLType: String {
        case id = "https://id.jamf.com/CommunitiesLogin"
        case account = "https://account.jamf.com/"
    }

    @Published var cookie: HTTPCookie?
    @Published var username: String = ""
    @Published var password: String = ""
    private var webView: WKWebView = WKWebView()

    override init() {
        super.init()
        webView.navigationDelegate = self

        guard let credentials: (username: String, password: String) = Keychain.read() else {
            return
        }

        username = credentials.username
        password = credentials.password
    }

    func refreshCookie() {

        DispatchQueue.main.async {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in

                for cookie in cookies {
                    WKWebsiteDataStore.default().httpCookieStore.delete(cookie, completionHandler: nil)
                }

                guard let url: URL = URL(string: JamfURLType.id.rawValue) else {
                    return
                }

                let request: URLRequest = URLRequest(url: url)
                self.webView.load(request)
            }
        }
    }

    func stopLoading() {
        webView.stopLoading()
    }
}

extension WebView: WKNavigationDelegate {

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        guard let url: URL = webView.url,
            let jamfURLType: JamfURLType = JamfURLType(rawValue: url.absoluteString) else {
            return
        }

        switch jamfURLType {
        case .id:
            let javaScript: String = """
            document.getElementById('loginPage:login-form:email-input').value = '\(username)';
            document.getElementById('loginPage:login-form:password-input').value = '\(password)';
            document.getElementById('loginPage:login-form:submit').click();
            """

            webView.evaluateJavaScript(javaScript) { _, error in

                if let error: Error = error {
                    print(error.localizedDescription)
                }
            }
        case .account:
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                for cookie in cookies where cookie.name == "JAMF_ACCOUNT_SESSION" {
                    self.cookie = cookie
                }
            }
        }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        cookie = nil
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        cookie = nil
    }
}
