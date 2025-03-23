import Foundation

extension String? {
    var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}
