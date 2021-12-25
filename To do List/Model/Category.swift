import RealmSwift
import Foundation

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
