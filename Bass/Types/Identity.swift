//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - IdentityType

public protocol IdentityType: Pointed, Foldable {
	var value: Value { get }
	init(_ value: Value)
}

// MARK: - IdentityType: Pointed

public extension IdentityType {
	public static func pure(_ a: Value) -> Self {
		return Self.init(a)
	}
}

// MARK: - IdentityType: Foldable

public extension IdentityType {
	public func foldMap<M : Monoid>(f: (Value) -> M) -> M {
		return f(value)
	}
	
	public func foldr<T>(initial: T, _ f: (Value) -> (T) -> T) -> T {
		return f(value)(initial)
	}
	
	public func foldr1(f: (Value) -> (Value) -> Value) throws -> Value {
		return value
	}
	
	public func foldl<T>(initial: T, _ f: (T) -> (Value) -> T) -> T {
		return f(initial)(value)
	}
	
	public func foldl1(f: (Value) -> (Value) -> Value) throws -> Value {
		return value
	}
	
	public func null() -> Bool {
		return false
	}
	
	public func length() -> Int {
		return 1
	}
	
	public func find(predicate: (Value) -> Bool) throws -> Value? {
		guard predicate(value) else {
			return nil
		}
		
		return value
	}
	
	public func toList() -> [Value] {
		return [value]
	}
}

// MARK: - IdentityType - map/flatMap/ap

public extension IdentityType {
	public func map<U>(_ f: (Value) -> U) -> Identity<U> {
		return Identity(f(self.value))
	}
	
	public func flatMap<U>(_ fn: (Value) -> Identity<U>) -> Identity<U> {
		return fn(self.value)
	}
	
	public func ap<T, IT: IdentityType where IT.Value == (Value) -> T>(_ fn: IT) -> Identity<T> {
		return self >>- { i in fn >>- { f in .pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <U, IT: IdentityType>(_ f: (IT.Value) -> U, g: IT) -> Identity<U> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <U, IT: IdentityType>(_ m: IT, _ fn: (IT.Value) -> Identity<U>) -> Identity<U> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <T, U, IT1: IdentityType, IT2: IdentityType where IT1.Value == (T) -> U, IT2.Value == T>(_ fn: IT1, _ g: IT2) -> Identity<U> {
	return g.ap(fn)
}

// MARK: - IdentityType (Value: OptionalType) - map/flatMap/ap

public extension IdentityType where Value: OptionalType {
	public func map<U>(_ f: (Value.Wrapped) -> U) -> Identity<U?> {
		return Identity(f <^> self.value)
	}
	
	public func flatMap<U>(_ fn: (Value.Wrapped) -> Identity<U>) -> Identity<U?> {
		return Identity( (self.value >>- fn)?.value )
	}
	
	public func ap<T, IT: IdentityType where IT.Value == (Value.Wrapped) -> T>(_ fn: IT) -> Identity<T?> {
		return self >>- { i in fn >>- { f in .pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <U, IT: IdentityType where IT.Value: OptionalType>(_ f: (IT.Value.Wrapped) -> U, g: IT) -> Identity<U?> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <U, IT: IdentityType where IT.Value: OptionalType>(m: IT, fn: (IT.Value.Wrapped) -> Identity<U>) -> Identity<U?> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <T: OptionalType, U, IT1: IdentityType, IT2: IdentityType where IT1.Value == (T.Wrapped) -> U, IT2.Value == T>(fn: IT1, g: IT2) -> Identity<U?> {
	return g.ap(fn)
}

// MARK: - Identity

public struct Identity<T> {
	public let value: T
}

// MARK: - Identity: IdentityType

extension Identity: IdentityType {
	public typealias Value = T
	
	public init(_ value: T) {
		self.value = value
	}
}
