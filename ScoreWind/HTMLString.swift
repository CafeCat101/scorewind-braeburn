//
//  HTMLString.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/11.
//

import Foundation
import SwiftUI
import WebKit

struct HTMLString: UIViewRepresentable {
	let htmlContent: String
	
	func makeUIView(context: Context) -> WKWebView {
		/*let webView = WKWebView()
		webView.loadHTMLString("<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><style>:root {font: -apple-system-body;}</style>"+htmlContent, baseURL: nil)
		return webView*/
		return WKWebView()
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
				print("class HTMLString updateUIView")
		uiView.loadHTMLString("<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><style>:root {font: -apple-system-body;background-color: rgb(237,237,237);}.myContent{padding:0px 15px 10px 15px}@media (prefers-color-scheme: dark) {:root {background-color: rgb(38,38,41);color: rgb(214,205,194);}}</style><div class='myContent'>"+htmlContent+"</div>", baseURL: nil)
	}
}
