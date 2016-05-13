//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - IdentityType

public protocol IdentityType {
	associatedtype Value
	
	var value: Value { get }
	init(_ value: Value)
}
