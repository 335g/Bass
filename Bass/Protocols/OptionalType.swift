//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - OptionalType

public protocol OptionalType {
	associatedtype Wrapped
	
	var optional: Wrapped? { get }
}

extension Optional: OptionalType {
	public var optional: Wrapped? {
		return self
	}
}

