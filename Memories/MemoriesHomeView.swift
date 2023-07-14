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
import PostHog

struct MemoriesHomeView: View {
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State private var runConfetti: Int = 0
    @State private var bikeConfetti: Int = 0
    @State private var hikeConfetti: Int = 0
    @State private var skiConfetti: Int = 0
    @State private var otherConfetti: Int = 0
    
    @State private var isShowingWebView: Bool = false
    
    var refreshButtonColor: Color {
        return activityViewModel.isFetching ? .gray : .black
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView{
                ZStack {
                    
                    MemoriesConfettiView(runConfetti: $runConfetti, bikeConfetti: $bikeConfetti, hikeConfetti: $hikeConfetti, skiConfetti: $skiConfetti, otherConfetti: $otherConfetti)
                        .zIndex(10)
                    
                    // Content view
                    VStack {
                        
                        // Spacer -----------------------------------------------------
                        Spacer()
                            .frame(minHeight: 10, idealHeight: 40, maxHeight: 80)
                            .fixedSize()
                        
                        // Header -----------------------------------------------------
                        HStack(spacing: 12) {
                            
                            // Picture ------------------------------------------------
                            ZStack{
                                AsyncImage(url: URL(string: loginViewModel.athlete!.pictureUrl)) { image in
                                    image
                                } placeholder: {
                                    Color.gray.opacity(0.1)
                                }
                                .frame(width: 54, height: 54)
                                .cornerRadius(27)
                                .zIndex(1)
                                
                                StravaIconView()
                                    .zIndex(10)
                                
                            }
                            
                            // Name ---------------------------------------------------
                            VStack(alignment: .leading) {
                                Text(loginViewModel.athlete!.firstName)
                                    .font(.headline).bold()
                                Text(loginViewModel.athlete!.lastName)
                                    .font(.headline).bold()
                                
                            }
                        }.frame(height: 100)
                        
                        if Config.env == "dev" {
                            Button("Logout (dev only - will crash)") {
                                self.loginViewModel.logout()
                            }
                        }
                        
                        // Spacer -----------------------------------------------------
                        Spacer()
                        
                        VStack {
                            // Activity widget -----------------------------------------------------
                            if !activityViewModel.isFetching,
                               let activity = activityViewModel.activity {
                                MemoriesWidgetView(loggedIn: true, activity: activity)
                                    .frame(width: 292, height: 311)
                                    .background(.gray.opacity(0.05))
                                    .cornerRadius(20)
                                    .shadow(radius: 18)
                                
                                
                                // Loading view ------------------------------------------------
                            } else {
                                ProgressView()
                                    .frame(width: 292, height: 311)
                                    .background(.gray.opacity(0.1))
                                    .cornerRadius(12)
                                
                            }
                            
                            // Refresh widget ------------------------------------------------
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
                                PHGPostHog.shared()?.capture(AnalyticsEvents.addWidgetHelp)

                                isShowingWebView = true
                            } label: {
                                Label {
                                    Text("Add widget").bold()
                                } icon: {
                                    Image(systemName: "plus.circle.fill")
                                }.padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(35)
                            .padding()
                            .sheet(isPresented: $isShowingWebView) {
                                SheetView(isShowingWebView: self.$isShowingWebView)
                                
                            }
                        }.padding([.leading, .trailing], 18)
                        
                        Spacer()
                            .frame(minHeight: 10, idealHeight: 18, maxHeight: 36)
                            .fixedSize()
                        
                        
                        
                    }.zIndex(1) // VStack content view
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height) // fix height scrollview
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
            } // ScrollView
        } // GeometryView
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
        PHGPostHog.shared()?.capture(AnalyticsEvents.refreshActivities)

        
        await activityViewModel.fetchAndStoreRandomActivity()
        activityViewModel.forceRefreshWidget()
        self.triggerConfettis()
    }
    
    private func triggerConfettis() {
        switch self.activityViewModel.activity?.getSportType() {
        case "Run": self.runConfetti += 1
        case "Ride": self.bikeConfetti += 1
        case "AlpineSki", "NordicSki": self.skiConfetti += 1
        case "Hike": self.hikeConfetti += 1
        case nil: ()
        default: self.otherConfetti += 1
        }
    }
}


struct MemoriesConfettiView : View {
    @Binding var runConfetti: Int
    @Binding var bikeConfetti: Int
    @Binding var hikeConfetti: Int
    @Binding var skiConfetti: Int
    @Binding var otherConfetti: Int
    
    private func ConfettiView(binding: Binding<Int>, specificEmojis: [String]) -> some View {
        return Text("").confettiCannon(
            counter: binding,
            num: 1,
            confettis: (specificEmojis + ["🥇", "🔥"]).map {.text($0)},
            confettiSize: 20,
            repetitions: 30,
            repetitionInterval: 0.1
        )
    }
    
    var body: some View{
        VStack(alignment: .center) {
            Spacer()
            ConfettiView(binding: $runConfetti, specificEmojis: ["🏃‍♀️", "🏃", "🏃‍♂️", "👟"])
            ConfettiView(binding: $bikeConfetti, specificEmojis: ["🚴‍♀️", "🚴", "🚴‍♂️", "🚵‍♀️", "🚵", "🚵‍♂️"])
            ConfettiView(binding: $hikeConfetti, specificEmojis: ["🥾", "🏔️"])
            ConfettiView(binding: $skiConfetti, specificEmojis: ["⛷️", "🎿"])
            ConfettiView(binding: $otherConfetti, specificEmojis: ["🏃‍♀️", "🚴‍♀️", "⛷️", "🏋️‍♀️"])
            Spacer()
        }
    }
}

struct StravaIconView : View {
    var body: some View{
        HStack{
            Spacer()
            VStack{
                Spacer()
                Image("Strava")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .cornerRadius(4)
            }
        }.frame(width: 54, height: 54)
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
