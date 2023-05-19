//
//  MemoriesHomeView.swift
//  Memories
//
//  Created by Vincent Ballet on 12/05/2023.
//

import SwiftUI
import WebKit

struct MemoriesHomeView: View {
    @EnvironmentObject var viewModel: StravaLoginViewModel
    @State private var isShowingWebView: Bool = false
    
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView{
                VStack {
                   
                    
                    // Spacer -----------------------------------------------------
                    Spacer()
                        .frame(minHeight: 10, idealHeight: 40, maxHeight: 80)
                        .fixedSize()
                    
                    // Header ----------------------------------------------------
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: viewModel.pictureUrl)) { image in
                            image
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(width: 82, height: 82)
                        .cornerRadius(41)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.firstName)
                                .font(.headline).bold()
                            Text(viewModel.lastName)
                                .font(.headline).bold()

                        }
                    }.frame(height: 100)
                    
                    // Spacer -----------------------------------------------------
                    Spacer()
                    
                    VStack{
                        // Activity widget -----------------------------------------------------
                        if let activity = viewModel.activity {
                            VStack {
                                MemoriesWidgetView(activity: activity)
                                    .frame(width: 292, height: 311)
                                    .background(.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    .shadow(radius: 12)
                                
                                Text("Your widget preview").font(.subheadline)
                            }
                        } else {
                            ProgressView()
                                .frame(width: 292, height: 311)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(12)
                            
                        }
                    }.frame(height: 400)
                    
                    // Spacer -----------------------------------------------------
                    Spacer()
                    
                    // Add widget button -----------------------------------------------------
                    VStack{
                        Button {
                            amplitude.track(eventType: AnalyticsEvents.addWidgetHelp)
                            isShowingWebView = true
                        } label: {
                            Label {
                                Text("Add widget")
                                
                                    .bold()
                            } icon: {
                                Image(systemName: "plus.circle.fill")
                            }.padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(35)
                        .sheet(isPresented: $isShowingWebView) {
                            SheetView(isShowingWebView: self.$isShowingWebView)

                        }
                    }
                    .padding()
                   
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                .onAppear {
                    Task {
                        await viewModel.fetchRandomActivity()
                    }
                }
            } // scrollview
            .refreshable {
                amplitude.track(eventType: AnalyticsEvents.refreshActivities)
                await viewModel.fetchRandomActivity()
            }
        } // geometryreader
        
        
    }
}


struct SheetView : View {
    @Binding var isShowingWebView: Bool
    
    var body: some View{
        NavigationView{
            WebView(url: URL(string: "https://support.apple.com/en-us/HT207122")!)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingWebView = false
                }) {
                    Text("Done").bold()
                })
        }
    }
}


struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
