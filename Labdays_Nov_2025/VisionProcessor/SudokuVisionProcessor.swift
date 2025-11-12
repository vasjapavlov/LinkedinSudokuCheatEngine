import Vision
import UIKit

/// This struct handles all the Vision logic for extracting a 6x6 Sudoku grid.
struct SudokuVisionProcessor {

    /// Processes image data and asynchronously returns a 6x6 Sudoku grid.
    /// - Parameter imageData: The raw `Data` of the screenshot.
    /// - Returns: A `SudokuGrid` (`[[Int?]]`) representing the 6x6 board.
    /// - Throws: A `SudokuError` if processing fails.
    func processImage(imageData: Data) async throws -> SudokuGrid {
        
        // 1. Convert Data -> CGImage and get orientation
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw SudokuVisionProcessorError.imageConversionFailed
        }
        
        // Get the correct image orientation for the Vision request
        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)
        
        // 2. Create the two Vision requests
        let gridRequest = VNDetectRectanglesRequest()
        gridRequest.maximumObservations = 1 // We only want the biggest, main grid
        gridRequest.minimumConfidence = 0.8 // Be reasonably confident

        let textRequest = VNRecognizeTextRequest()
        // You can add custom words if you find it mis-recognizing
        // textRequest.customWords = ["1", "2", "3", "4", "5", "6"]
        
        // 3. Create and perform the handler
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        try handler.perform([gridRequest, textRequest])

        // 4. Get the Grid Bounding Box
        // This is the fix for the "empty border" edge case.
        guard let gridResults = gridRequest.results,
              let gridObservation = gridResults.first else {
            throw SudokuVisionProcessorError.gridNotFound
        }
        
        // This bounding box is normalized (0.0-1.0) with a BOTTOM-LEFT origin.
        let gridBoundingBox = gridObservation.boundingBox
        
        // 5. Get the Text Observations
        guard let textResults = textRequest.results else {
            throw SudokuVisionProcessorError.textRequestFailed
        }
        
        // 6. "Slot" the digits into the grid
        
        // Calculate the normalized size of a single cell
        let cellWidth = gridBoundingBox.width / 6.0
        let cellHeight = gridBoundingBox.height / 6.0
        
        // Create the empty 6x6 matrix
        var sudokuMatrix: SudokuGrid = Array(repeating: Array(repeating: 0, count: 6), count: 6)

        for observation in textResults {
            // Get the best candidate and make sure it's a single digit
            guard let text = observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespaces),
                  text.count == 1, // Make sure it's a single character
                  let digit = Int(text) else {
                continue
            }
            
            // Get the digit's bounding box (also normalized, bottom-left)
            let digitBoundingBox = observation.boundingBox
            
            // Find the center of the digit
            let digitCenter = CGPoint(x: digitBoundingBox.midX, y: digitBoundingBox.midY)
            
            // Ensure this digit is *inside* the grid we found
            if gridBoundingBox.contains(digitCenter) {
                
                // Calculate column and row
                let col = Int((digitCenter.x - gridBoundingBox.minX) / cellWidth)
                
                // --- CRITICAL LOGIC ---
                // Vision's (0,0) is BOTTOM-LEFT. Our matrix's (0,0) is TOP-LEFT.
                // We must "flip" the Y-coordinate.
                let rowFromBottom = Int((digitCenter.y - gridBoundingBox.minY) / cellHeight)
                let row = 5 - rowFromBottom // Flip the row
                // ---------------------
                
                // Final bounds check
                if (row >= 0 && row < 6 && col >= 0 && col < 6) {
                    sudokuMatrix[row][col] = digit
                }
            }
        }
        
        return sudokuMatrix
    }
}

// MARK: - UIImage Orientation Helper

/// Helper to convert UIImage.Orientation to CGImagePropertyOrientation
/// This is crucial for getting Vision to "see" the image correctly.
extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
