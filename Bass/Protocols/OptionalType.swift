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

// MARK: - OptionalType - map/flatMap/ap

public extension OptionalType {
	public func map<A>(_ f: (Wrapped) throws -> A) rethrows -> A? {
		return try optional.map(f)
	}
	
	public func flatMap<A>(_ f: (Wrapped) throws -> A?) rethrows -> A? {
		return try optional.flatMap(f)
	}
	
	public func ap<A, OT: OptionalType>(_ fn: OT) -> A?
		where OT.Wrapped == (Wrapped) -> A {
			return fn >>- { f in map(f) }
	}
}

public func <^> <A, OT: OptionalType>(_ f: (OT.Wrapped) throws -> A, _ optional: OT) rethrows -> A? {
	return try optional.map(f)
}

public func >>- <A, OT: OptionalType>(_ optional: OT, _ f: (OT.Wrapped) throws -> A?) rethrows -> A? {
	return try optional.flatMap(f)
}

public func <*> <A, B, OT1: OptionalType, OT2: OptionalType>(fn: OT1, g: OT2) -> B?
	where OT1.Wrapped == (A) -> B, OT2.Wrapped == A {
		return g.ap(fn)
}
