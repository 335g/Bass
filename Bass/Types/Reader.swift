//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ReaderType

public protocol ReaderType {
	associatedtype EnvR
	associatedtype ValueR
	
	var run: EnvR -> ValueR { get }
	init(_ run: EnvR -> ValueR)
}

// MARK: - Reader

public struct Reader<R, A> {
	let run: R -> A
}

