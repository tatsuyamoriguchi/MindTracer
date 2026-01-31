//
//  LegalView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/24/25.
//

import SwiftUI

struct LegalView: View {
    var onAgree: () -> Void  // Callback when user agrees
    
    @State private var showCancelAlert = false
    
    var body: some View {
        
        Form {
            Section {
                Text(MindTracerLegalContents.legal.title)
                    
            } header: {
                Text("MindTracer User Agreement")
                    .font(.headline)
            }
            
            Section {
                // Agree button
                Button(action: {
                    onAgree()  // User agreed
                }) {
                    Text("Agree")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Cancel button
                Button(action: {
                    showCancelAlert = true  // Show alert before exiting
                }) {
                    Text("Cancel")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert("Legal Agreement Required", isPresented: $showCancelAlert) {
                    Button("OK") {
                        exit(0)  // Terminate app
                    }
                } message: {
                    Text("MindTracer requires acceptance of the legal terms to ensure your rights and responsibilities are clear. Press OK to exit the app.")
                }
            }
            .padding()
        }
    }
    
    
}

#Preview {
    LegalView {
        print("Agree tapped (Preview)")
    }
}

