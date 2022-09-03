import Foundation

public extension Optional {
	func unwrap() throws -> Wrapped {
		switch self {
		case .some(let value):
			return value
		case .none:
			throw SimpleError(message: "Error unwrapping optional of type: \(Wrapped.self)")
		}
	}
}
