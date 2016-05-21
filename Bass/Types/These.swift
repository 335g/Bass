//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - TheseType

public protocol TheseType: Pointed, Foldable {
	associatedtype ThisType
	associatedtype ThatType
	
	static func this(x: ThisType) -> Self
	static func that(x: ThatType) -> Self
	static func both(x: ThisType, _ y: ThatType) -> Self
	
	func these<T>(@noescape ifThis ifThis: ThisType throws -> T, ifThat: ThatType throws -> T, ifBoth: (ThisType, ThatType) throws -> T) rethrows -> T
}

// MARK: - TheseType: Pointed

public extension TheseType {
	public static func pure(x: ThatType) -> Self {
		return .that(x)
	}
}

// MARK: - TheseType: Foldable

public extension TheseType {
	public func foldMap<M : Monoid>(f: ThatType -> M) -> M {
		return these(
			ifThis: const(.mempty),
			ifThat: { f($0) },
			ifBoth: { f($1) }
		)
	}
	
	public func foldr<T>(initial: T, _ f: ThatType -> T -> T) -> T {
		return these(
			ifThis: const(initial),
			ifThat: { f($0)(initial) },
			ifBoth: { f($1)(initial) }
		)
	}
	
	public func null() -> Bool {
		return isThis
	}
	
	public func length() -> Int {
		return these(
			ifThis: const(0),
			ifThat: const(1),
			ifBoth: const(1)
		)
	}
	
	public func find(predicate: ThatType -> Bool) throws -> ThatType? {
		return these(
			ifThis: const(nil),
			ifThat: { predicate($0) ? $0 : nil },
			ifBoth: { predicate($1) ? $1 : nil }
		)
	}
	
	public func toList() -> [ThatType] {
		return these(
			ifThis: const([]),
			ifThat: { [$0] },
			ifBoth: { [$1] }
		)
	}
}

// MARK: - These: Semigroup (This, That : Semigroup)

public extension TheseType where ThisType: Semigroup, ThatType: Semigroup {
	public func mappend(other: Self) -> Self {
		return these(
			ifThis: { a in
				return other.these(
					ifThis: { .this(a <> $0) },
					ifThat: { .both(a, $0) },
					ifBoth: { .both(a <> $0, $1) }
				)
			},
			ifThat: { b in
				return other.these(
					ifThis: { .both($0, b) },
					ifThat: { .that(b <> $0) },
					ifBoth: { .both($0, b <> $1) }
				)
			},
			ifBoth: { a, b in
				return other.these(
					ifThis: { .both(a <> $0, b) },
					ifThat: { .both(a, b <> $0) },
					ifBoth: { .both(a <> $0, b <> $1) }
				)
			}
		)
	}
}

public func <> <TT: TheseType where TT.ThisType: Semigroup, TT.ThatType: Semigroup>(lhs: TT, rhs: TT) -> TT {
	return lhs.mappend(rhs)
}

// MARK: - TheseType - method

public extension TheseType {
	public var this: ThisType? {
		return these(
			ifThis: id,
			ifThat: const(nil),
			ifBoth: const(nil)
		)
	}
	
	public var that: ThatType? {
		return these(
			ifThis: const(nil),
			ifThat: id,
			ifBoth: const(nil)
		)
	}
	
	public var both: (ThisType, ThatType)? {
		return these(
			ifThis: const(nil),
			ifThat: const(nil),
			ifBoth: id
		)
	}
	
	public var isThis: Bool {
		return these(
			ifThis: const(true),
			ifThat: const(false),
			ifBoth: const(false)
		)
	}
	
	public var isThat: Bool {
		return these(
			ifThis: const(false),
			ifThat: const(true),
			ifBoth: const(false)
		)
	}
	
	public var isBoth: Bool {
		return these(
			ifThis: const(false),
			ifThat: const(false),
			ifBoth: const(true)
		)
	}
}

// MARK: - TheseType - map/flatMap/ap

public extension TheseType {
	public func map<T>(f: ThisType -> T) -> These<T, ThatType> {
		return bimap(f, id)
	}
	
	public func map<T>(f: ThatType -> T) -> These<ThisType, T> {
		return bimap(id, f)
	}
	
	public func bimap<T, U>(f: ThisType -> T, _ g: ThatType -> U) -> These<T, U> {
		return these(
			ifThis: { .this(f($0)) },
			ifThat: { .that(g($0)) },
			ifBoth: { .both(f($0), g($1)) })
	}
}

// MARK; - These

public enum These<A, B> {
	case This(A)
	case That(B)
	case Both(A, B)
}

// MARK: - These: TheseType

extension These: TheseType {
	public typealias ThisType = A
	public typealias ThatType = B
	
	public static func this(x: A) -> These {
		return .This(x)
	}
	
	public static func that(x: B) -> These {
		return .That(x)
	}
	
	public static func both(x: A, _ y: B) -> These {
		return .Both(x, y)
	}
	
	public func these<T>(@noescape ifThis ifThis: A throws -> T, ifThat: B throws -> T, ifBoth: (A, B) throws -> T) rethrows -> T {
		switch self {
		case .This(let a):
			return try ifThis(a)
		case .That(let b):
			return try ifThat(b)
		case .Both(let a, let b):
			return try ifBoth(a, b)
		}
	}
}

// MARK: These: Pointed

extension These: Pointed {
	public typealias PointedValue = B
}
