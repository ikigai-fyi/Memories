//
//  EmailFormView.swift
//  Memories
//
//  Created by Paul Nicolet on 28/11/2023.
//

import SwiftUI
import Sentry

struct EmailFormView: View {
    let onDone: () -> Void
    
    @State var email: String = ""
    @State var isValid: Bool = false
    @State var isLoading: Bool = false
    @FocusState var isFocused: Bool
    @State var isShowingError: Bool = false
    
    private let authManager = AuthManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Spacer()
                        .frame(minHeight: 10, idealHeight: 100, maxHeight: 600)
                        .fixedSize()
                    
                    Text("Help improve Memories ❤️")
                        .font(.title).bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    
                    Text("We may contact you to ask for feedback! Your data will never ever be shared to third parties.")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(maxHeight: 42)
                    TextField("", text: $email, prompt: Text(verbatim: "stan@getz.com"))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .onReceive(email.publisher) { _ in
                            self.isValid = self.isValidEmail(email)
                        }
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                self.isLoading = true
                                defer { self.isLoading = false }
                                self.isFocused = false
                                
                                do {
                                    try await self.patchEmail()
                                    let athlete = self.authManager.athlete!.updateEmail(email: email)
                                    self.authManager.login(athlete: athlete)
                                    Analytics.capture(event: .saveEmailForm)
                                    self.onDone()
                                } catch {
                                    self.isShowingError = true
                                }
                            }
                        } label: {
                            Text("Save my email")
                                .bold()
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(isValid ? .blue : .gray.opacity(0.5))
                        .foregroundColor(isValid ? .white : .white.opacity(0.5))
                        .cornerRadius(35)
                        .disabled(!isValid)
                    }
                    
                    Button {
                        self.isFocused = false
                        Analytics.capture(event: .skipEmailForm)
                        self.onDone()
                    } label: {
                        Text("Skip")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                .padding([.leading, .trailing], 48)
                .padding([.top, .bottom], 32)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }.onAppear {
            self.isFocused = true
            Analytics.capture(event: .viewEmailFormScreen)
        }.alert(isPresented: $isShowingError) {
            .init(title: Text("An error occurred"))
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @MainActor
    private func patchEmail() async throws {
        try await Request().patch(endpoint: "/athletes/self", payload: ["email": self.email])
    }
}

#Preview {
    EmailFormView { }
}
