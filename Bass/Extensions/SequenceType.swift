//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - SequenceType (ReaderType)

public extension Sequence where Iterator.Element: ReaderType {
	public func sequece() -> Reader<Iterator.Element.EnvR, [Iterator.Element.ValueR]> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

// MARK: - SequenceType (WriterType)

public extension Sequence where Iterator.Element: WriterType, Iterator.Element.ValuesW == (Iterator.Element.ResultW, Iterator.Element.OutputW) {
	public func sequence() -> Writer<Iterator.Element.OutputW, [Iterator.Element.ResultW], ([Iterator.Element.ResultW], Iterator.Element.OutputW)> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

// MARK: - SequenceType (StateType)

public extension Sequence where Iterator.Element: StateType, Iterator.Element.ValuesS == (Iterator.Element.ResultS, Iterator.Element.StateS) {
	public func sequence() -> State<Iterator.Element.StateS, [Iterator.Element.ResultS], ([Iterator.Element.ResultS], Iterator.Element.StateS)> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}

// MARK: - SequenceType (EitherType)

public extension Sequence where Iterator.Element: EitherType {
	public var rights: [Iterator.Element.RightType] {
		return map{ $0.right }
			.filter{ $0 != nil }
			.map{ $0! }
	}
	
	public var lefts: [Iterator.Element.LeftType] {
		return map{ $0.left }
			.filter{ $0 != nil }
			.map{ $0! }
	}
	
	public var partition: ([Iterator.Element.LeftType], [Iterator.Element.RightType]) {
		return (lefts, rights)
	}
	
	public func sequence() -> Either<Iterator.Element.LeftType, [Iterator.Element.RightType]> {
		return reduce(.pure([])){ acc, elem in
			acc >>- { xs in elem >>- { .pure(xs + [$0]) } }
		}
	}
}
