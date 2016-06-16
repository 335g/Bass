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
	public func map<A>(_ f: @noescape (Wrapped) throws -> A) rethrows -> A? {
		return try optional.map(f)
	}
	
	public func flatMap<A>(_ f: @noescape (Wrapped) throws -> A?) rethrows -> A? {
		return try optional.flatMap(f)
	}
}

public func <^> <A, OT: OptionalType>(_ f: @noescape (OT.Wrapped) throws -> A, _ optional: OT) rethrows -> A? {
	return try optional.map(f)
}

public func >>- <A, OT: OptionalType>(_ optional: OT, _ f: @noescape (OT.Wrapped) throws -> A?) rethrows -> A? {
	return try optional.flatMap(f)
}

// MARK: - OptionalType - ap

public extension OptionalType {
	public func ap<A, OT: OptionalType where OT.Wrapped == (Wrapped) -> A>(_ fn: OT) -> A? {
		return fn >>- { f in map(f) }
	}
}

public func <*> <A, B, OT1: OptionalType, OT2: OptionalType where OT1.Wrapped == (A) -> B, OT2.Wrapped == A>(fn: OT1, g: OT2) -> B? {
	return g.ap(fn)
}
