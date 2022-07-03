//
//  BlankTabView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/7/3.
//

import SwiftUI

struct BlankTabView: View {
	@State var message = ""
    var body: some View {
        Text(message)
    }
}

struct BlankTabView_Previews: PreviewProvider {
    static var previews: some View {
        BlankTabView()
    }
}
