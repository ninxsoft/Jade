//
//  DetailView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct DetailView: View {
    var productType: ProductType
    var products: [Product]
    @Binding var selectedProduct: Product?
    @Binding var selectedDownloadLink: DownloadLink?
    private let padding: CGFloat = 100

    var body: some View {
        VStack {
            DetailHeaderView(productType: productType)
            if !products.isEmpty {
                HStack {
                    Text("Available Versions:")
                        .font(.title3)
                    Spacer()
                }
                .padding(.top)
                ScrollView(.vertical) {
                    ForEach(products) { product in
                        DetailRowView(product: product, selectedProduct: $selectedProduct, selectedDownloadLink: $selectedDownloadLink)
                    }
                }
            } else {
                GroupBox {
                    Text("Unable to find any \(productType.description) Assets 😞\n\nVerify your Jamf ID credentials are correct and that your\n\(productType.description) subscription is valid.")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(padding)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(productType: .jamfPro, products: [.example], selectedProduct: .constant(.example), selectedDownloadLink: .constant(.example))
    }
}
