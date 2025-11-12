import Foundation

enum SudokuVisionProcessorError: Error, LocalizedError {
    case imageConversionFailed
    case gridNotFound
    case textRequestFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed: return "Could not convert image data."
        case .gridNotFound: return "Could not find a 6x6 grid rectangle in the image."
        case .textRequestFailed: return "The text recognition request failed."
        }
    }
}
