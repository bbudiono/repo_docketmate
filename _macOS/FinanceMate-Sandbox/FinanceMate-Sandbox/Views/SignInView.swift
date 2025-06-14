// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  SignInView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Polished SSO sign-in interface with Apple and Google authentication in Sandbox environment
* Issues & Complexity Summary: Modern SSO UI with accessibility, animations, and error handling
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium
  - Dependencies: 5 New (SSOAuthentication, UIAnimations, AccessibilitySupport, ErrorHandling, UserExperience)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Polished UI with complex authentication flow and user experience considerations
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Focus on user experience and accessibility in authentication flow
* Last Updated: 2025-06-02
*/

import SwiftUI
import AuthenticationServices

// MARK: - Sign In View

struct SignInView: View {
    
    // MARK: - State Properties
    
    @StateObject private var authService = AuthenticationService()
    @State private var showingErrorAlert = false
    @State private var isAppleSignInLoading = false
    @State private var isGoogleSignInLoading = false
    @State private var animateTitle = false
    @State private var animateButtons = false
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 32) {
                    
                    // Header Section
                    headerSection
                    
                    // Sign In Options
                    signInOptionsSection
                    
                    // Footer
                    footerSection
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 60)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
                
                // Loading Overlay
                if authService.isLoading {
                    loadingOverlay
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .alert("Authentication Error", isPresented: $showingErrorAlert) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            Text(authService.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authService.errorMessage) { _, errorMessage in
            showingErrorAlert = errorMessage != nil
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Icon
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
            }
            .scaleEffect(animateTitle ? 1.0 : 0.8)
            .opacity(animateTitle ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateTitle)
            
            // Title and Subtitle
            VStack(spacing: 8) {
                Text("Welcome to FinanceMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Sign in to manage your finances securely")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(animateTitle ? 1.0 : 0.0)
            .offset(y: animateTitle ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
        }
    }
    
    private var signInOptionsSection: some View {
        VStack(spacing: 20) {
            // Apple Sign In Button
            appleSignInButton
            
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
                
                Text("or")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            // Google Sign In Button
            googleSignInButton
        }
        .opacity(animateButtons ? 1.0 : 0.0)
        .offset(y: animateButtons ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateButtons)
    }
    
    private var appleSignInButton: some View {
        Button(action: {
            Task {
                await signInWithApple()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.system(size: 20, weight: .medium))
                
                Text("Continue with Apple")
                    .font(.headline)
                    .fontWeight(.medium)
                
                if isAppleSignInLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.black)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .disabled(authService.isLoading)
        .scaleEffect(isAppleSignInLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isAppleSignInLoading)
        .accessibilityLabel("Sign in with Apple")
        .accessibilityHint("Tap to sign in using your Apple ID")
    }
    
    private var googleSignInButton: some View {
        Button(action: {
            Task {
                await signInWithGoogle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .medium))
                
                Text("Continue with Google")
                    .font(.headline)
                    .fontWeight(.medium)
                
                if isGoogleSignInLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .disabled(authService.isLoading)
        .scaleEffect(isGoogleSignInLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isGoogleSignInLoading)
        .accessibilityLabel("Sign in with Google")
        .accessibilityHint("Tap to sign in using your Google account")
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Open terms of service
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Privacy Policy") {
                    // Open privacy policy
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .opacity(animateButtons ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateButtons)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Signing you in...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Methods
    
    private func startAnimations() {
        withAnimation {
            animateTitle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                animateButtons = true
            }
        }
    }
    
    private func signInWithApple() async {
        isAppleSignInLoading = true
        defer { isAppleSignInLoading = false }
        
        do {
            let result = try await authService.signInWithApple()
            if result.success {
                // Authentication successful, view will dismiss automatically
                print("Apple Sign In successful for user: \(result.user?.displayName ?? "Unknown")")
            }
        } catch {
            print("Apple Sign In failed: \(error.localizedDescription)")
            // Error will be handled by the alert
        }
    }
    
    private func signInWithGoogle() async {
        isGoogleSignInLoading = true
        defer { isGoogleSignInLoading = false }
        
        do {
            let result = try await authService.signInWithGoogle()
            if result.success {
                // Authentication successful, view will dismiss automatically
                print("Google Sign In successful for user: \(result.user?.displayName ?? "Unknown")")
            }
        } catch {
            print("Google Sign In failed: \(error.localizedDescription)")
            // Error will be handled by the alert
        }
    }
}

// MARK: - Preview

#Preview {
    SignInView()
        .frame(width: 600, height: 700)
}