
import Foundation
import Bass

extension Int: Monoid {
	public typealias PointedValue = Int
	
	public static func pure(a: Int) -> Int {
		return a
	}
	
	public func mappend(x: Int) -> Int {
		return self + x
	}
	
	public static var mempty: Int {
		return 0
	}
}

let a: Writer<Int, Int, (Int, Int)> = .pure(0)
"a"


