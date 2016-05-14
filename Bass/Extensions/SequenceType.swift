//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - SequenceType

public extension SequenceType where Generator.Element: ReaderType {
	public func sequece() -> Reader<Generator.Element.EnvR, [Generator.Element.ValueR]> {
		return reduce(.pure([])){ acc, elem in
			return acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}
