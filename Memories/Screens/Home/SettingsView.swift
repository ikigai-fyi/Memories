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
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    
    // inherited
    @Binding var isShowingOptions: Bool
    @Binding var isChatPresented: Bool
    
    // state
    @State private var showingFakeBehaviourAlert = false
    @State private var isShowingAlert = false
    @State private var measurementSystemString: String = Helper.getIsUserUsingMetricSystemFromUserDefaults()! ? NSLocalizedString("Metric", comment: "comment") : NSLocalizedString("Imperial", comment: "comment")
    @StateObject private var remoteSettings = RemoteSettings()
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    
                    if let athlete = loginViewModel.athlete {
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
                        loginViewModel.logout()
                    }
                    
                    Button("Delete my account", role: .destructive) {
                        Analytics.capture(event: .deleteAccount)
                        isShowingAlert = true
                    }.alert ("Account deletion", isPresented: $isShowingAlert) {
                        Button("OK", role: .destructive) {
                            Analytics.capture(event: .confirmDeleteAccount)
                            Task { await
                                loginViewModel.deleteAccount()
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
                
                if Config.isDev {
                    Section(header: Text("Developer")){
                        Button("Set fake behaviour (\(activityViewModel.fakeBehaviour?.title ?? "none"))") {
                            showingFakeBehaviourAlert = true
                        }.alert ("Set fake behaviour", isPresented: $showingFakeBehaviourAlert) {
                            Button("Remove fake behaviour") {
                                activityViewModel.fakeBehaviour = nil
                            }
                            Button(FakeBehaviour.noActivity.title) {
                                activityViewModel.fakeBehaviour = .noActivity
                            }
                            Button(FakeBehaviour.noPicture.title) {
                                activityViewModel.fakeBehaviour = .noPicture
                            }
                        }
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
            
        let url = URLComponents(string: "\(Config.backendURL)/rest/settings")!
        let jwt = StravaLoginViewModel.getAthleteFromUserDefault()!.jwt
        var request = URLRequest(url: url.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.standard)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    let decoded = try decoder.decode(Settings.self, from: data)
                    self.widgetRefreshRatePerDay = 24 / decoded.refreshPeriodInHours
                } catch {
                    SentrySDK.capture(error: error)
                }
            } else {
                SentrySDK.capture(message: response.description)
            }
        } catch {
            SentrySDK.capture(error: error)
        }


        self.isLoading = false
    }
    
    @MainActor
    private func patch() async {
        self.isLoading = true
        
        let url = URLComponents(string: "\(Config.backendURL)/rest/settings")!
        let jwt = StravaLoginViewModel.getAthleteFromUserDefault()!.jwt
        var request = URLRequest(url: url.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        let parameters: [String: Any] = [
            "refresh_period_in_hours": 24 / self.widgetRefreshRatePerDay!
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                SentrySDK.capture(message: response.description)
            }
        } catch {
            SentrySDK.capture(error: error)
        }
        
        self.isLoading = false
    }
}

#Preview {
    SettingsView(isShowingOptions: .constant(true), isChatPresented: .constant(true))
}
