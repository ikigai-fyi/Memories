//
//  ContentView.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity
import AmplitudeSwift

struct StravaLoginView: View {
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(minHeight: 10, idealHeight: 100, maxHeight: 600)
                .fixedSize()
            
            Image("ikigaiIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 164, height: 164)
            .cornerRadius(41)
            
            Text("Memories")
                .font(.title).bold()
            Text("Widgets for Strava")
                .font(.headline)
            
            if loginViewModel.isLoading {
                Spacer()
                ProgressView()
            }
            
          
            Spacer()
            
            Button {
                Amplitude.instance.track(eventType: AnalyticsEvents.connectStrava)
                
                // Open Strava app if installed, if will be redirected to our app through a deeplink
                if UIApplication.shared.canOpenURL(self.loginViewModel.getStravaMobileUrl()) {
                    UIApplication.shared.open(self.loginViewModel.getStravaMobileUrl(), options: [:])
                } else {
                    print("Install Strava app and login")
                }
            } label: {
                Text("Connect with Strava")
                    .bold()
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(Constants.MainColor))
            .foregroundColor(.white)
            .cornerRadius(35)

        }
        .frame(maxWidth: .infinity)
        .padding(32.0)
        .onOpenURL { url in
            Task {
                await loginViewModel.handleOauthRedirect(url: url)
            }
        }

    }
}


struct StravaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StravaLoginView()
    }
}
