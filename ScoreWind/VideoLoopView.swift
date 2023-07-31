//
//  VideoLoopView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/31.
//
//URL(fileURLWithPath: "Ricardo_Notestand_TapA_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")
import SwiftUI
import AVKit

struct VideoLoopView: View {
	@State private var playerLooper: AVPlayerLooper?
	@State private var videoPlayer: AVQueuePlayer?
	
	// Define URL property
	var videoURL:URL?
	
	var body: some View {
		VideoPlayer(player: videoPlayer)
			.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
			.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		//.edgesIgnoringSafeArea(.all)
			.onAppear {
				if let videoURL = videoURL {
					let item = AVPlayerItem(url: videoURL)
					videoPlayer = AVQueuePlayer(playerItem: item)
					playerLooper = AVPlayerLooper(player: videoPlayer!, templateItem: item)
					videoPlayer?.play()
				}
			}
			.onDisappear(perform: {
				videoPlayer = nil
			})
	}
}
