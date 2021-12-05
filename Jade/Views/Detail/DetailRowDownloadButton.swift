//
//  DetailRowDownloadButton.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailRowDownloadButton: View {
    var product: Product
    var downloadLink: DownloadLink
    @Binding var selectedProduct: Product?
    @Binding var selectedDownloadLink: DownloadLink?
    @State private var hovering: Bool = false
    private let length: CGFloat = 32
    private var systemName: String {
        hovering ? "\(downloadLink.systemName).fill" : downloadLink.systemName
    }

    var body: some View {
        Button(action: {
            selectedProduct = product
            selectedDownloadLink = downloadLink
        }, label: {
            ImageView(systemName: systemName, length: length, color: .blue)
        })
        .buttonStyle(.plain)
        .help(downloadLink.formattedTitle)
        .onHover { hovering in
            self.hovering = hovering
        }
    }
}

struct DetailRowDownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DetailRowDownloadButton(product: .example, downloadLink: .example, selectedProduct: .constant(.example), selectedDownloadLink: .constant(.example))
    }
}
