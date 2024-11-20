//
//  ViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/3/24.
//

import UIKit
import SwiftUI

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
    
    @IBAction func moveToOperationDBVC(_ sender: UIButton) {
        
        
    }
    
    @IBAction func LinkKakaoChat(_ sender: UIButton) {
        let kakaoLink = "https://open.kakao.com/o/sBp2720g"
        //MARK: -- 앱스토어 링크가 잘가지는지에 대해서는 아직 검증하지 못해봄
        let appStoreLink = "https://apps.apple.com/app/id123456789"
        
        func openKaKaoOpenChat() {
            
            convertLinkToURL(appStoreLink: appStoreLink)
            //link url객체로 변환
            func convertLinkToURL(appStoreLink : String) {
                guard  let appStoreURL = URL(string: appStoreLink),
                       let kakaoURL = URL(string: kakaoLink) else {
                    print("URL이 유효하지 않습니다.")
                    return
                }
                
                openURL1(kakaoURL: kakaoURL, appStoreURL: appStoreURL)
            }
            
            
            func openURL1(kakaoURL: URL, appStoreURL: URL) {
                //canOepnURL은 return이 bool타입
                if  UIApplication.shared.canOpenURL(kakaoURL) {
                    UIApplication.shared.open(kakaoURL, options: [:])
                }
                else {
                    print("move appstore for launch kakao talk")
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
            }
        }
        
        openKaKaoOpenChat()
    }
}
    

