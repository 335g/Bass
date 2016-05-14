//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ReaderType

public protocol ReaderType: Pointed {
	associatedtype EnvR
	associatedtype ValueR
	
	var run: EnvR -> ValueR { get }
	init(_ run: EnvR -> ValueR)
	
	var reader: Reader<EnvR, ValueR> { get }
}

// MARK: - ReaderType: Pointed

public extension ReaderType {
	public typealias PointedValue = EnvR -> ValueR
	public static func pure(a: EnvR -> ValueR) -> Self {
		return Self.init(a)
	}
}

// MARK: - Reader

public struct Reader<R, A> {
	public let run: R -> A
}

// MARK: - Reader: ReaderType

extension Reader: ReaderType {
	public init(_ run: R -> A) {
		self.run = run
	}
	
	public var reader: Reader<R, A> {
		return self
	}
}

// MARK: - Reader: Pointed

public extension Reader {
	public typealias PointedValue = R -> A
}

