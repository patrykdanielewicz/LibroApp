//
//  CameraButton.swift
//  Libro
//
//  Created by Patryk Danielewicz on 04.05.2024.
//

import UIKit

class CameraButton: UIButton {
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCameraButton() 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureCameraButton() {
        translatesAutoresizingMaskIntoConstraints = false
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .light, scale: .default)
        setImage(UIImage(systemName: ConstantValuesAndNames.cameraButtonImage, withConfiguration: imageConfig), for: .normal)
        tintColor = ConstantValuesAndNames.secondColor
    }
}
