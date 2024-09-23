//
//  ViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/3/24.
//

import UIKit

// 앱실행시 보여지는 화면입니다 
class MainViewController: UIViewController {
    
    @IBOutlet weak var moveToCompareViewButton: UIButton!
    
    @IBOutlet weak var frontCakeImageVIew: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRoundlyFrontImage()
    }
    
    func makeRoundlyFrontImage() {
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

