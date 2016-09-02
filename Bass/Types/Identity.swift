//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - IdentityType

public protocol IdentityType: Pointed, Foldable {
	associatedtype Value
	
	var value: Value { get }
	init(_ value: Value)
}

// MARK: - IdentityType: Pointed

public extension IdentityType {
	public static func pure(_ a: Value) -> Self {
		return Self(a)
	}
}

// MARK: - IdentityType: Foldable

public extension IdentityType {
	public func foldMap<M : Monoid>(_ f: @escaping (Value) -> M) -> M {
		return f(value)
	}
	
	public func foldr<T>(initial: T, _ f: @escaping (Value) -> (T) -> T) -> T {
		return f(value)(initial)
	}
	
	public func foldr1(_ f: (Value) -> (Value) -> Value) throws -> Value {
		return value
	}
	
	public func foldl<T>(initial: T, _ f: (T) -> (Value) -> T) -> T {
		return f(initial)(value)
	}
	
	public func foldl1(_ f: (Value) -> (Value) -> Value) throws -> Value {
		return value
	}
	
	public func null() -> Bool {
		return false
	}
	
	public func length() -> Int {
		return 1
	}
	
	public func find(_ predicate: (Value) -> Bool) throws -> Value? {
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
	public func map<U, I: IdentityType>(_ f: (Value) -> U) -> I
		where I.Value == U {
			return I(f(value))
	}
	
	public func flatMap<U, I: IdentityType>(_ fn: (Value) -> I) -> I
		where I.Value == U {
			return fn(self.value)
	}
	
	public func ap<T, IT: IdentityType>(_ fn: IT) -> Identity<T>
		where IT.Value == (Value) -> T {
			return self >>- { i in fn >>- { f in .pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <U, I1: IdentityType, I2: IdentityType>(_ f: (I1.Value) -> U, g: I1) -> I2
	where I2.Value == U {
		return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <U, IT: IdentityType>(_ m: IT, _ fn: (IT.Value) -> Identity<U>) -> Identity<U> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <T, U, IT1: IdentityType, IT2: IdentityType>(_ fn: IT1, _ g: IT2) -> Identity<U>
	where IT1.Value == (T) -> U, IT2.Value == T {
		return g.ap(fn)
}

// MARK: - IdentityType (Value: OptionalType) - map/flatMap/ap

public extension IdentityType where Value: OptionalType {
	public func map<U, I: IdentityType>(_ f: (Value.Wrapped) -> U) -> I
		where I.Value == U? {
			return I(f <^> self.value)
	}
	
	public func flatMap<U, I1: IdentityType, I2: IdentityType>(_ fn: (Value.Wrapped) -> I1) -> I2
		where I1.Value == U, I2.Value == U? {
			return I2( (self.value >>- fn)?.value)
	}
	
	public func ap<T, IT: IdentityType>(_ fn: IT) -> Identity<T?>
		where IT.Value == (Value.Wrapped) -> T {
			return self >>- { i in fn >>- { f in .pure(f(i)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <U, I1: IdentityType, I2: IdentityType>(_ f: (I1.Value.Wrapped) -> U, g: I1) -> I2
	where I1.Value: OptionalType, I2.Value == U? {
		return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <U, IT: IdentityType>(m: IT, fn: (IT.Value.Wrapped) -> Identity<U>) -> Identity<U?>
	where IT.Value: OptionalType {
		return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <T: OptionalType, U, IT1: IdentityType, IT2: IdentityType>(fn: IT1, g: IT2) -> Identity<U?>
	where IT1.Value == (T.Wrapped) -> U, IT2.Value == T {
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
