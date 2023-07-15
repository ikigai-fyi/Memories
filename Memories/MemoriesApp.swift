//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity
import Sentry
import Crisp

@main
struct MemoriesApp: App {
    @StateObject var loginViewModel = StravaLoginViewModel()
    @StateObject var activityViewModel = ActivityViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isChatPresented = false
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://2307db5e8e854158be765b26bce256ed@o4505126569246720.ingest.sentry.io/4505248857784320"
            options.debug = false
            options.environment = Config.env
        }
        
        Analytics.initialize()
        
        CrispSDK.configure(websiteID: "ddfdd35f-d323-4ca9-8df6-c0380e53ad72")
        if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
            CrispSDK.user.nickname = athlete.fullName
            CrispSDK.user.avatar = URL(string: athlete.pictureUrl)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                if loginViewModel.athlete == nil {
                    StravaLoginView().environmentObject(loginViewModel)
                } else {
                    MemoriesHomeView().environmentObject(loginViewModel).environmentObject(activityViewModel)
                }
                
                Button {
                    self.isChatPresented.toggle()
                    // Action
                } label: {
                    Image(systemName: "questionmark")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                }
                .padding()
                .sheet(isPresented: self.$isChatPresented) {
                    ChatView()
                }
            }
        }.onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
                    Analytics.identify(athlete: athlete)
                }
                
                Analytics.capture(event: .appActive, userProperties: [.lastSeenDate: Date().ISO8601Format()])
            default: ()
            }
        }
    }
}
