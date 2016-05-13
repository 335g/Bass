//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Pointed

public protocol Pointed {
	associatedtype PointedValue
	
	static func pure(a: PointedValue) -> Self
}
