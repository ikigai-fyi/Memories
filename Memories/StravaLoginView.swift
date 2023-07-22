//
//  ContentView.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity
import Crisp

struct StravaLoginView: View {
    @EnvironmentObject var loginViewModel: StravaLoginViewModel
    @State private var isChatPresented: Bool = false
    
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
            
            VStack(spacing: 12.0) {
             
                Button {
                    // Open Strava app if installed, if will be redirected to our app through a deeplink
                    // UIApplication can only be used in a UIKit context
                    if UIApplication.shared.canOpenURL(self.loginViewModel.getStravaMobileUrl()) {
                        Analytics.capture(event: .connectStrava, eventProperties: [.with: "stravaApp"])
                        UIApplication.shared.open(self.loginViewModel.getStravaMobileUrl(), options: [:])
                    } else {
                        Analytics.capture(event: .connectStrava, eventProperties: [.with: "stravaWebview"])
                        self.loginViewModel.startWebOauth()
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
                
                Button {
                    self.isChatPresented.toggle()
                    Analytics.capture(event: .loginHelpButtonClicked)
                } label: {
                    Text("Need help?")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                .sheet(isPresented: self.$isChatPresented) {
                    ChatView()
                }
                
            }

        }
        .frame(maxWidth: .infinity)
        .padding(32.0)
        .onOpenURL { url in
            Task {
                await loginViewModel.handleOauthRedirect(url: url)
            }
        }.onAppear {
            Analytics.capture(event: .viewLoginScreen)
        }
        
    }
}


struct StravaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StravaLoginView()
    }
}
