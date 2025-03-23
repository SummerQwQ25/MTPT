import Foundation

extension Array<Any>? {
    var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
} 
