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
	public func map<IT: IdentityType>(_ f: (Value) -> IT.Value) -> IT {
		return IT(f(value))
	}
	
	public func flatMap<IT: IdentityType>(_ fn: (Value) -> IT) -> IT {
		return fn(value)
	}
	
	public func ap<IT1: IdentityType, IT2: IdentityType where IT1.Value == (Value) -> IT2.Value>(_ fn: IT1) -> IT2 {
		return self >>- { i in fn >>- { f in .pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <IT1: IdentityType, IT2: IdentityType>(_ f: (IT1.Value) -> IT2.Value, g: IT1) -> IT2 {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <IT1: IdentityType, IT2: IdentityType>(_ m: IT1, _ fn: (IT1.Value) -> IT2) -> IT2 {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <IT1: IdentityType, IT2: IdentityType, IT3: IdentityType where IT1.Value == (IT2.Value) -> IT3.Value>(_ fn: IT1, _ g: IT2) -> IT3 {
	return g.ap(fn)
}

// MARK: - IdentityType (Value: OptionalType) - map/flatMap/ap

public extension IdentityType where Value: OptionalType {
	public func map<T, IT: IdentityType where IT.Value == T?>(_ f: (Value.Wrapped) -> T) -> IT {
		return IT(f <^> value)
	}
	
	public func flatMap<T, IT1: IdentityType, IT2: IdentityType where IT1.Value == T, IT2.Value == T?>(_ fn: (Value.Wrapped) -> IT1) -> IT2 {
		return IT2( (value >>- fn)?.value )
	}
	
	public func ap<T, IT1: IdentityType, IT2: IdentityType, IT3: IdentityType where IT1.Value == (Value.Wrapped) -> T, IT2.Value == T?, IT3.Value == T>(_ fn: IT1) -> IT2 {
		return self >>- { i in fn >>- { f in IT3.pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <T, IT1: IdentityType, IT2: IdentityType where IT1.Value: OptionalType, IT2.Value == T?>(_ f: (IT1.Value.Wrapped) -> T, g: IT1) -> IT2 {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <T, IT1: IdentityType, IT2: IdentityType, IT3: IdentityType where IT1.Value: OptionalType, IT2.Value == T, IT3.Value == T?>(m: IT1, fn: (IT1.Value.Wrapped) -> IT2) -> IT3 {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
//public func <*> <T: OptionalType, U, IT1: IdentityType, IT2: IdentityType where IT1.Value == (T.Wrapped) -> U, IT2.Value == T>(fn: IT1, g: IT2) -> Identity<U?> {
//	return g.ap(fn)
//}

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
