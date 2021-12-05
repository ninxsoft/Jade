//
//  ContentView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI
import UserNotifications

enum SheetType: String {
    case credentials = "Credentials"
    case refresh = "Refresh"
    case download = "Download"
}

struct ContentView: View {
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?
    @State private var selectedDownloadLink: DownloadLink?
    @State private var destinationURL: URL?
    @State private var sheet: SheetType?
    @State private var sheetPresented: Bool = false
    @StateObject private var webView: WebView = WebView()
    private var openPanel: NSOpenPanel = NSOpenPanel()
    @AppStorage("RequestedAuthorizationForNotifications") private var requestedAuthorizationForNotifications: Bool = false
    @AppStorage("HideUnownedProducts") private var hideUnownedProducts: Bool = true

    private let width: CGFloat = 1_080
    private let height: CGFloat = 720

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(productTypes()) { productType in
                    NavigationLink(
                        destination: DetailView(
                            productType: productType,
                            products: products(for: productType),
                            selectedProduct: $selectedProduct,
                            selectedDownloadLink: $selectedDownloadLink
                        )
                    ) {
                        SidebarRowView(productType: productType)
                    }
                }
                Spacer()
                Divider()
                HStack {
                    Toggle("Hide Unowned Products", isOn: $hideUnownedProducts)
                }
                .padding()
            }
            Text("Select a product type from the sidebar to view available downloads.")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    sheet = .credentials
                    sheetPresented = true
                }, label: {
                    Image(systemName: "key")
                        .foregroundColor(.accentColor)
                })
                .help("Credentials")
            }
            ToolbarItem {
                Button(action: {
                    sheet = .refresh
                    sheetPresented = true
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                })
                .help("Refresh")
            }
        }
        .frame(minWidth: width, minHeight: height)
        .onAppear {

            checkForUpdates()

            guard Keychain.read() != nil else {
                sheet = .credentials
                return
            }

            sheet = .refresh
        }
        .onChange(of: sheet) { sheet in

            guard sheet != nil else {
                return
            }

            sheetPresented = true
        }
        .onChange(of: selectedDownloadLink) { selectedDownloadLink in

            guard selectedDownloadLink != nil else {
                sheet = nil
                return
            }

            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.isAccessoryViewDisclosed = false

            openPanel.begin { response in

                guard response == .OK,
                    let url: URL = openPanel.url else {
                    self.selectedDownloadLink = nil
                    return
                }

                destinationURL = url
                sheet = .download
            }
        }
        .sheet(isPresented: $sheetPresented) {
            switch sheet {
            case .credentials:
                CredentialsView(webView: webView, sheetPresented: $sheetPresented)
            case .refresh:
                RefreshView(products: $products, webView: webView, sheetPresented: $sheetPresented)
            case .download:
                DownloadView(product: $selectedProduct, downloadLink: $selectedDownloadLink, webView: webView, destinationURL: destinationURL, sheetPresented: $sheetPresented)
            case .none:
                EmptyView()
            }
        }
    }

    private func productTypes() -> [ProductType] {
        hideUnownedProducts ? ProductType.allCases.filter { !products(for: $0).isEmpty } : ProductType.allCases
    }

    private func products(for type: ProductType) -> [Product] {
        products.filter { $0.type == type }.sorted { $0.version.compare($1.version, options: .numeric) == .orderedDescending }
    }

    private func checkForUpdates() {

        guard let url: URL = URL(string: .latestReleaseURL),
            let infoDictionary: [String: Any] = Bundle.main.infoDictionary,
            let version: String = infoDictionary["CFBundleShortVersionString"] as? String else {
            return
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                return
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")

            guard version.compare(latestVersion, options: .numeric) == .orderedAscending else {
                return
            }

            if !requestedAuthorizationForNotifications {
                let notificationCenter: UNUserNotificationCenter = .current()
                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in

                    if let error: Error = error {
                        print(error.localizedDescription)
                        return
                    }

                    requestedAuthorizationForNotifications = true
                    sendUpdateNotification(for: latestVersion)
                }
            } else {
                sendUpdateNotification(for: latestVersion)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func sendUpdateNotification(for version: String) {

        let notificationCenter: UNUserNotificationCenter = .current()
        notificationCenter.getNotificationSettings { settings in

            guard [.authorized, .provisional].contains(settings.authorizationStatus) else {
                return
            }

            let identifier: String = UUID().uuidString

            let content: UNMutableNotificationContent = UNMutableNotificationContent()
            content.title = "Update Available"
            content.body = "Version \(version) is available to download."
            content.sound = .default
            content.categoryIdentifier = UNNotificationCategory.Identifier.update

            let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request: UNNotificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            notificationCenter.add(request) { error in

                if let error: Error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
