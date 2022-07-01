//
//  ScoreWindApp.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/7/1.
//

import SwiftUI

@main
struct ScoreWindApp: App {
	@StateObject var scorewindData = ScorewindData()
	@StateObject var downloadManager = DownloadManager()
	
	var body: some Scene {
		WindowGroup {
			HomeView(downloadManager: downloadManager)
				.environmentObject(scorewindData)
		}
	}
}
