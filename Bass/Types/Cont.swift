//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ContType

public protocol ContType: Pointed {
	associatedtype IRC // Intermediate Result of ContType
	associatedtype FRC // Final Result of ContType
	
	var run: (IRC -> FRC) -> FRC { get }
	init(_ run: (IRC -> FRC) -> FRC)
}

// MARK: - ContType: Pointed

public extension ContType {
	public static func pure(a: IRC) -> Self {
		return Self.init{ f in f(a) }
	}
}

// MARK: - ContType - method

public extension ContType where IRC == FRC {
	/// The result of running a CPS computation with the identity as the final continuation.
	public var eval: FRC {
		return run { $0 }
	}
}

public extension ContType {
	/// Apply a function to transform the continuation passed to a CPS computation.
	public func with<I>(f: (I -> FRC) -> (IRC -> FRC)) -> Cont<FRC, I> {
		return Cont { self.run(f($0)) }
	}
}

// MARK: - ContType - map/flatMap/ap

public extension ContType {
	public func map(f: FRC -> FRC) -> Cont<FRC, IRC> {
		return Cont(f • self.run)
	}
	
	public func map<I>(f: IRC -> I) -> Cont<FRC, I> {
		return Cont { self.run($0 • f) }
	}
	
	public func flatMap<I>(g: IRC -> Cont<FRC, I>) -> Cont<FRC, I> {
		return Cont { c in self.run{ g($0).run(c) } }
	}
	
	public func ap<I, CT: ContType where CT.IRC == IRC -> I, CT.FRC == FRC>(fn: CT) -> Cont<FRC, I> {
		return Cont { c in fn.run{ g in self.run(c • g) } }
	}
}

/// Alias for `map(f:)`
public func <^> <I, F, CT: ContType where CT.IRC == I, CT.FRC == F>(f: F -> F, g: CT) -> Cont<F, I> {
	return g.map(f)
}

/// Alias for `map(f:)`
public func <^> <I, I2, F, CT: ContType where CT.IRC == I, CT.FRC == F>(f: I -> I2, g: CT) -> Cont<F, I2> {
	return g.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <I, I2, F, CT: ContType where CT.IRC == I, CT.FRC == F>(m: CT, fn: I -> Cont<F, I2>) -> Cont<F, I2> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <I, I2, F, CT1: ContType, CT2: ContType where CT1.IRC == I -> I2, CT1.FRC == F, CT2.IRC == I, CT2.FRC == F>(fn: CT1, m: CT2) -> Cont<F, I2> {
	return m.ap(fn)
}

// MARK: - Cont

public struct Cont<F, I> {
	public let run: (I -> F) -> F
}

// MARK: - Cont: ContType

extension Cont: ContType {
	public typealias IRC = I
	public typealias FRC = F
	
	public init(_ run: (I -> F) -> F) {
		self.run = run
	}
}

// MARK: - Cont: Pointed

extension Cont {
	public typealias PointedValue = I
}

// MARK: - Functions

public func callCC<F, I1, I2>(f: (I1 -> Cont<F, I2>) -> Cont<F, I1>) -> Cont<F, I1> {
	return Cont { c in
		f{ x in Cont{ _ in c(x) } }.run(c)
	}
}
