//
//  CollectionCellImages.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//

import Foundation
import UIKit

class CollectionCellImages: UIImageView {
    
    
    func downloadImage(stringURL: String,  completionHandler: @escaping() -> Void){
        self.image = nil
        print("hello world")
        guard let url = URL(string: stringURL) else {return}
        
        DispatchQueue.main.async {
            guard let imageData = try? Data(contentsOf: url) else {return}
                self.image = UIImage(data: imageData)
                completionHandler()
            }
        }
    }

