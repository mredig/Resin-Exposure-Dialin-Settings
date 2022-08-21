import Foundation

public struct SimpleError: Error {
	public var message: String

	public init(message: String = "Unknown Error") {
		self.message = message
	}
}

