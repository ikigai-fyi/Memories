//
//  ActivityViewModel.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation
import WidgetKit
import AmplitudeSwift

public class ActivityViewModel: NSObject, ObservableObject {
    @Published public var activity: Activity?
    
    @MainActor
    public func fetchAndStoreRandomActivity() async {
        // analytics ⚠️ should be moved to someplace ran everytime the app is opened, not in the fetch function
        let identify = Identify()
        let now = DateFormatter.standard.string(from: Date())
        identify.set(property: AnalyticsProperties.lastSeenDate, value: now)
        identify.append(property: AnalyticsProperties.numTotalSessions, value: 1)
        amplitude.identify(identify: identify)

        let url = URL(string: "https://api-dev.ikigai.fyi/rest/activities/random")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Helper.getJWT()!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.standard)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decoded = try decoder.decode(Activity.self, from: data)
                self.activity = decoded
                saveActivityIntoUserDefaults(activity : self.activity!)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    private func saveActivityIntoUserDefaults(activity: Activity) {
        Helper.saveActivityToUserDefault(activity: activity)
    }
}

extension DateFormatter {
    static let standard: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}
