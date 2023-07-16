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
    @State private var isChatPresented: Bool = false
    
    var refreshButtonColor: Color {
        return activityViewModel.isFetching ? .gray : .black
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView{
                ZStack {
                    
                    MemoriesConfettiView(runConfetti: $runConfetti, bikeConfetti: $bikeConfetti, hikeConfetti: $hikeConfetti, skiConfetti: $skiConfetti, otherConfetti: $otherConfetti)
                        .zIndex(10)
                    
                    // Header view
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
                                    Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
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
                        
                        Spacer()
                        
                    }.zIndex(5)
                    
                    VStack {
                        if false && Config.env == "dev" {
                            Button("Logout (dev only - will crash)") {
                                self.loginViewModel.logout()
                            }
                        }
                        
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
                            WidgetCenter.shared.getCurrentConfigurations { results in
                                guard let widgets = try? results.get() else { return }
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
                                            SKStoreReviewController.requestReview(in: windowScene)
                                            UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
                                        }
                                    }
                                }
                            }
                        default: ()
                        }
                    }
                    
                    
                    VStack { // Buttons  -----------------------------------------------------
                        
                        Spacer()
                        
                        // Add widget button -----------------------------------------------------
                        VStack{
                            Button {
                                Analytics.capture(event: .addWidgetHelp)
                                
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
                            .sheet(isPresented: $isShowingWebView) {
                                SheetView(isShowingWebView: self.$isShowingWebView)
                                
                            }

                            
                            Button {
                                self.isChatPresented.toggle()
                                Analytics.capture(event: .homeFeedbackButtonClicked)
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
                    
                    
                }.onAppear {
                    Analytics.capture(event: .viewHomeScreen)
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
