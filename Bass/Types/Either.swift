//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - EitherType

public protocol EitherType {
	associatedtype LeftType
	associatedtype RightType
	
	static func left(x: LeftType) -> Self
	static func right(x: RightType) -> Self
	
	func either<A>(@noescape ifLeft ifLeft: LeftType throws -> A, @noescape ifRight: RightType throws -> A) rethrows -> A
}

// MARK: - EitherType - map/flatMap

public extension EitherType {
	public func map<T>(@noescape f: LeftType -> T) -> Either<T, RightType> {
		return flatMap { .left(f($0)) }
	}
	
	public func map<T>(@noescape f: RightType -> T) -> Either<LeftType, T> {
		return flatMap { .right(f($0)) }
	}
	
	public func map<T, U>(@noescape lf: LeftType -> T, @noescape rf: RightType -> U) -> Either<T, U> {
		return map(lf).map(rf)
	}
	
	public func flatMap<T>(@noescape g: LeftType -> Either<T, RightType>) -> Either<T, RightType> {
		return either(
			ifLeft: g,
			ifRight: Either.right
		)
	}
	
	public func flatMap<T>(@noescape g: RightType -> Either<LeftType, T>) -> Either<LeftType, T> {
		return either(
			ifLeft: Either.left,
			ifRight: g
		)
	}
}

/// Alias for `map(f:)`
public func <^> <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(f: A -> C, g: ET) -> Either<C, B> {
	return g.map(f)
}

/// Alias for `map(f:)`
public func <^> <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(f: B -> C, g: ET) -> Either<A, C> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(m: ET, fn: A -> Either<C, B>) -> Either<C, B> {
	return m.flatMap(fn)
}

/// Alias for `flatMap(fn:)`
public func >>- <A, B, C, ET: EitherType where ET.LeftType == A, ET.RightType == B>(m: ET, fn: B -> Either<A, C>) -> Either<A, C> {
	return m.flatMap(fn)
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