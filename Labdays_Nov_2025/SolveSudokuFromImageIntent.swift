import AppIntents
import UIKit // or SwiftUI

// This struct defines the "action" your app is making available to Shortcuts.
struct SolveSudokuFromImageIntent: AppIntent {
    
    // This is the title that will appear in the Shortcuts app.
    static var title: LocalizedStringResource = "Solve Sudoku from Image"
    
    // This tells the system that this intent should be discoverable
    // by users in the Shortcuts app gallery.
    static var isDiscoverable: Bool = true

    private let processor = SudokuVisionProcessor()
    // This defines the *input* for the intent.
    // The 'title' is what the user sees in the Shortcut editor.
    //
    // **** FIX: We use IntentFile instead of Data. ****
    // IntentFile is the correct wrapper for passing file/image data.
    @Parameter(title: "Image", inputConnectionBehavior: .connectToPreviousIntentResult)
    var image: IntentFile // We'll receive the screenshot as an IntentFile

    // This tells the system to open your app to fulfill the intent.
    // For your use case, this is exactly what you want.
    static var openAppWhenRun: Bool = true

    // This is the main function that gets called when the Shortcut runs.
    @MainActor // Ensure this runs on the main thread if you plan to update UI
    func perform() async throws -> some IntentResult {
        let imageData = image.data
        
        print("Received image data of size: \(imageData.count) bytes. Handing off to solver...")

        // 2. Call our processor to get the 6x6 grid
        do {
            let grid = try await processor.processImage(imageData: imageData)
            
            print("--- Vision Processing Succeeded ---")
            print("Parsed 6x6 Grid:")
            // You can use a helper to print this more nicely
            print(grid)
            print("-----------------------------------")

            // 3. Post the solved grid to the app's UI
            // Your main ViewController or SwiftUI View should observe this.
            NotificationCenter.default.post(
                name: .didParseSudokuGrid,
                object: grid
            )
            
        } catch {
            // Handle errors from the Vision processor
            print("--- Vision Processing Failed ---")
            print("Error: \(error.localizedDescription)")
            // You could post a "failure" notification here
            NotificationCenter.default.post(
                name: .didFailToParseSudoku,
                object: error
            )
        }

        // We don't need to return any data *to* the Shortcut,
        // so we just return .result() to signal success.
        return .result()
    }
}

// It's good practice to define your Notification name in an extension.
extension Notification.Name {
    /// Posted when the Vision processor successfully returns a 6x6 grid.
    /// The `object` will be the `SudokuGrid` ([[Int?]]).
    static let didParseSudokuGrid = Notification.Name("com.your-app.didParseSudokuGrid")
    
    /// Posted when the Vision processor fails.
    /// The `object` will be the `Error`.
    static let didFailToParseSudoku = Notification.Name("com.your-app.didFailToParseSudoku")
}

// IMPORTANT: You must also "export" this intent so the system can see it.
// The easiest way is to add an AppShortcutsProvider.
struct MySudokuShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SolveSudokuFromImageIntent(),
            // **** FIX: The phrases array MUST include the ${applicationName} placeholder. ****
            phrases: [
                "Solve my Sudoku with \(.applicationName)",
                "Solve Sudoku in \(.applicationName)"
            ],
            shortTitle: "Solve Sudoku",
            systemImageName: "camera.viewfinder"
        )
    }
}
