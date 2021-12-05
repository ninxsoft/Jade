//
//  SidebarRowView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct SidebarRowView: View {
    var productType: ProductType
    private let length: CGFloat = 24
    private let padding: CGFloat = 5

    var body: some View {
        HStack {
            ImageView(systemName: productType.systemName, length: length, color: .primary)
            Text(productType.description)
                .bold()
        }
        .padding(padding)
    }
}

struct SidebarRowView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarRowView(productType: .jamfPro)
    }
}
