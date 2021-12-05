//
//  TagView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct TagView: View {
    var text: String
    var backgroundColor: Color
    private let padding: CGFloat = 5
    private let cornerRadius: CGFloat = 5

    var body: some View {
        Text(text)
            .bold()
            .padding(padding)
            .foregroundColor(.white)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(text: "Current", backgroundColor: .blue)
    }
}
