//
//  MemoriesHomeView.swift
//  Memories
//
//  Created by Vincent Ballet on 12/05/2023.
//

import SwiftUI
import WebKit
import WidgetKit
import ConfettiSwiftUI
import Crisp
import StoreKit
import PostHog
import AVKit

struct MemoriesHomeView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.displayScale) var displayScale
    
    @State private var runConfetti: Int = 0
    @State private var bikeConfetti: Int = 0
    @State private var hikeConfetti: Int = 0
    @State private var skiConfetti: Int = 0
    @State private var otherConfetti: Int = 0
    
    @State private var isShowingWebView: Bool = false
    @State private var isShowingVideoView: Bool = false
    @State private var isChatPresented: Bool = false
    @State private var isShowingOptions: Bool = false
    @State private var isShowingShareSheet: Bool = false
    @State private var activityTap: Bool = false
    @State private var titleEgg: Bool = false
    
    @State private var activationViewOpacity: Double = 0
    
    @State private var memory: Memory? = nil
    @State private var error: ActivityError? = nil
    @State private var isLoading: Bool = false
    
    // Honest work: just an integer that is bound to views that need to be refreshed sometimes
    // For instance, to force a widget preview refresh after settings change, just increase this value
    // Usage: View().id(viewModel.stateValue)
    @State var stateValue: Int = 0
    
    private let authManager = AuthManager.shared
    private let memoryService = MemoryService()
    
    private var isLoadingInitial: Bool {
        return self.isLoading && self.memory == nil
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { proxy in
                
                // Header view
                VStack {
                    HStack(spacing: 12) {
                        Text("Memories")
                            .font(.largeTitle.weight(.heavy))
                            .foregroundColor(Color(.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)))
                            .scaleEffect(x: titleEgg ? -1 : 1, y: 1)
                            .animation(.spring(), value: titleEgg)
                            .onTapGesture(count: 3) {
                                titleEgg.toggle()
                            }
                        
                        Spacer()
                        
                        // Picture
                        ZStack{
                            Button(action: {
                                Analytics.capture(event: .viewSettingsScreen)
                                isShowingOptions = true
                            }) {
                                AsyncImage(url: URL(string: authManager.athlete?.pictureUrl ?? "")) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 42, maxHeight: 42)
                                } placeholder: {
                                    Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
                                }
                                .frame(maxWidth: 42, maxHeight: 42)
                                .cornerRadius(21)
                                .zIndex(1)
                                
                                
                            }.sheet(isPresented: $isShowingOptions, onDismiss: {
                                self.stateValue += 1
                            }) {
                                SettingsView(isShowingOptions: $isShowingOptions, isChatPresented: $isChatPresented)
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
                            
                            VStack(spacing: 18.0) {
                                
                                let smallScreen = proxy.size.height < 700
                                let forceHalfRow = smallScreen
                                
                                HStack {
                                    RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen);
                                }.frame(maxWidth: .infinity)
                                
                                
                                HStack {
                                    RowIcon(row: -2, half: forceHalfRow); Spacer(); RowIcon(row: -2, half: forceHalfRow); Spacer(); RowIcon(row: -2, half: forceHalfRow); Spacer(); RowIcon(row: -2, half: forceHalfRow)
                                }.frame(maxWidth: .infinity)
                                
                                
                                HStack {
                                    RowIcon(row: -1); Spacer(); RowIcon(row: -1); Spacer(); RowIcon(row: -1); Spacer(); RowIcon(row: -1)
                                }.frame(maxWidth: .infinity)
                                    .padding(.bottom)
                            }
                            
                            VStack {
                                // Activity widget -----------------------------------------------------
                                if !self.isLoadingInitial {
                                    MemoriesWidgetView(
                                        memory: self.memory,
                                        error: self.error,
                                        withBadges: true,
                                        isInWidget: false
                                    )
                                    .frame(maxWidth: .infinity, minHeight: 162, idealHeight: 162, maxHeight: 162)
                                    .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 18)
                                    .id(self.stateValue)
                                    .onTapGesture {
                                        guard
                                            let activity = self.memory?.activity,
                                            let stravaUrl = activity.stravaUrl
                                        else { return }
                                        
                                        Analytics.capture(event: .openActivityOnStrava, eventProperties: [.from: "preview"])
                                        
                                        // Give some room for the press animation to play before opening the link
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            UIApplication.shared.open(stravaUrl)
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 0, perform: {}) { _ in
                                        activityTap.toggle()
                                    }
                                    .scaleEffect(activityTap ? 0.95 : 1)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: activityTap)
                                } else {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 162, idealHeight: 162, maxHeight: 162)
                                        .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
                                        .cornerRadius(12)
                                }
                                
                                // Buttons
                                HStack{
                                    
                                    Button {
                                        Task {
                                            await self.forceRefreshMemory()
                                        }
                                    } label: {
                                        Label {
                                            Text("Refresh").bold()
                                        } icon: {
                                            Image(systemName: "arrow.clockwise")
                                        }.foregroundColor(self.isLoadingInitial ? .white.opacity(0.7) : .white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 12)
                                    .background(.blue)
                                    .foregroundColor(.blue)
                                    .cornerRadius(35)
                                    .disabled(self.isLoading)
                                    
                                    
                                    Button {
                                        guard
                                            let activity = self.memory?.activity,
                                            let stravaUrl = activity.stravaUrl
                                        else { return }
                                        
                                        Analytics.capture(event: .openActivityOnStrava, eventProperties: [.from: "button"])
                                        UIApplication.shared.open(stravaUrl)
                                        
                                    } label: {
                                        Label {
                                            Text("Strava").bold()
                                        } icon: {
                                            Image(systemName: "link")
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 12)
                                    .background(Color(.init(red: 0.99, green: 0.10, blue: 0.0, alpha: 1)))
                                    .foregroundColor(.white)
                                    .cornerRadius(35)
                                    
                                }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            
                            
                            
                            
                            VStack(spacing: 18.0) {
                                HStack {
                                    RowIcon(row: 1); Spacer(); RowIcon(row: 1); Spacer(); RowIcon(row: 1); Spacer(); RowIcon(row: 1)
                                }.frame(maxWidth: .infinity)
                                
                                HStack {
                                    RowIcon(row: 2); Spacer(); RowIcon(row: 2); Spacer(); RowIcon(row: 2); Spacer(); RowIcon(row: 2)
                                }.frame(maxWidth: .infinity)
                                
                                HStack {
                                    RowIcon(row: 3); Spacer(); RowIcon(row: 3); Spacer(); RowIcon(row: 3); Spacer(); RowIcon(row: 3)
                                }.frame(maxWidth: .infinity)
                            }
                            
                            Spacer()
                            
                        }
                        .zIndex(1)
                        .padding([.leading, .trailing], 28)
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height) // fix height scrollview
                    }
                }
                
                // Bottom CTAs
                VStack {
                    
                    Spacer()
                    
                    VStack(spacing: 10){
                        
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
                        
                        if #available(iOS 16.0, *) {
                            ShareLink(NSLocalizedString("Share the app", comment: "comment"), item: NSLocalizedString("url_app", comment: "comment"), message: Text("share_message"))
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 14)).foregroundColor(.black)
                                .simultaneousGesture(TapGesture().onEnded() {
                                    Analytics.capture(event: .shareToFriends)
                                })
                            
                        }
                        
                    }.padding([.leading, .trailing], 18)
                    
                    Spacer()
                        .frame(minHeight: 10, idealHeight: 30, maxHeight: 60)
                        .fixedSize()
                    
                    
                }.zIndex(5)
                
            }.onOpenURL{ url in
                guard let memory = self.memory else { return }
                
                switch Deeplink(from: url) {
                case .shareMemoryFromPreview:
                    Analytics.capture(event: .shareMemory, eventProperties: [.from: "preview"])
                    WidgetSharingManager(memory: memory, displayScale: self.displayScale).share() {
                        self.isShowingShareSheet = true
                    }
                case .shareMemoryFromWidget:
                    Analytics.capture(event: .shareMemory, eventProperties: [.from: "widget"])
                    WidgetSharingManager(memory: memory, displayScale: self.displayScale).share() {
                        self.isShowingShareSheet = true
                    }
                case nil: return
                }
            }.sheet(isPresented: self.$isShowingShareSheet) {
                let memory = self.memory!
                ShareView(items: WidgetSharingManager(memory: memory, displayScale: self.displayScale).getNativeSharingItems())
            }
            
            VStack {
                Spacer()
                
                ActivationView(
                    isShowingWebView: $isShowingWebView,
                    isShowingVideoView: $isShowingVideoView,
                    isChatPresented: $isChatPresented
                )
                .background(.white)
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.3), radius: 18)
                .padding(18)
            }
            .zIndex(2000)
            .opacity(self.activationViewOpacity)
        }
        .onAppear{
            // First render
            Analytics.capture(event: .viewHomeScreen)
            
            self.isLoading = true
            Task {
                await self.fetchMemory(refresh: false)
            }
            self.updateActivationState()
        }
        .onChange(of: scenePhase) { newPhase in
            // Subsequent renders
            switch newPhase {
            case .active:
                Task {
                    await self.fetchMemory(refresh: false)
                }
                
                self.updateActivationState()
            default: ()
            }
        }
    }
    
    func forceRefreshMemory() async {
        Analytics.capture(event: .refreshActivities)
        
        await self.fetchMemory(refresh: true)
        self.triggerConfettis()
    }
    
    func updateActivationState() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            // More than one widget installed?
            let isUserActivated = ((try? result.get().count) ?? 0) > 0
            
            if isUserActivated {
                self.triggerAskForReview()
            }
            
            withAnimation(.linear(duration: 0.2)) {
                self.activationViewOpacity = isUserActivated ? 0 : 1
            }
        }
    }
    
    private func fetchMemory(refresh: Bool) async {
        self.isLoading = true
        defer {
            self.isLoading = false
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        do {
            self.memory = try await self.memoryService.fetch(refresh: refresh)
            self.error = nil
        } catch let e as ActivityError {
            self.memory = nil
            self.error = e
        } catch {
            self.memory = nil
            self.error = .other
        }
    }
    
    private func triggerConfettis() {
        switch self.memory?.activity.getSportType() {
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
    
    private var height: CGFloat = 64.0
    private let width: CGFloat = 64.0
    
    init(row: Int, half: Bool = false) {
        self.row = row
        if half{
            self.height = self.height / 2
        }
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
            .frame(width: self.width, height: self.height)
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
    @State private var player = AVPlayer(url: Helper.createLocalUrl(for: "addWidgetHelp", ofType: "mp4")!)
    
    
    var body: some View{
        GeometryReader { proxy in
            
            NavigationView{
                VStack(spacing:18){
                    Spacer()
                    
                    VideoPlayer(player: player)
                        .frame(
                            width: 0.5614583333 * 0.8 * proxy.size.height,
                            height: 0.8 * proxy.size.height
                        ).navigationBarTitle(Text(""), displayMode: .inline)
                        .background(.white)
                        .cornerRadius(8)
                        .navigationBarTitle(Text(""), displayMode: .inline)
                        .zIndex(1)
                        .onAppear{
                            player.play()
                            player.seek(to: .zero)
                        }.padding()
                    
                    Button {
                        Analytics.capture(event: .goToHomeScreenAfterHelpVideo)
                        self.isShowingVideoView = false
                    } label: {
                        Label {
                            Text("Ok, got it!").bold()
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }.padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(35)
                    
                    
                    
                } .padding([.leading, .trailing, .bottom], 28)
                
            }
            
        }
        
    }
}



struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
