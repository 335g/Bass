//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - SequenceType

public extension SequenceType where Generator.Element: ReaderType {
	public func sequece() -> Reader<Generator.Element.EnvR, [Generator.Element.ValueR]> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

public extension SequenceType where Generator.Element: WriterType, Generator.Element.ValuesW == (Generator.Element.ResultW, Generator.Element.OutputW) {
	public func sequence() -> Writer<Generator.Element.OutputW, [Generator.Element.ResultW], ([Generator.Element.ResultW], Generator.Element.OutputW)> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

public extension SequenceType where Generator.Element: StateType, Generator.Element.ValuesS == (Generator.Element.ResultS, Generator.Element.StateS) {
	public func sequence() -> State<Generator.Element.StateS, [Generator.Element.ResultS], ([Generator.Element.ResultS], Generator.Element.StateS)> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

public extension SequenceType where Generator.Element: EitherType {
	public var rights: [Generator.Element.RightType] {
		return map{ $0.right }
			.filter{ $0 != nil }
			.map{ $0! }
	}
	
	public var lefts: [Generator.Element.LeftType] {
		return map{ $0.left }
			.filter{ $0 != nil }
			.map{ $0! }
	}
	
	public var partition: ([Generator.Element.LeftType], [Generator.Element.RightType]) {
		return (lefts, rights)
	}
}
