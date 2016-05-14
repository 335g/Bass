//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ContType

public protocol ContType: Pointed {
	associatedtype InterRC // Intermediate Result of ContType
	associatedtype FinalRC // Final Result of ContType
	
	var run: (InterRC -> FinalRC) -> FinalRC { get }
	init(_ run: (InterRC -> FinalRC) -> FinalRC)
}

// MARK: - ContType: Pointed

public extension ContType {
	public static func pure(a: FinalRC) -> Self {
		return Self.init { _ in a }
	}
}

// MARK: - ContType - method

public extension ContType where InterRC == FinalRC {
	
	/// The result of running a CPS computation with the identity as the final continuation.
	public var eval: InterRC {
		return run { $0 }
	}
}

// MARK: - Cont

public struct Cont<I, F> {
	public let run: (I -> F) -> F
}

// MARK: - Cont: ContType

extension Cont: ContType {
	public typealias InterRC = I
	public typealias FinalRC = F
	
	public init(_ run: (I -> F) -> F) {
		self.run = run
	}
}

// MARK: - Cont: Pointed

extension Cont {
	public typealias PointedValue = F
}