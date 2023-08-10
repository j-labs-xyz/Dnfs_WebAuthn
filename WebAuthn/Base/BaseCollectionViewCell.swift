import UIKit
import Reusable

open class BaseCollectionViewCell: UICollectionViewCell, Reusable {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func createUI() {
        
    }
}

extension UICollectionViewCell: LXReuseIdProtocol {
    public static func reuseId() -> String {
        return String(NSStringFromClass(Self.classForKeyedUnarchiver()))
    }
}

extension UICollectionView {
    public func deqCell<T: LXReuseIdProtocol>(c:T.Type, indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: c.reuseId(), for: indexPath) as? T
    }
}
