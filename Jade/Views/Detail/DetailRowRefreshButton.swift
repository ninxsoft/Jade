//
//  DetailRowRefreshButton.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailRowRefreshButton: View {
    var product: Product
    @Binding var downloadLinks: [DownloadLink]
    @State private var refreshing: Bool = false
    @State private var hovering: Bool = false
    @State private var rotationAmount: Double = 0
    private let length: CGFloat = 32
    private var systemName: String {
        hovering ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle"
    }

    var body: some View {
        Button(action: {
            Task {
                refreshing = true
                rotationAmount = 360
                await retrieveDownloadLinks()
                refreshing = false
            }
        }, label: {
            ImageView(systemName: systemName, length: length, color: .accentColor)
        })
        .buttonStyle(.plain)
        .help("Refresh Download Links")
        .rotationEffect(.degrees(rotationAmount))
        .animation(.easeOut(duration: 2), value: rotationAmount)
        .disabled(refreshing)
        .onHover { hovering in
            self.hovering = hovering
        }
    }

    func retrieveDownloadLinks() async {

        guard let url: URL = product.downloadLinksURL else {
            return
        }

        do {
            let (data, _): (Data, URLResponse) = try await URLSession.shared.data(from: url)
            let downloadLinks: [DownloadLink] = try JSONDecoder().decode([DownloadLink].self, from: data)
            self.downloadLinks = downloadLinks.sorted { $0.formattedTitle < $1.formattedTitle }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct DetailRowRefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        DetailRowRefreshButton(product: .example, downloadLinks: .constant([.example]))
    }
}
