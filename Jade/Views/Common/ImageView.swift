//
//  ImageView.swift
//  Jade
//
//  Created by Nindi Gill on 4/12/21.
//

import SwiftUI

struct ImageView: View {
    var systemName: String
    var length: CGFloat
    var color: Color

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: length, height: length)
            .foregroundColor(color)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(systemName: "link.circle", length: 32, color: .accentColor)
    }
}
