//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Pointed

public protocol Pointed {
	associatedtype A
	
	static func pure(a: A) -> Self
}
