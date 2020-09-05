//
//  UIView+Ext.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/18.
//  Copyright © 2020 hanmok. All rights reserved.
//

import UIKit

extension UIView{
    func pin(to superView : UIView){
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
    
    func pinWithSpace(to superView : UIView){
        translatesAutoresizingMaskIntoConstraints = false
//        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        topAnchor.constraint(equalTo: superView.topAnchor, constant: 60).isActive = true
//        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -15).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
    
    func pinWithSpace2(to superView : UIView){
            translatesAutoresizingMaskIntoConstraints = false
    //        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
            topAnchor.constraint(equalTo: superView.topAnchor, constant: 60).isActive = true
    //        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    
}
