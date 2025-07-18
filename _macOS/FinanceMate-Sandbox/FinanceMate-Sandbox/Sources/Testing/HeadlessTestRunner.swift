// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation
import SwiftUI

@available(macOS 13.0, *)
public struct HeadlessTestRunner {
    
    public static func main() async {
        print("🚀 Starting FinanceMate Comprehensive Headless Testing Framework")
        print("================================================================")
        
        let framework = ComprehensiveHeadlessTestFramework()
        
        // Start monitoring framework updates
        let monitoring = Task {
            await monitorTestProgress(framework: framework)
        }
        
        // Execute comprehensive test suite
        await framework.executeComprehensiveTestSuite()
        
        // Cancel monitoring
        monitoring.cancel()
        
        // Print final summary
        await printFinalSummary(framework: framework)
        
        print("================================================================")
        print("✅ Comprehensive Headless Testing Complete")
        
        // Exit with appropriate code
        let hasFailures = framework.results.contains { $0.status == .failed } || !framework.crashLogs.isEmpty
        exit(hasFailures ? 1 : 0)
    }
    
    private static func monitorTestProgress(framework: ComprehensiveHeadlessTestFramework) async {
        var lastProgress: Double = 0
        
        while !Task.isCancelled {
            let currentProgress = await framework.progress
            let currentTest = await framework.currentTest
            let isRunning = await framework.isRunning
            
            if currentProgress != lastProgress || !currentTest.isEmpty {
                let progressPercent = Int(currentProgress * 100)
                print("📊 Progress: \\(progressPercent)% - \\(currentTest)")
                lastProgress = currentProgress
            }
            
            if !isRunning {
                break
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
    }
    
    private static func printFinalSummary(framework: ComprehensiveHeadlessTestFramework) async {
        let results = await framework.results
        let crashLogs = await framework.crashLogs
        
        let passedTests = results.filter { $0.status == .passed }.count
        let failedTests = results.filter { $0.status == .failed }.count
        let warningTests = results.filter { $0.status == .warning }.count
        
        print("\\n📊 FINAL TEST SUMMARY")
        print("=====================")
        print("✅ Passed: \\(passedTests)")
        print("❌ Failed: \\(failedTests)")
        print("⚠️ Warnings: \\(warningTests)")
        print("🔴 Crashes: \\(crashLogs.count)")
        
        if failedTests > 0 {
            print("\\n❌ FAILED TESTS:")
            for result in results.filter({ $0.status == .failed }) {
                print("  - \\(result.name): \\(result.message)")
            }
        }
        
        if !crashLogs.isEmpty {
            print("\\n🔴 CRASH LOGS DETECTED:")
            for crashLog in crashLogs {
                print("  - \\(crashLog.fileName) (\\(crashLog.severity))")
            }
        }
        
        let totalDuration = results.reduce(0) { $0 + $1.duration }
        print("\n⏱️ Total Test Duration: \(String(format: "%.2f", totalDuration)) seconds")
        
        let overallStatus = failedTests == 0 && crashLogs.isEmpty ? "✅ READY FOR TESTFLIGHT" : "❌ ISSUES REQUIRE ATTENTION"
        print("\n🎯 Overall Status: \(overallStatus)")
    }
}