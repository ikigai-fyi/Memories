//
//  SettingsView.swift
//  Memories
//
//  Created by Paul Nicolet on 23/11/2023.
//

import SwiftUI
import Activity
import Crisp

struct SettingsView: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    
    // inherited
    @Binding var isShowingOptions: Bool
    @Binding var isChatPresented: Bool
    
    // state
    @State private var showingFakeBehaviourAlert = false
    @State private var isShowingAlert = false
    @AppStorage(UserDefaultsKeys.userWidgetRefreshRatePerDay) var widgetRefreshRatePerDay: Int = Helper.getUserWidgetRefreshRatePerDay()!
    @State private var measurementSystemString: String = Helper.getIsUserUsingMetricSystemFromUserDefaults()! ? NSLocalizedString("Metric", comment: "comment") : NSLocalizedString("Imperial", comment: "comment")
    
    
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
                    
                    Stepper(String(format: NSLocalizedString("Refresh %dx per day", comment: "comment"), widgetRefreshRatePerDay), value: $widgetRefreshRatePerDay, in: 1...4, step: 1){_ in
                        Helper.saveUserWidgetRefreshRatePerDay(refreshRatePerDay: widgetRefreshRatePerDay)
                        
                        Analytics.capture(
                            event: .updateSettingRefreshRatePerDay,
                            eventProperties: [.settingValue: widgetRefreshRatePerDay],
                            userProperties: [.refreshRatePerDay: widgetRefreshRatePerDay]
                        )
                    }
                    
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
            
            
            
        }
    }
}

#Preview {
    SettingsView(isShowingOptions: .constant(true), isChatPresented: .constant(true))
}
