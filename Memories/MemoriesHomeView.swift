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
import ConfettiSwiftUI
import Crisp
import StoreKit
import PostHog
import AVKit

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
    @State private var isShowingVideoView: Bool = false
    @State private var isChatPresented: Bool = false
    
    @State private var showingOptions = false
    @State private var showingAlert = false
    
    @State private var shouldShowAddWidgetHelp = true


    
    var refreshButtonColor: Color {
        return activityViewModel.isFetching ? .gray : .black
    }
    
    var body: some View {
    
        GeometryReader { proxy in
            
            // Header view
            VStack {
                // Header -----------------------------------------------------
                HStack(spacing: 12) {
                    
                    // App name -----------------------------------------------
                    Text("Memories")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundColor(Color(.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)))
                    
                    // Spacer -----------------------------------------------------
                    Spacer()
                    
                    // Picture ------------------------------------------------
                    ZStack{
                        Button(action: {
                                    showingOptions = true
                                }) {
                                    AsyncImage(url: URL(string: loginViewModel.athlete?.pictureUrl ?? "")) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 42, maxHeight: 42)
                                    } placeholder: {
                                        Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
                                    }
                                    .frame(maxWidth: 42, maxHeight: 42)
                                    .cornerRadius(21)
                                    .zIndex(1)
                                    
                                    
                                }.confirmationDialog("Profile", isPresented: $showingOptions, titleVisibility: .hidden) {


                                    Button("Suggest features") {
                                        self.isChatPresented.toggle()
                                        Analytics.capture(event: .shareFeedback, eventProperties: [.from: "profileFeedbackButton"])
                                    }.sheet(isPresented: self.$isChatPresented) {
                                        ChatView()
                                    }

                                    Button("Logout") {
                                        Analytics.capture(event: .logout)
                                        loginViewModel.logout()
                                    }

                                    Button("Delete my account", role: .destructive) {
                                        Analytics.capture(event: .deleteAccount)
                                        showingAlert = true
                                    }

                                    Button("Cancel", role: .cancel) {}
                                }.alert ("Account deletion", isPresented: $showingAlert) {
                                    Button("OK", role: .destructive) {
                                        Analytics.capture(event: .confirmDeleteAccount)
                                        Task { await
                                            loginViewModel.deleteAccount()
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }message: {
                                    Text("Are you sure? This action is irreversible.")
                                }
                        
                                StravaIconView().zIndex(10)
                        
                    }
                    
                }.padding()
                
                Spacer()
                
            }.zIndex(5)
            
            ScrollView{
                ZStack {
                    
                    MemoriesConfettiView(runConfetti: $runConfetti, bikeConfetti: $bikeConfetti, hikeConfetti: $hikeConfetti, skiConfetti: $skiConfetti, otherConfetti: $otherConfetti)
                        .zIndex(10)
                    
                    VStack {
                        
                        // Spacer -----------------------------------------------------
                        Spacer()
                        
                        VStack(spacing: 18.0) {
                            
                            // TODO : 700 is a random value
                            if proxy.size.height > 700 {
                                HStack {
                                    RowIcon(row: -3)
                                    Spacer()
                                    RowIcon(row: -3)
                                    Spacer()
                                    RowIcon(row: -3)
                                    Spacer()
                                    RowIcon(row: -3)
                                    
                                }.frame(maxWidth: .infinity)
                            }
                            
                            HStack {
                                RowIcon(row: -2)
                                Spacer()
                                RowIcon(row: -2)
                                Spacer()
                                RowIcon(row: -2)
                                Spacer()
                                RowIcon(row: -2)
                                
                            }.frame(maxWidth: .infinity)
                            
                            HStack {
                                RowIcon(row: -1)
                                Spacer()
                                RowIcon(row: -1)
                                Spacer()
                                RowIcon(row: -1)
                                Spacer()
                                RowIcon(row: -1)
                                
                            }.frame(maxWidth: .infinity)
                                .padding(.bottom)
                        }
                        
                        VStack {
                            // Activity widget -----------------------------------------------------
                            if !activityViewModel.isFetching,
                               let activity = activityViewModel.activity {
                                MemoriesWidgetView(loggedIn: true, activity: activity)
                                    .frame(height: 162)
                                    .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 18)
                                
                                
                                // Loading view ------------------------------------------------
                            } else {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 162, idealHeight: 162, maxHeight: 162)
                                    .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
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
                            
                        }
                    
                        
                        VStack(spacing: 18.0) {
                            HStack {
                                RowIcon(row: 1)
                                Spacer()
                                RowIcon(row: 1)
                                Spacer()
                                RowIcon(row: 1)
                                Spacer()
                                RowIcon(row: 1)

                            }.frame(maxWidth: .infinity)

                            HStack {
                                RowIcon(row: 2)
                                Spacer()
                                RowIcon(row: 2)
                                Spacer()
                                RowIcon(row: 2)
                                Spacer()
                                RowIcon(row: 2)

                            }.frame(maxWidth: .infinity)

                            HStack {
                                RowIcon(row: 3)
                                Spacer()
                                RowIcon(row: 3)
                                Spacer()
                                RowIcon(row: 3)
                                Spacer()
                                RowIcon(row: 3)

                            }.frame(maxWidth: .infinity)
                        }
                        
                        
                        // Spacer -----------------------------------------------------
                        Spacer()
                        
                    }
                    .zIndex(1) // VStack content view
                    .padding([.leading, .trailing], 28)
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
                            
                            // request review
                            // trigger is widget count > 0 && did not ask before
                            WidgetCenter.shared.getCurrentConfigurations { result in
                                
                                if let results = try? result.get(),
                                    results.count > 0 {
                                    self.shouldShowAddWidgetHelp = false
                                    self.triggerAskForReview()
                                    
                                } else {
                                    self.shouldShowAddWidgetHelp = true
                                }
                        
                            }
                        default: ()
                        }
                    }
                    
                }.onAppear {
                    Analytics.capture(event: .viewHomeScreen)
                }
            } // ScrollView
            
            VStack { // Buttons  -----------------------------------------------------
                
                Spacer()
                
                // Add widget button -----------------------------------------------------
                VStack{
                    
                    if shouldShowAddWidgetHelp{
                        Button {
                            if let ff = PHGPostHog.shared()?.getFeatureFlag(("activate-widget-gif")) as? Int,
                               ff == 0 {
                                Analytics.capture(event: .addWidgetHelp, eventProperties: [.abTestGroup: "0_webView"])
                                isShowingWebView = true
                            } else {
                                Analytics.capture(event: .addWidgetHelp, eventProperties: [.abTestGroup: "1_videoView"])
                                isShowingVideoView = true
                            }
                                
                            


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
                        .sheet(isPresented: $isShowingWebView) {
                            SheetWebView(isShowingWebView: self.$isShowingWebView)
                        }
                        .sheet(isPresented: $isShowingVideoView) {
                            SheetVideoView(isShowingVideoView: self.$isShowingVideoView)
                        }
                    }
                    
                    Button {
                        self.isChatPresented.toggle()
                        Analytics.capture(event: .shareFeedback, eventProperties: [.from: "homeFeedbackButton"])
                    } label: {
                        Label {
                            Text("Suggest features").bold()
                        } icon: {
                            Image(systemName: "lightbulb.fill")
                        }.padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(35)
                    .sheet(isPresented: self.$isChatPresented) {
                        ChatView()
                    }
                }.padding([.leading, .trailing], 18)
                
                // Spacer -----------------------------------------------------
                Spacer()
                    .frame(minHeight: 10, idealHeight: 30, maxHeight: 60)
                    .fixedSize()
                
                
            }.zIndex(5)
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
        Analytics.capture(event: .refreshActivities)
        
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
    
    private func triggerAskForReview(){
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        
        // Get the current bundle version for the app.
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { fatalError("Expected to find a bundle version in the info dictionary.") }
        
        // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
        if currentVersion != lastVersionPromptedForReview {
            Task { @MainActor in
                // Delay for five seconds to avoid interrupting the person using the app.
                // Use the equation n * 10^9 to convert seconds to nanoseconds.
                
                try? await Task.sleep(nanoseconds: UInt64(5e9))

                
                let allScenes = UIApplication.shared.connectedScenes
                let scene = allScenes.first { $0.activationState == .foregroundActive }
                if let windowScene = scene as? UIWindowScene {
                    Analytics.capture(event: .systemAskForReview)
                    SKStoreReviewController.requestReview(in: windowScene)
                    UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
                }
            }
        }
    }
}

struct RowIcon : View {
    var row: Int
    
    init(row: Int) {
        self.row = row
    }
    
    var rowColors : [Color] {
        switch (row){
        case -3 :
            return [Helper.gradientEnd, Helper.gradientStepTwo.opacity(0.97)]
        case -2 :
            return [Helper.gradientStepTwo.opacity(1.03), Helper.gradientStepOne.opacity(0.97)]
        case -1 :
            return [Helper.gradientStepOne.opacity(1.03), Helper.gradientStart]
        case 1 :
            return [Helper.gradientStart, Helper.gradientStepOne.opacity(1.03)]
        case 2 :
            return [Helper.gradientStepOne.opacity(0.97), Helper.gradientStepTwo.opacity(1.03)]
        case 3 :
            return [Helper.gradientStepTwo.opacity(0.97), Helper.gradientEnd]
        default : return [Helper.gradientStart, Helper.gradientEnd]
        }
        
    }
    
    var body: some View{
        Rectangle()
            .fill(LinearGradient(
                gradient: .init(colors: rowColors),
                startPoint: .init(x: 0.5, y: 0), endPoint: .init(x: 0.5, y: 1)))
            .frame(width: 64, height: 64)
            .cornerRadius(12)
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
                    .frame(width: 12, height: 12)
                    .cornerRadius(4)
            }
        }.frame(width: 42, height: 42)
    }
}

struct SheetWebView : View {
    @Binding var isShowingWebView: Bool

    var body: some View{
        NavigationView{
            WebView(url: URL(string: NSLocalizedString("url_help_widget", comment: "comment"))!)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingWebView = false
                }) {
                    Text("Done").bold()
                })
        }
    }
}

struct SheetVideoView : View {
    @Binding var isShowingVideoView: Bool
    @State private var player = AVPlayer(url: URL(string: "https://github.com/ikigai-fyi/Memories/raw/main/Assets/addWidgetHelp.mp4")!)

    var body: some View{
        NavigationView{
            
            VideoPlayer(player: player)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingVideoView = false
                }) {
                    Text("Done").bold()
                })
                .onAppear{
                    
                    player.play()
                    player.seek(to: .zero)
                }
        }
    }
}



struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
