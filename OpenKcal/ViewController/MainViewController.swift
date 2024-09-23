//
//  ViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/3/24.
//

import UIKit


class MainViewController: UIViewController {
    
    @IBOutlet weak var moveToCompareViewButton: UIButton!
    
    @IBOutlet weak var frontCakeImageVIew: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customStyleFrontImage()
    }
    
    func customStyleFrontImage() {
        frontCakeImageVIew.layer.cornerRadius = 15
        frontCakeImageVIew.mask?.layer.masksToBounds = true
        moveToCompareViewButton.tintColor = .systemPurple
        
        
    }
    
    @IBAction func createCakeDB(_ sender: UIButton) {
        
        
    }
    @IBAction func moveToCompareViewAction(_ sender: UIButton) {
        
            self.performSegue(withIdentifier: "moveToCompareView", sender: self)
    }
    

}

