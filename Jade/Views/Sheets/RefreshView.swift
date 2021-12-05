//
//  RefreshView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct RefreshView: View {
    @Binding var products: [Product]
    @ObservedObject var webView: WebView
    @Binding var sheetPresented: Bool
    @State private var refreshing: Bool = false
    @State private var error: Bool = false
    private let width: CGFloat = 300
    private let height: CGFloat = 100

    var body: some View {
        VStack {
            Text("Refreshing Products...")
                .foregroundColor(.primary)
                .font(.title2)
            ProgressView()
                .progressViewStyle(.linear)
                .padding(.horizontal)
            if error {
                Text("There was an error refreshing Jamf Products.")
                    .foregroundColor(.red)
            }
            Spacer()
            Button(refreshing ? "Cancel" : "Close") {
                webView.stopLoading()
                sheetPresented = false
            }
        }
        .frame(width: width, height: height)
        .padding()
        .onAppear {
            Task {
                await refreshProducts()
            }
        }
        .onChange(of: webView.cookie) { _ in
            Task {
                await refreshProducts()
            }
        }
    }

    private func refreshProducts() async {

        refreshing = true

        guard let cookie: HTTPCookie = webView.cookie else {
            webView.refreshCookie()
            return
        }

        HTTPCookieStorage.shared.setCookie(cookie)

        var products: [Product] = []

        for productType in ProductType.allURLCases {

            guard let url: URL = productType.url else {
                continue
            }

            do {
                let urlSession: URLSession = URLSession(configuration: .default)
                let (data, _): (Data, URLResponse) = try await urlSession.data(from: url)

                if let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let message: String = dictionary["message"] as? String,
                    message == "User does not own product" {
                    continue
                }

                let array: [Product] = try JSONDecoder().decode([Product].self, from: data)
                array.forEach { product in
                    if !products.map({ $0.id }).contains(product.id) {
                        products.append(product)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        self.products = products
        refreshing = false
        sheetPresented = false
    }
}

struct RefreshView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshView(products: .constant([.example]), webView: WebView(), sheetPresented: .constant(true))
    }
}
