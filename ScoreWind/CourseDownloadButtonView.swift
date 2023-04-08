//
//  CourseDownloadButtonView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/1.
//

import SwiftUI

struct CourseDownloadButtonView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	var getStatus:DownloadStatus
	@ObservedObject var downloadManager:DownloadManager
	@State private var showDownloadAlert = false
	@Binding var showStoreView: Bool
	
	
	var body: some View {
		Button(action: {
			if store.purchasedSubscriptions.isEmpty {
				showStoreView = true
			} else {
				showDownloadAlert = true
			}
		}, label: {
			if getStatus == DownloadStatus.downloading {
				DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("Dynamic/IconHighlighted"), iconSystemImage: "stop.fill")
					.frame(maxWidth: 35, maxHeight:20)
			} else {
				Label("Downloaded", systemImage: getStatusIconName())
					.labelStyle(.iconOnly)
					.foregroundColor(getStatus == DownloadStatus.downloaded ? Color("Dynamic/IconHighlighted") : Color("Dynamic/MainBrown+6"))
					.frame(maxWidth: 35, maxHeight:20)
			}
		})
		.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
		.background(
			RoundedRectangle(cornerRadius: CGFloat(17))
				.foregroundColor(Color("Dynamic/MainBrown"))
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				.opacity(0.25)
				.overlay {
					RoundedRectangle(cornerRadius: 17)
						.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
				}
		)
		.alert("\(getAlertDialogTitle(downloadStatus:getStatus))", isPresented: $showDownloadAlert, actions: {
			Button("ok", action:{
				print("[debug] CourseView, alert ok.")
				showDownloadAlert = false
				downloadManager.addOrRemoveCourseOffline(currentCourseDownloadStatus: getStatus, courseID: scorewindData.currentCourse.id, lessons: scorewindData.currentCourse.lessons)
				
				
				if downloadManager.downloadingCourse == 0 && getStatus == DownloadStatus.notInQueue {
					Task {
						print("[debug] download all Task")
						do {
							try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
						} catch {
							print("[debug] download all, catch, \(error)")
						}
						
					}
				} else {
					print("[debug] downloadVideoXML task is running.")
				}
				
			})
			Button("Cancel", role:.cancel, action:{
				showDownloadAlert = false
			})
		}, message: {
			if getStatus == DownloadStatus.notInQueue {
				Text("All videos and socres in this course will be downloaded into your device. Continue?")
			} else {
				Text("After removing downloads, you can not take course offline. Continue?")
			}
		})
		
		
		/*
		Label("Downloaded", systemImage: getStatusIconName())
			.labelStyle(.iconOnly)
			.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					.opacity(0.25)
					.overlay {
						RoundedRectangle(cornerRadius: 17)
							.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
					}
			)
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.onTapGesture {
				if store.purchasedSubscriptions.isEmpty {
					showSubscriberOnlyAlert = true
				} else {
					showDownloadAlert = true
				}
			}
			.alert("\(getAlertDialogTitle(downloadStatus:getStatus))", isPresented: $showDownloadAlert, actions: {
				Button("ok", action:{
					print("[debug] CourseView, alert ok.")
					showDownloadAlert = false
					downloadManager.addOrRemoveCourseOffline(currentCourseDownloadStatus: getStatus, courseID: scorewindData.currentCourse.id, lessons: scorewindData.currentCourse.lessons)
					
					
					if downloadManager.downloadingCourse == 0 && getStatus == DownloadStatus.notInQueue {
						Task {
							print("[debug] download all Task")
							do {
								try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
							} catch {
								print("[debug] download all, catch, \(error)")
							}
							
						}
					} else {
						print("[debug] downloadVideoXML task is running.")
					}
					
				})
				Button("Cancel", role:.cancel, action:{
					showDownloadAlert = false
				})
			}, message: {
				if getStatus == DownloadStatus.notInQueue {
					Text("All videos and socres in this course will be downloaded into your device. Continue?")
				} else {
					Text("After removing downloads, you can not take course offline. Continue?")
				}
			})
		*/
		/*
		HStack {
			if getStatus == DownloadStatus.notInQueue {
				Image(systemName: "arrow.down.to.line.circle")
					.foregroundColor(Color("AppYelloDynamic"))
			} else if getStatus == DownloadStatus.inQueue {
				Image(systemName: "arrow.down.square")
					.foregroundColor(Color.gray)
			} else if getStatus == DownloadStatus.downloading {
				Image(systemName: "square.and.arrow.down.on.square.fill")
					.foregroundColor(.blue)
			} else if getStatus == DownloadStatus.downloaded {
				Image(systemName: "arrow.down.square.fill")
					.foregroundColor(Color.green)
			} else if getStatus == DownloadStatus.failed {
				Image(systemName: "exclamationmark.square")
					.foregroundColor(Color.green)
			}
			
			Button(action: {
				showDownloadAlert = true
			}) {
				if getStatus == DownloadStatus.notInQueue {
					Text("Download course for offline")
						.foregroundColor(Color("AppYelloDynamic"))
				} else {
					Text("Remove downloads")
						.foregroundColor(Color("AppYelloDynamic"))
				}
			}
			.alert("\(getAlertDialogTitle(downloadStatus:getStatus))", isPresented: $showDownloadAlert, actions: {
				Button("ok", action:{
					print("[debug] CourseView, alert ok.")
					showDownloadAlert = false
					downloadManager.addOrRemoveCourseOffline(currentCourseDownloadStatus: getStatus, courseID: scorewindData.currentCourse.id, lessons: scorewindData.currentCourse.lessons)
					if downloadManager.downloadingCourse == 0 && getStatus == DownloadStatus.notInQueue {
						Task {
							print("[debug] download all Task")
							do {
								try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
							} catch {
								print("[debug] download all, catch, \(error)")
							}
							
						}
					} else {
						print("[debug] downloadVideoXML task is running.")
					}
					
				})
				Button("Cancel", role:.cancel, action:{
					showDownloadAlert = false
				})
			}, message: {
				if getStatus == DownloadStatus.notInQueue {
					Text("128 MB course content will be downloaded into your device. Continue?")
				} else {
					Text("After removing downloads, you can not take course offline. Continue?")
				}
			})
		}
		.padding()
		.background{
			RoundedRectangle(cornerRadius: 10)
				.stroke(Color("downloadCourse"), lineWidth:1)
		}
		*/
	}
	
	private func getAlertDialogTitle(downloadStatus: DownloadStatus) -> String {
		if downloadStatus == DownloadStatus.notInQueue {
			return "Download course"
		} else {
			return "Remove download"
		}
	}
	
	private func getStatusIconName() -> String {
		if getStatus == DownloadStatus.inQueue {
			return "arrow.down.to.line.compact"
		} else if getStatus == DownloadStatus.downloading {
			return "stop.circle"
		} else if getStatus == DownloadStatus.downloaded {
			return "arrow.down.circle.fill"
		} else if getStatus == DownloadStatus.failed {
			return "exclamationmark.circle.fill"
		} else {
			//not in queue
			return "arrow.down.circle"
		}
	}
	
}

struct CourseDownloadButtonView_Previews: PreviewProvider {
	static var previews: some View {
		CourseDownloadButtonView(getStatus: DownloadStatus.notInQueue, downloadManager: DownloadManager(), showStoreView: .constant(false)).environmentObject(ScorewindData())
	}
}
