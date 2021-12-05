//
//  DetailRowView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailRowView: View {
    var product: Product
    @State private var downloadLinks: [DownloadLink] = []
    @Binding var selectedProduct: Product?
    @Binding var selectedDownloadLink: DownloadLink?
    @State private var scaleAmount: Double = 0

    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.version)
                            .font(.title2)
                        if product.current {
                            TagView(text: "Current", backgroundColor: .blue)
                        }
                        if product.hotfix {
                            TagView(text: "Hotfix", backgroundColor: .red)
                        }
                    }
                    if let releaseDate: String = product.releaseDate, !releaseDate.isEmpty {
                        Text(formattedDate(for: releaseDate))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ForEach(downloadLinks) { downloadLink in
                    DetailRowDownloadButton(product: product, downloadLink: downloadLink, selectedProduct: $selectedProduct, selectedDownloadLink: $selectedDownloadLink)
                        .scaleEffect(scaleAmount)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: scaleAmount)
                }
                DetailRowReleaseNotesButton(product: product)
                DetailRowRefreshButton(product: product, downloadLinks: $downloadLinks)
            }
            .padding()
        }
        .onChange(of: downloadLinks) { downloadLinks in
            scaleAmount = downloadLinks.isEmpty ? 0 : 1
        }
    }

    private func formattedDate(for releaseDate: String) -> String {

        let iso8601DateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        guard let date: Date = iso8601DateFormatter.date(from: releaseDate) else {
            return ""
        }

        let string: String = dateFormatter.string(from: date)
        return string
    }
}

struct DetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        DetailRowView(product: .example, selectedProduct: .constant(.example), selectedDownloadLink: .constant(.example))
    }
}
