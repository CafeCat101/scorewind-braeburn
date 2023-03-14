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
	@StateObject var store: Store = Store()
	
	var body: some Scene {
		WindowGroup {
			//GeometryReader { proxy in
				HomeView(downloadManager: downloadManager)
					.environmentObject(scorewindData)
					.environmentObject(store)
					//.environment(\.mainWindowSize, proxy.size)
			//}
			
		}
	}
}

private struct MainWindowSizeKey: EnvironmentKey {
		static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
		var mainWindowSize: CGSize {
				get { self[MainWindowSizeKey.self] }
				set { self[MainWindowSizeKey.self] = newValue }
		}
}
