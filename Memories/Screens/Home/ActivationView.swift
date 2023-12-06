//
//  ActivationView.swift
//  Memories
//
//  Created by Paul Nicolet on 06/12/2023.
//

import SwiftUI
import Crisp
import PostHog

struct ActivationView: View {
    
    @Binding var isShowingWebView: Bool
    @Binding var isShowingVideoView: Bool
    @Binding var isChatPresented: Bool
    
    var body: some View {
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

#Preview {
    ActivationView(isShowingWebView: .constant(false), isShowingVideoView: .constant(false), isChatPresented: .constant(false))
}
