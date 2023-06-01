//
//  MemoriesHomeView.swift
//  Memories
//
//  Created by Vincent Ballet on 12/05/2023.
//

import SwiftUI
import WebKit
import Activity
import WidgetKit
import AmplitudeSwift
import ConfettiSwiftUI

struct MemoriesHomeView: View {
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State private var counter: Int = 0
    
    @State private var isShowingWebView: Bool = false
    
    var refreshButtonColor: Color {
        return activityViewModel.isFetching ? .gray : .black
    }
    
    var body: some View {
        
        ZStack {
            
            MemoriesConfettiView(counter: $counter)
                .zIndex(10)
            
            VStack {
                // Spacer -----------------------------------------------------
                Spacer()
                    .frame(minHeight: 10, idealHeight: 40, maxHeight: 80)
                    .fixedSize()
                
                // Header ----------------------------------------------------
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: loginViewModel.athlete!.pictureUrl)) { image in
                        image
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 82, height: 82)
                    .cornerRadius(41)
                    
                    VStack(alignment: .leading) {
                        Text(loginViewModel.athlete!.firstName)
                            .font(.headline).bold()
                        Text(loginViewModel.athlete!.lastName)
                            .font(.headline).bold()
                        
                    }
                }.frame(height: 100)
                
                // Spacer -----------------------------------------------------
                Spacer()
                
                VStack {
                    // Activity widget -----------------------------------------------------
                    if !activityViewModel.isFetching,
                       let activity = activityViewModel.activity {
                        MemoriesWidgetView(loggedIn: true, activity: activity)
                            .frame(width: 292, height: 311)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(12)
                            .shadow(radius: 12)
                        
                        
                    } else {
                        ProgressView()
                            .frame(width: 292, height: 311)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(12)
                        
                    }
                    
                    Button {
                        Task {
                            await self.forceRefreshActivity()
                        }
                    } label: {
                        Label {
                            Text("Your widget preview")
                                .font(.subheadline)
                        }  icon: {
                            Image(systemName: "arrow.clockwise")
                        }.font(.system(size: 12)).foregroundColor(refreshButtonColor)
                    }.disabled(activityViewModel.isFetching)
                        
                    
                    
                    
                }.frame(height: 400)
                
                // Spacer -----------------------------------------------------
                Spacer()
                
                // Add widget button -----------------------------------------------------
                VStack{
                    Button {
                        Amplitude.instance.track(eventType: AnalyticsEvents.addWidgetHelp)
                        isShowingWebView = true
                    } label: {
                        Label {
                            Text("Add widget")
                            
                                .bold()
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }.padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(35)
                    .sheet(isPresented: $isShowingWebView) {
                        SheetView(isShowingWebView: self.$isShowingWebView)
                        
                    }
                }
                .padding()
                
            }.zIndex(1)
            .onAppear{
                // First render
                self.syncActivity()
            }
            .onChange(of: scenePhase) { newPhase in
                // Subsequent renders
                switch newPhase {
                case .active:
                    self.syncActivity()
                default: ()
                }
            }
        }
    }
    
    func syncActivity() {
        Task {
            // Fetch if there is no activity
            // If there is, it might come from the home view, or the widget, just load it
            await self.activityViewModel.loadActivityFromUserDefaultsOrFetch()
            activityViewModel.forceRefreshWidget()
        }
    }
    
    func forceRefreshActivity() async {
        Amplitude.instance.track(eventType: AnalyticsEvents.refreshActivities)
        await activityViewModel.fetchAndStoreRandomActivity()
        counter += 1
        activityViewModel.forceRefreshWidget()
    }
}


struct MemoriesConfettiView : View {
    @Binding var counter: Int

    var body: some View{
        VStack(alignment: .center) {
            Spacer()
            Text("").confettiCannon(counter: $counter, num:1, confettis: [.text("👌"), .text("🚀"), .text("🤩"), .text("🔥")], confettiSize: 20, repetitions: 30, repetitionInterval: 0.1)
            Spacer()
        }
    }
}

struct SheetView : View {
    @Binding var isShowingWebView: Bool
    
    var body: some View{
        NavigationView{
            WebView(url: URL(string: "https://support.apple.com/en-us/HT207122")!)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingWebView = false
                }) {
                    Text("Done").bold()
                })
        }
    }
}


struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
