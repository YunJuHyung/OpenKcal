//
//  CompareViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import UIKit


class CompareViewController: UIViewController,UIPointerInteractionDelegate {
    
    @IBOutlet weak var cakeImageView1: UIImageView!
    @IBOutlet weak var cakeImageView2: UIImageView!
    @IBOutlet weak var firstCakeImageBackgroundView: UIView!
    @IBOutlet weak var secondCakeImageBackgroundView: UIView!
    @IBOutlet weak var cakeTableView1: UITableView!
 //   let modelFile = CakeData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backgroundEffectAndCornerRadius(selectUIView: firstCakeImageBackgroundView)
        backgroundEffectAndCornerRadius(selectUIView: secondCakeImageBackgroundView)
        addPlusImage(firstCakeImageBackgroundView)
        addPlusImage(secondCakeImageBackgroundView)
        setupImageView()
        
        }
    
    func backgroundEffectAndCornerRadius(selectUIView cakeUiView: UIView) {
        cakeUiView.layer.cornerRadius = 10
        cakeUiView.layer.shadowColor = UIColor.black.cgColor
        cakeUiView.layer.shadowOpacity = 0.5
        cakeUiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cakeUiView.layer.shadowRadius = 4
        cakeUiView.layer.masksToBounds = false
    }
    
   
    
    func addPlusImage(_ uiView: UIView?) {
        guard let uiView = uiView else { return }
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus")
        imageView.tintColor = UIColor.black
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
        
        uiView.addSubview(imageView)
        
        // 오토레이아웃으로 UIImageView를 중앙에 배치
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 50), // 이미지 크기 조정
                imageView.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    //cake image view 클릭시 일어나는  UITapGesture
    private func setupImageView() {
           
           // UITapGestureRecognizer를 생성하고, 액션 메서드 설정
           let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped1))
           let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped2))
           
           // 이미지 뷰에 제스처 인식기 추가
        
        cakeImageView1.addGestureRecognizer(tapGesture1)
        cakeImageView1.isUserInteractionEnabled = true
        
        cakeImageView2.addGestureRecognizer(tapGesture2)
        cakeImageView2.isUserInteractionEnabled = true
        
       }

    
    func navigateToSelectCakeViewController() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //viewController 인스턴스화
        let vc = mainStoryboard.instantiateViewController(identifier: "SelecteCakeViewController") as! SelecteCakeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func imageViewTapped1() {
        // 터치 이벤트 처리
        print("Image view tapped!")
        //네비로 연결 하기
        navigateToSelectCakeViewController()
    }
    @objc private func imageViewTapped2() {
        // 터치 이벤트 처리
        print("Image view tapped!")
        //네비로 연결 하기
        navigateToSelectCakeViewController()
    }
    
    
}
