//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - EitherType

public protocol EitherType: Pointed, Foldable {
	associatedtype LeftType
	associatedtype RightType
	
	static func left(x: LeftType) -> Self
	static func right(x: RightType) -> Self
	
	func either<A>(@noescape ifLeft ifLeft: LeftType throws -> A, @noescape ifRight: RightType throws -> A) rethrows -> A
}

// MARK: - EitherType: Pointed

public extension EitherType {
	public static func pure(x: RightType) -> Self {
		return .right(x)
	}
}

// MARK: - EitherType: Foldable

public extension EitherType {
	public func foldMap<M : Monoid>(f: RightType -> M) -> M {
		return either(
			ifLeft: const(.mempty),
			ifRight: { f($0) }
		)
	}
	
	public func foldr<T>(initial: T, _ f: RightType -> T -> T) -> T {
		return either(
			ifLeft: const(initial),
			ifRight: { f($0)(initial) }
		)
	}
	
	public func foldl<T>(initial: T, _ f: T -> RightType -> T) -> T {
		return either(
			ifLeft: const(initial),
			ifRight: { f(initial)($0) }
		)
	}
	
	public func null() -> Bool {
		return isRight
	}
	
	public func length() -> Int {
		return either(
			ifLeft: const(0),
			ifRight: const(1)
		)
	}
	
	public func find(predicate: RightType -> Bool) throws -> RightType? {
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
}

// MARK: - EitherType - map/flatMap/ap

public extension EitherType {
	public func map<T>(@noescape f: RightType -> T) -> Either<LeftType, T> {
		return flatMap { .right(f($0)) }
	}
	
	public func bimap<T, U>(@noescape f: LeftType -> T, @noescape g: RightType -> U) -> Either<T, U> {
		return either(
			ifLeft: { .left(f($0)) },
			ifRight: { .right(g($0)) }
		)
	}
	
	public func flatMap<T>(@noescape fn: RightType -> Either<LeftType, T>) -> Either<LeftType, T> {
		return either(
			ifLeft: Either.left,
			ifRight: fn
		)
	}
	
	public func ap<T, ET: EitherType where ET.LeftType == LeftType, ET.RightType == RightType -> T>(fn: ET) -> Either<LeftType, T> {
		return fn.either(
			ifLeft: { .left($0) },
			ifRight: { map($0) }
		)
	}
}

/// Alias for `map(f:)`
public func <^> <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(f: B -> C, g: ET) -> Either<A, C> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(m: ET, fn: B -> Either<A, C>) -> Either<A, C> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <L, T, U, ET1: EitherType, ET2: EitherType where ET1.LeftType == L, ET1.RightType == T -> U, ET2.LeftType == L, ET2.RightType == T>(fn: ET1, m: ET2) -> Either<L, U> {
	return m.ap(fn)
}

// MARK: - Either

public enum Either<L, R> {
	case Left(L)
	case Right(R)
}

// MARK: - Either: EitherType

extension Either: EitherType {
	public typealias LeftType = L
	public typealias RightType = R
	
	public static func left(x: LeftType) -> Either<L, R> {
		return .Left(x)
	}
	
	public static func right(x: RightType) -> Either<L, R> {
		return .Right(x)
	}
	
	public func either<A>(@noescape ifLeft ifLeft: L throws -> A, @noescape ifRight: R throws -> A) rethrows -> A {
		switch self {
		case .Left(let x):
			return try ifLeft(x)
		case .Right(let x):
			return try ifRight(x)
		}
	}
}

// MARK: - Either: Pointed

extension Either: Pointed {
	public typealias PointedValue = R
}
