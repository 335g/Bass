//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ReaderType

public protocol ReaderType {
	associatedtype EnvR
	associatedtype ValueR
	
	var run: EnvR -> ValueR { get }
	init(_ run: EnvR -> ValueR)
	
	var reader: Reader<EnvR, ValueR> { get }
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

