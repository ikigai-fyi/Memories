//
//  FakeBehaviour.swift
//  Activity
//
//  Created by Paul Nicolet on 22/07/2023.
//

import Foundation

enum FakeBehaviour {
    case noActivity
    case noPicture
    
    public var jwt: String {
        switch self {
        case .noActivity: return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY5MDAyOTY3MSwianRpIjoiZTBmNDVlMWEtNThjMi00NjNhLThiZDYtNTJmMzA3NWI4NTVhIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImF0aF9pc1czYVhXSGo0eGREWGdOIiwibmJmIjoxNjkwMDI5NjcxfQ.1Oyz_dV0gdQ6MiaaMk7XA6khN6a_lA3ldv_kg5YR03c"
        case .noPicture: return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY5MDAyOTc2NCwianRpIjoiMWEyNjBmMDItYWUxOS00ODExLWJmNjQtYmFhNmE4NTBlNzA4IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImF0aF9uWUN5RzJ2VDdHbWFuNTJ1IiwibmJmIjoxNjkwMDI5NzY0fQ.t-tbxZvYUww9L7u9NflCbbZr_YIgxRyrI8SiBWceUkE"
        }
    }
}
