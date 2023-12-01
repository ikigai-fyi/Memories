//
//  ContentView.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Crisp

struct StravaLoginView: View {
    @State private var isChatPresented: Bool = false
    @State private var isLoading: Bool = false
    
    let onDone: () -> Void
    private let loginService = LoginService()
    
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
            
            if self.isLoading {
                Spacer()
                ProgressView()
            }
            
          
            Spacer()
            
            VStack(spacing: 12.0) {
             
                Button {
                    self.isLoading = true
                    self.loginService.startOauth { url, _ in
                        // Coming back from webview
                        guard let url = url else { return }
                        Task { await self.continueOauth(url: url) }
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
            // Coming back from Strava app
            Task { await self.continueOauth(url: url) }
        }.onAppear {
            Analytics.capture(event: .viewLoginScreen)
        }
        
    }
    
    private func continueOauth(url: URL) async {
        defer { self.isLoading = false }
        do {
            try await self.loginService.handleOauthRedirect(url: url)
            self.onDone()
        } catch {}
    }
}


struct StravaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StravaLoginView {}
    }
}
