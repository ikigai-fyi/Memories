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
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    @Environment(\.displayScale) var displayScale
    @Environment(\.scenePhase) var scenePhase
    
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

    @State private var isUserActivated = false
    
    @State var activityTap = false
    @State var titleEgg = false
    
    var previewRefreshButtonTextColor: Color {
        return memoryViewModel.isFetchingInitial ? .gray : .black
    }
    
    var refreshButtonTextColor: Color {
        return memoryViewModel.isFetchingInitial ? .white.opacity(0.7) : .white
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
                        .scaleEffect(x: titleEgg ? -1 : 1, y: 1)
                        .animation(.spring(), value: titleEgg)
                        .onTapGesture(count: 3) {
                            titleEgg.toggle()
                        }
                    
                    // Spacer -----------------------------------------------------
                    Spacer()
                    
                    // Picture ------------------------------------------------
                    ZStack{
                        Button(action: {
                            Analytics.capture(event: .viewSettingsScreen)
                            isShowingOptions = true
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
                            
                            
                        }.sheet(isPresented: $isShowingOptions, onDismiss: {
                            self.forceRenderWidgetViews()
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
                            let forceHalfRow = smallScreen && !isUserActivated
                            
                            // TODO : 700 is a random value
                            if isUserActivated{
                                HStack {
                                    RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen); Spacer(); RowIcon(row: -3, half: smallScreen);
                                }.frame(maxWidth: .infinity)
                            }
                            
                            
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
                            if !self.memoryViewModel.isFetchingInitial {
                                MemoriesWidgetView(
                                    memory: memoryViewModel.memory,
                                    error: memoryViewModel.error,
                                    withBadges: true,
                                    isInWidget: false
                                )
                                    .frame(maxWidth: .infinity, minHeight: 162, idealHeight: 162, maxHeight: 162)
                                    .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 18)
                                    .id(memoryViewModel.stateValue)
                                    .onTapGesture {
                                        guard
                                            let activity = memoryViewModel.memory?.activity,
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
                                
                                // Loading view ------------------------------------------------
                            } else {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 162, idealHeight: 162, maxHeight: 162)
                                    .background(Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)))
                                    .cornerRadius(12)
                            }
                            
                            // Refresh widget ------------------------------------------------
                            if !isUserActivated {
                                Button {
                                    Task {
                                        await self.forceRefreshMemory()
                                    }
                                } label: {
                                    Label {
                                        Text("Your widget preview").font(.subheadline)
                                    }  icon: {
                                        Image(systemName: "arrow.clockwise")
                                    }.font(.system(size: 12)).foregroundColor(previewRefreshButtonTextColor)
                                }.disabled(memoryViewModel.isFetching)
                            } else {
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
                                        }.foregroundColor(refreshButtonTextColor)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 12)
                                    .background(.blue)
                                    .foregroundColor(.blue)
                                    .cornerRadius(35)
                                    .disabled(memoryViewModel.isFetching)
                                    
                                    
                                    Button {
                                        guard
                                            let activity = memoryViewModel.memory?.activity,
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
                        
                        // Spacer -----------------------------------------------------
                        Spacer()
                        
                    }
                    .zIndex(1) // VStack content view
                    .padding([.leading, .trailing], 28)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height) // fix height scrollview
                    .onAppear{
                        // First render
                        Task {
                            await self.memoryViewModel.fetchMemory()
                        }
                    }
                    .onChange(of: scenePhase) { newPhase in
                        // Subsequent renders
                        switch newPhase {
                        case .active:
                            Task {
                                await self.memoryViewModel.fetchMemory()
                            }
                            
                            // request review
                            // trigger is widget count > 0 && did not ask before
                            WidgetCenter.shared.getCurrentConfigurations { result in
                                
                                if let results = try? result.get(),
                                   results.count > 0 {
                                    self.isUserActivated = true
                                    self.triggerAskForReview()
                                    
                                } else {
                                    self.isUserActivated = false
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
                VStack(spacing: 10){
                    
                    if !isUserActivated{
                        ActivationView(
                            isShowingWebView: $isShowingWebView,
                            isShowingVideoView: $isShowingVideoView,
                            isChatPresented: $isChatPresented
                        ).background(.white)
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.3), radius: 18)
                        
                    } else {
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
                        
                    }
                }.padding([.leading, .trailing], 18)
                
                
                // Spacer -----------------------------------------------------
                Spacer()
                    .frame(minHeight: 10, idealHeight: 30, maxHeight: 60)
                    .fixedSize()
                
                
            }.zIndex(5)
        }.onOpenURL{ url in
            switch Deeplink(from: url) {
            case .shareMemoryFromPreview:
                Analytics.capture(event: .shareMemory, eventProperties: [.from: "preview"])
                self.isShowingShareSheet = true
            case .shareMemoryFromWidget:
                Analytics.capture(event: .shareMemory, eventProperties: [.from: "widget"])
                self.isShowingShareSheet = true
            case nil: return
            }
        }.sheet(isPresented: self.$isShowingShareSheet) {
            ShareView(items: self.buildShareItems())
        }
    }
    
    func buildShareItems() -> [Any] {
        let shareMessage = NSLocalizedString("widget_share_message", comment: "comment")
        let appUrl = NSLocalizedString("url_app", comment: "comment")
        let text = "\(shareMessage) <\(appUrl)>"
        
        var items: [Any] = [text]
        if #available(iOS 16.0, *), let image = self.renderAsImage() {
            items.append(image)
        }
        
        return items
    }
    
    @available(iOS 16.0, *)
    func renderAsImage() -> UIImage? {
        let view = HStack(alignment: .center) {
            VStack(alignment: .center) {
                MemoriesWidgetView(
                    memory: memoryViewModel.memory,
                    error: memoryViewModel.error,
                    withBadges: false,
                    isInWidget: false
                )
                    .frame(width: 360, height: 170)
                    .cornerRadius(15)
                    .padding(15)
            }
        }
            .background(.white)
            .cornerRadius(30)
        
        let renderer = ImageRenderer(content: view)

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            return uiImage
        }
        
        return nil
    }
    
    func forceRefreshMemory() async {
        Analytics.capture(event: .refreshActivities)
        
        await memoryViewModel.fetchMemory(refresh: true)
        self.forceRenderWidgetViews()
        self.triggerConfettis()
    }
    
    func forceRenderWidgetViews() {
        self.memoryViewModel.stateValue += 1
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func triggerConfettis() {
        switch self.memoryViewModel.memory?.activity.getSportType() {
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

struct ActivationView: View{
    
    @Binding var isShowingWebView: Bool
    @Binding var isShowingVideoView: Bool
    @Binding var isChatPresented: Bool
    
    
    var body: some View{
        VStack(alignment: .center, spacing: 14) {
            
            Text("You're almost there! 🎉")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
            
            HStack{
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 42, maxHeight: 42)
                    .foregroundColor(Color(uiColor: .systemGray6))
                    .frame(width: 25, height: 25, alignment: .center)
                
                Button("Connect with Strava") {}
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 12)
                    .background(Color(uiColor: .systemGray6))
                    .foregroundColor(Color(uiColor: .darkGray))
                    .cornerRadius(35)
                    .disabled(true)
            }
            
            HStack{
                Image(systemName: "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 42, maxHeight: 42)
                    .frame(width: 25, height: 25, alignment: .center)
                    .foregroundColor(.blue)
                
                Button {
                    if let ff = PHGPostHog.shared()?.getFeatureFlag("activate-widget-gif") as? Int,
                       ff == 0 {
                        Analytics.capture(event: .addWidgetHelp, eventProperties: [.abTestGroup: "0_webView"])
                        isShowingWebView = true
                    } else {
                        Analytics.capture(event: .addWidgetHelp, eventProperties: [.abTestGroup: "1_videoView"])
                        isShowingVideoView = true
                    }
                }
            label: {
                Text("Add widget").bold()
            }
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 12)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(35)
            .sheet(isPresented: $isShowingWebView) {
                SheetWebView(isShowingWebView: $isShowingWebView)
            }
            .sheet(isPresented: $isShowingVideoView) {
                SheetVideoView(isShowingVideoView: $isShowingVideoView)
            }
            }
            
            Button {
                self.isChatPresented.toggle()
                Analytics.capture(event: .loginHelpButtonClicked)
            } label: {
                Text("Need help?")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .sheet(isPresented: $isChatPresented) {
                ChatView()
            }
            
        }.padding(EdgeInsets(top: 20, leading: 18, bottom: 20, trailing: 18))
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