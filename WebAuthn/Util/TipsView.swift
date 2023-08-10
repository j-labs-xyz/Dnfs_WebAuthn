//
//  TipsView.swift
//  Tethers
//
//  Created by J Labs
//

import UIKit

class TipsView: UIView {

    var tipsLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tipsView = UIView()
        tipsView.layer.cornerRadius = 8
        tipsView.layer.masksToBounds = true
        tipsView.backgroundColor = UIColor.color_F42147
        self.addSubview(tipsView)
        tipsView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(-15)
        }
        
        
        let tipsLabel = UILabel()
        tipsLabel.textColor = .white
        tipsLabel.font = UIFont.systemFont(ofSize: 15)
        tipsView.addSubview(tipsLabel)
        self.tipsLabel = tipsLabel
        tipsLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
        
        let iconView = UIImageView(image: UIImage(named: "check_icon"))
        iconView.contentMode = .scaleAspectFit
        tipsView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalToSuperview()
            make.left.equalTo(tipsLabel.snp.right).offset(20)
            make.right.equalTo(-20)
        }
        
        
    }
    
    func show(tips: String,inView: UIView) {
        self.tipsLabel.text = tips
        self.transform = CGAffineTransform(translationX: 0, y: Screen_Height)
        self.addedOn(inView).snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalTo(-10)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.96, initialSpringVelocity: 15) {
            self.transform = CGAffineTransformIdentity
        } completion: { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 0
                } completion: { finish in
                    self.removeFromSuperview()
                }
            }
        }
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let arrowSize = CGSize(width: 10, height: 8)
        let arrowPath = UIBezierPath()
        let arrowX = self.bounds.width/2
        let arrowY = 52.0
        arrowPath.move(to: CGPoint(x: arrowX, y: arrowY))
        arrowPath.addLine(to: CGPoint(x: arrowX - arrowSize.width/2, y: arrowY - arrowSize.height))
        arrowPath.addLine(to: CGPoint(x: arrowX - arrowSize.width/2, y: arrowY - arrowSize.height))
        arrowPath.addLine(to: CGPoint(x: arrowX + arrowSize.width/2, y: arrowY - arrowSize.height))
        arrowPath.addLine(to: CGPoint(x: arrowX + arrowSize.width/2, y: arrowY - arrowSize.height))

        let shape = CAShapeLayer()
        //填充色
        shape.fillColor = UIColor.color_F42147.cgColor
        shape.path = arrowPath.cgPath
        layer.addSublayer(shape)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
