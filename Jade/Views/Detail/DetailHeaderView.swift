//
//  DetailHeaderView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailHeaderView: View {
    @Environment(\.openURL) var openURL: OpenURLAction
    var productType: ProductType
    @State private var hovering: Bool = false
    private let leadingImageLength: CGFloat = 48
    private let trailingImageLength: CGFloat = 32
    private var systemName: String {
        hovering ? "link.circle.fill" : "link.circle"
    }

    var body: some View {
        GroupBox {
            HStack {
                ImageView(systemName: productType.systemName, length: leadingImageLength, color: .accentColor)
                Text(productType.description)
                    .font(.title)
                Spacer()
                Button(action: {
                    visitWebsite()
                }, label: {
                    ImageView(systemName: systemName, length: trailingImageLength, color: .blue)
                })
                .buttonStyle(.plain)
                .help("Visit Website")
                .onHover { hovering in
                    self.hovering = hovering
                }
            }
            .padding()
        }
    }

    private func visitWebsite() {

        guard let url: URL = URL(string: productType.homepage) else {
            return
        }

        openURL(url)
    }
}

struct DetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DetailHeaderView(productType: .jamfPro)
    }
}
