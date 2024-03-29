//
//  SettingsView.swift
//  Memories
//
//  Created by Paul Nicolet on 23/11/2023.
//

import SwiftUI
import Crisp
import Sentry

struct SettingsView: View {
    @Binding var isShowingOptions: Bool
    @Binding var isChatPresented: Bool

    @State private var isShowingAlert = false
    @State private var measurementSystemString: String = Helper.getIsUserUsingMetricSystemFromUserDefaults()! ? NSLocalizedString("Metric", comment: "comment") : NSLocalizedString("Imperial", comment: "comment")
    @StateObject private var remoteSettings = RemoteSettings()
    
    private let authManager = AuthManager.shared
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    
                    if let athlete = authManager.athlete {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: athlete.pictureUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 64, maxHeight: 64)
                            } placeholder: {
                                Color(.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
                            }
                            .frame(maxWidth: 64, maxHeight: 64)
                            .cornerRadius(32)
                            .zIndex(1)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                HStack(spacing: 8) {
                                    
                                    Text("\(athlete.firstName) \(athlete.lastName)").bold()
                                    Spacer()
                                }
                                
                                Text("Successfully connected to Strava")
                                    .font(.caption)
                            }
                            
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    
                    Button("Logout") {
                        Analytics.capture(event: .logout)
                        authManager.logout()
                        ScreenManager.shared.goTo(screen: .login)
                    }
                    
                    Button("Delete my account", role: .destructive) {
                        Analytics.capture(event: .deleteAccount)
                        isShowingAlert = true
                    }.alert ("Account deletion", isPresented: $isShowingAlert) {
                        Button("OK", role: .destructive) {
                            Analytics.capture(event: .confirmDeleteAccount)
                            Task { 
                                await self.remoteSettings.deleteAccount()
                                ScreenManager.shared.goTo(screen: .login)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure? This action is irreversible.")
                    }
                }
                
                
                
                Section(header: Text("Widget settings")) {
                    Button(NSLocalizedString("Units", comment: "comment") + " : \(measurementSystemString)") {
                        let currentIsMetric = Helper.getIsUserUsingMetricSystemFromUserDefaults()!
                        let newIsMetric = !currentIsMetric
                        
                        let string = newIsMetric ? "Metric" : "Imperial"
                        self.measurementSystemString = NSLocalizedString(string, comment: "comment")
                        
                        Helper.saveIsUserUsingMetricSystemFromUserDefaults(metric: newIsMetric)
                        Analytics.capture(
                            event: .updateSettingMeasurementSystem,
                            eventProperties: [.settingValue: string],
                            userProperties: [.measurementSystem: string]
                        )
                    }
                    
                    
                    
                    Stepper(String(format: NSLocalizedString("Refresh %dx per day", comment: "comment"), self.remoteSettings.widgetRefreshRatePerDay ?? 0)) {
                        
                        Task {
                            await self.remoteSettings.incrementRefreshRate()
                        }
                        
                        Analytics.capture(
                            event: .updateSettingRefreshRatePerDay,
                            eventProperties: [.settingValue: self.remoteSettings.widgetRefreshRatePerDay!],
                            userProperties: [.refreshRatePerDay: self.remoteSettings.widgetRefreshRatePerDay!]
                        )
                    } onDecrement: {
                        Task {
                            await self.remoteSettings.decrementRefreshRate()
                        }
                        
                        Analytics.capture(
                            event: .updateSettingRefreshRatePerDay,
                            eventProperties: [.settingValue: self.remoteSettings.widgetRefreshRatePerDay!],
                            userProperties: [.refreshRatePerDay: self.remoteSettings.widgetRefreshRatePerDay!]
                        )
                    }.disabled(self.remoteSettings.isLoading)
                    
                }
                
                
                Section(header: Text("Contact us")){
                    Button("Suggest features") {
                        self.isChatPresented.toggle()
                        Analytics.capture(event: .shareFeedback, eventProperties: [.from: "profileFeedbackButton"])
                    }.sheet(isPresented: self.$isChatPresented) {
                        ChatView()
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isShowingOptions = false
            }) {
                Text("Done").bold()
            })
            
        }.task {
            await self.remoteSettings.fetch()
        }
    }
}

struct Settings: Codable {
    let refreshPeriodInHours: Int
}

class RemoteSettings: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var widgetRefreshRatePerDay: Int? = nil
    
    @MainActor
    func incrementRefreshRate() async {
        guard self.widgetRefreshRatePerDay! < 4 else { return }
        self.widgetRefreshRatePerDay! += 1
        await self.patch()
    }
    
    @MainActor
    func decrementRefreshRate() async {
        guard self.widgetRefreshRatePerDay! > 1 else { return }
        self.widgetRefreshRatePerDay! -= 1
        await self.patch()
    }
    
    @MainActor
    func fetch() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard let settings = try? await Request().get(Settings.self, endpoint: "/settings") else { return }
        self.widgetRefreshRatePerDay = 24 / settings.refreshPeriodInHours
    }
    
    @MainActor
    private func patch() async {
        self.isLoading = true
        let payload: [String: Any] = [
            "refresh_period_in_hours": 24 / self.widgetRefreshRatePerDay!
        ]
        try? await Request().patch(endpoint: "/settings", payload: payload)
        self.isLoading = false
    }
    
    @MainActor
    func deleteAccount() async {
        let url = URL(string: "\(Config.backendURL)/rest/auth/delete")!
        var request = URLRequest(url: url)
        let jwt = AuthManager.shared.jwt!
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        self.isLoading = true
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let r = response as? HTTPURLResponse, r.statusCode == 200 {
                AuthManager.shared.logout()
            } else {}
        } catch {
            SentrySDK.capture(error: error)
        }
        self.isLoading = false
    }
}

#Preview {
    SettingsView(isShowingOptions: .constant(true), isChatPresented: .constant(true))
}
