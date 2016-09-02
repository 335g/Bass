//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Pointed

public protocol Pointed {
	associatedtype Value
	
	static func pure(_ a: Value) -> Self
}
