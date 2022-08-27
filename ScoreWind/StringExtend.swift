//
//  StringExtend.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/8/27.
//

import Foundation
extension String {

		func stripOutHtml() -> String? {
				do {
						guard let data = self.data(using: .unicode) else {
								return nil
						}
						let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
						return attributed.string
				} catch {
						return nil
				}
		}
}
