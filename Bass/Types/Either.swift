//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - EitherType

public protocol EitherType: Pointed, Foldable {
	associatedtype LeftType
	associatedtype RightType
	
	init(left: LeftType)
	init(right: RightType)
	
	func either<A>(ifLeft: @noescape (LeftType) throws -> A, ifRight: @noescape (RightType) throws -> A) rethrows -> A
}

// MARK: - EitherType: Pointed

public extension EitherType {
	public static func pure(_ x: RightType) -> Self {
		return Self(right: x)
	}
}

// MARK: - EitherType: Foldable

public extension EitherType {
	public func foldMap<M : Monoid>(_ f: (RightType) -> M) -> M {
		return either(
			ifLeft: const(.mempty),
			ifRight: { f($0) }
		)
	}
	
	public func foldr<T>(initial: T, _ f: (RightType) -> (T) -> T) -> T {
		return either(
			ifLeft: const(initial),
			ifRight: { f($0)(initial) }
		)
	}
	
	public func foldl<T>(initial: T, _ f: (T) -> (RightType) -> T) -> T {
		return either(
			ifLeft: const(initial),
			ifRight: { f(initial)($0) }
		)
	}
	
	public func null() -> Bool {
		return isLeft
	}
	
	public func length() -> Int {
		return either(
			ifLeft: const(0),
			ifRight: const(1)
		)
	}
	
	public func find(_ predicate: (RightType) -> Bool) throws -> RightType? {
		return either(
			ifLeft: const(nil),
			ifRight: { predicate($0) ? $0 : nil }
		)
	}
	
	public func toList() -> [RightType] {
		return either(
			ifLeft: const([]),
			ifRight: { [$0] }
		)
	}
}

// MARK: - EitherType - method

public extension EitherType {
	public var left: LeftType? {
		return either(
			ifLeft: id,
			ifRight: const(nil)
		)
	}
	
	public var right: RightType? {
		return either(
			ifLeft: const(nil),
			ifRight: id
		)
	}
	
	public var isLeft: Bool {
		return either(
			ifLeft: const(true),
			ifRight: const(false)
		)
	}
	
	public var isRight: Bool {
		return either(
			ifLeft: const(false),
			ifRight: const(true)
		)
	}
	
	public func getOrElse(_ x: RightType) -> RightType {
		return either(
			ifLeft: const(x),
			ifRight: id
		)
	}
	
	public func toOptional() -> RightType? {
		return either(
			ifLeft: const(.none),
			ifRight: { .some($0) }
		)
	}
	
	public func valueOr(_ x: (LeftType) -> RightType) -> RightType {
		return either(
			ifLeft: { x($0) },
			ifRight: id
		)
	}
}

// MARK: - EitherType - map/flatMap/ap

public extension EitherType {
	public func map<T>(_ f: (LeftType) -> T) -> Either<T, RightType> {
		return either(
			ifLeft: { .left(f($0)) },
			ifRight: Either.right
		)
	}
	
	public func map<T>(_ f: (RightType) -> T) -> Either<LeftType, T> {
		return either(
			ifLeft: Either.left,
			ifRight: { .right(f($0)) }
		)
	}
	
	public func bimap<T, U>(_ f: @noescape (LeftType) -> T, _ g: @noescape (RightType) -> U) -> Either<T, U> {
		return either(
			ifLeft: { .left(f($0)) },
			ifRight: { .right(g($0)) }
		)
	}
	
	public func flatMap<T>(_ fn: @noescape (RightType) -> Either<LeftType, T>) -> Either<LeftType, T> {
		return either(
			ifLeft: Either.left,
			ifRight: fn
		)
	}
	
	public func ap<T, ET: EitherType where ET.LeftType == LeftType, ET.RightType == (RightType) -> T>(_ fn: ET) -> Either<LeftType, T> {
		return fn.either(
			ifLeft: { .left($0) },
			ifRight: { map($0) }
		)
	}
}

/// Alias for `map(f:)`
public func <^> <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(_ f: (B) -> C, _ g: ET) -> Either<A, C> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(_ m: ET, _ fn: (B) -> Either<A, C>) -> Either<A, C> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <L, T, U, ET1: EitherType, ET2: EitherType where ET1.LeftType == L, ET1.RightType == (T) -> U, ET2.LeftType == L, ET2.RightType == T>(_ fn: ET1, _ m: ET2) -> Either<L, U> {
	return m.ap(fn)
}

// MAKR: - State - Kleisli

public func >>->> <L, A, B, C>(_ left: (A) -> Either<L, B>, _ right: (B) -> Either<L, C>) -> (A) -> Either<L, C> {
	return { a in left(a) >>- right }
}

public func <<-<< <L, A, B, C>(_ left: (B) -> Either<L, C>, _ right: (A) -> Either<L, B>) -> (A) -> Either<L, C> {
	return right >>->> left
}

// MARK: - Lift

public func lift<L, A, B, C>(_ f: (A, B) -> C) -> Either<L, (A) -> (B) -> C> {
	return .pure(curry(f))
}

public func lift<L, A, B, C, D>(_ f: (A, B, C) -> D) -> Either<L, (A) -> (B) -> (C) -> D> {
	return .pure(curry(f))
}

public func lift<L, A, B, C, D, E>(_ f: (A, B, C, D) -> E) -> Either<L, (A) -> (B) -> (C) -> (D) -> E> {
	return .pure(curry(f))
}

// MARK: - Either

public enum Either<L, R> {
	case left(L)
	case right(R)
}

// MARK: - Either: EitherType

extension Either: EitherType {
	public typealias Element = R
	
	public typealias LeftType = L
	public typealias RightType = R
	
	public init(left: L) {
		self = .left(left)
	}
	
	public init(right: R) {
		self = .right(right)
	}
	
	public func either<A>(ifLeft: @noescape (L) throws -> A, ifRight: @noescape (R) throws -> A) rethrows -> A {
		switch self {
		case .left(let x):
			return try ifLeft(x)
		case .right(let x):
			return try ifRight(x)
		}
	}
}

// MARK: - Either: Pointed

extension Either: Pointed {
	public typealias Value = R
}
