//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - IdentityType

public protocol IdentityType: Pointed, Foldable {
	associatedtype Value
	
	var value: Value { get }
	init(_ value: Value)
}

// MARK: - IdentityType: Pointed

public extension IdentityType {
	public static func pure(a: Value) -> Self {
		return Self.init(a)
	}
}

// MARK: - IdentityType: Foldable

public extension IdentityType {
	public func foldMap<M : Monoid>(f: Value -> M) -> M {
		return f(value)
	}
	
	public func foldr<T>(initial: T, _ f: Value -> T -> T) -> T {
		return f(value)(initial)
	}
	
	public func foldr1(f: Value -> Value -> Value) throws -> Value {
		return value
	}
	
	public func foldl<T>(initial: T, _ f: T -> Value -> T) -> T {
		return f(initial)(value)
	}
	
	public func foldl1(f: Value -> Value -> Value) throws -> Value {
		return value
	}
	
	public func null() -> Bool {
		return false
	}
	
	public func length() -> Int {
		return 1
	}
	
	public func find(predicate: Value -> Bool) throws -> Value? {
		guard predicate(value) else {
			return nil
		}
		
		return value
	}
	
	public func toList() -> [Value] {
		return [value]
	}
}

// MARK: - Identity

public final class Identity<T>: IdentityType {
	public typealias PointedValue = T
	
	public let value: T
	
	public init(_ value: T) {
		self.value = value
	}
}

// MARK: - IdentityType - map/flatMap

public extension IdentityType {
	public func map<U>(f: Value -> U) -> Identity<U> {
		return Identity(f(self.value))
	}
	
	public func flatMap<U>(f: Value -> Identity<U>) -> Identity<U> {
		return f(self.value)
	}
}

public func <^> <U, IT: IdentityType>(f: IT.Value -> U, id: IT) -> Identity<U> {
	return id.map(f)
}

public func >>- <U, IT: IdentityType>(id: IT, f: IT.Value -> Identity<U>) -> Identity<U> {
	return id.flatMap(f)
}

// MARK: - IdentityType (Value: OptionalType) - map/flatMap

public extension IdentityType where Value: OptionalType {
	public func map<U>(f: Value.Wrapped -> U) -> Identity<U?> {
		return Identity(f <^> self.value)
	}
	
	public func flatMap<U>(f: Value.Wrapped -> Identity<U>) -> Identity<U?> {
		return Identity( (self.value >>- f)?.value )
	}
}

public func <^> <U, IT: IdentityType where IT.Value: OptionalType>(f: IT.Value.Wrapped -> U, id: IT) -> Identity<U?> {
	return id.map(f)
}

public func >>- <U, IT: IdentityType where IT.Value: OptionalType>(id: IT, f: IT.Value.Wrapped -> Identity<U>) -> Identity<U?> {
	return id.flatMap(f)
}

// MARK: - IdentityType - ap

public extension IdentityType {
	public func ap<T, IT: IdentityType where IT.Value == Value -> T>(id: IT) -> Identity<T> {
		return .pure(id.value(self.value))
	}
}

public func <*> <T, U, IT1: IdentityType, IT2: IdentityType where IT1.Value == T -> U, IT2.Value == T>(left: IT1, right: IT2) -> Identity<U> {
	return right.ap(left)
}

// MARK: - IdentityType (Value: OptionalType) - ap

public extension IdentityType where Value: OptionalType {
	public func ap<T, IT: IdentityType where IT.Value == Value.Wrapped -> T>(id: IT) -> Identity<T?> {
		return .pure(id.value <^> self.value)
	}
}

public func <*> <T: OptionalType, U, IT1: IdentityType, IT2: IdentityType where IT1.Value == T.Wrapped -> U, IT2.Value == T>(left: IT1, right: IT2) -> Identity<U?> {
	return right.ap(left)
}
