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

// MARK: - OptionalType - map/flatMap

public extension OptionalType {
	public func map<A>(@noescape f: Wrapped throws -> A) rethrows -> A? {
		return try optional.map(f)
	}
	
	public func flatMap<A>(@noescape f: Wrapped throws -> A?) rethrows -> A? {
		return try optional.flatMap(f)
	}
}

