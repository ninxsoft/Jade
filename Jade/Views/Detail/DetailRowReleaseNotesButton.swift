//
//  DetailRowReleaseNotesButton.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailRowReleaseNotesButton: View {
    @Environment(\.openURL) var openURL: OpenURLAction
    var product: Product
    @State private var hovering: Bool = false
    private let length: CGFloat = 32
    private var systemName: String {
        hovering ? "book.circle.fill" : "book.circle"
    }

    var body: some View {
        Button(action: {
            openReleaseNotes()
        }, label: {
            ImageView(systemName: systemName, length: length, color: .accentColor)
        })
        .buttonStyle(.plain)
        .help("Release Notes")
        .onHover { hovering in
            self.hovering = hovering
        }
    }

    func openReleaseNotes() {

        if let releaseNotes: String = product.releaseNotes,
            !releaseNotes.isEmpty,
            let url: URL = URL(string: releaseNotes) {
            openURL(url)
        } else if let url: URL = URL(string: product.type.homepage) {
            openURL(url)
        }
    }
}

struct DetailRowReleaseNotesButton_Previews: PreviewProvider {
    static var previews: some View {
        DetailRowReleaseNotesButton(product: .example)
    }
}
