//
//  VideoClipLoopView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/31.
//
//URL(fileURLWithPath: "Ricardo_Notestand_TapA_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")

import SwiftUI
import AVKit
import AVFoundation
/*
struct VideoClipLoopView: View {
	var videoURL: URL?
		var body: some View {
				VStack {
					VideoPlayerView(videoURL: videoURL!)
				}
		}
}

struct VideoPlayerView: UIViewControllerRepresentable {
	var videoURL: URL?
		class Coordinator: NSObject {
				var queuePlayer: AVQueuePlayer?
				var looper: AVPlayerLooper?
				
				@objc func playerItemDidReachEnd(_ notification: Notification) {
						// Seek to the beginning when the video reaches the end
						queuePlayer?.seek(to: .zero)
				}
		}
		
		func makeCoordinator() -> Coordinator {
				Coordinator()
		}
		
		func makeUIViewController(context: Context) -> AVPlayerViewController {
				// Get the URL of the video file from the main bundle
				/*guard let videoURL = Bundle.main.url(forResource: "Ricardo_Notestand_TapA_UltraHD", withExtension: "mp4") else {
						fatalError("Video file not found in the main bundle.")
				}*/
				//let videoURL = URL(fileURLWithPath: "Ricardo_Notestand_TapA_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")
				
				// Create an AVPlayerItem from the URL
			let playerItem = AVPlayerItem(url: videoURL!)
				
				// Create an AVQueuePlayer and add the AVPlayerItem to it
				let queuePlayer = AVQueuePlayer(playerItem: playerItem)
				
				// Create an AVPlayerLooper to loop the video
				let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
				
				// Start playing the video
				queuePlayer.play()
				
				// Create an AVPlayerViewController to display the video
				let playerViewController = AVPlayerViewController()
				playerViewController.player = queuePlayer
				
				// Set up coordinator to handle looping
				let coordinator = context.coordinator
				coordinator.queuePlayer = queuePlayer
				coordinator.looper = looper
				
				// Observe the end of the video to trigger looping
				NotificationCenter.default.addObserver(
						coordinator,
						selector: #selector(Coordinator.playerItemDidReachEnd(_:)),
						name: .AVPlayerItemDidPlayToEndTime,
						object: playerItem
				)
				
				return playerViewController
		}
		
		func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
				// Update the view controller if needed (not used in this example)
		}
}
*/




















/*
 struct VideoClipLoopView: View {
 @State private var tipVideo:AVPlayer?
 var videoUrl: URL?
 var videoLength: Double = 1.0
 
 var body: some View {
 VStack {
 VideoPlayer(player: tipVideo)
 .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
 .frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
 .shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
 .padding([.leading, .trailing], 15)
 .onAppear(perform: {
 
 })
 }
 .onAppear(perform: {
 //tipVideo = AVPlayer(url: URL(fileURLWithPath: "DIY_Notestannd_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4"))
 print("\(videoUrl!.path)")
 tipVideo = AVPlayer(url: videoUrl!)
 
 tipVideo!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
 if time.seconds > videoLength {
 tipVideo!.pause()
 tipVideo!.seek(to: .zero)
 tipVideo!.play()
 }
 })
 
 tipVideo?.play()
 })
 .onDisappear(perform: {
 tipVideo?.pause()
 tipVideo = nil
 })
 }
 }
 
 struct VideoClipLoopView_Previews: PreviewProvider {
 static var previews: some View {
 VideoClipLoopView()
 }
 }
 */
