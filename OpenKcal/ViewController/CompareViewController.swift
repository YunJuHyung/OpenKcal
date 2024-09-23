//
//  CompareViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import UIKit


class CompareViewController: UIViewController,UIPointerInteractionDelegate,UITableViewDataSource {
    
    var selectedCake: CakeData? // 선택된 케이크를 저장할 프로퍼티

        func navigateToSelectCakeViewController() {
            if let selectCakeVC = storyboard?.instantiateViewController(withIdentifier: "SelectCakeViewController") as? SelectCakeViewController {
                
                // 클로저 설정: 케이크가 선택되면 이 클로저가 실행됨
                selectCakeVC.cakeDataCloserType = { [weak self] selectedCake in
                    // 선택된 케이크 데이터를 저장
                    self?.selectedCake = selectedCake
                    self?.leftTableView.reloadData()
                    
                    // 필요한 로직 수행 (ex. 테이블 업데이트)
                    print("선택된 케이크: \(selectedCake.name)")
                }
                
                // 네비게이션을 통해 화면 전환
                navigationController?.pushViewController(selectCakeVC, animated: true)
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //어차피 단일 데이터만 보여줘서 1로 해도됨
        //미리 선택되는 cell이 안생기게 합니다
        return selectedCake != nil ? 1 : 0
        
        
//        return userPickCakeSelectVCValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resuableCell", for: indexPath)
        print("!11111")
        if let cake = self.selectedCake {
            print("cake 에 대한 정보: \(cake)")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = """
                이름: \(cake.name)
                맛: \(cake.flavor)
                칼로리: \(cake.kcal)
                당: \(cake.sugar)
                포화지방: \(cake.saturatedFat)
                단백질: \(cake.protein)
                """
                    }
                
        return cell
    }
    
    
    
    
    @IBOutlet weak var cakeImageView1: UIImageView!
    @IBOutlet weak var cakeImageView2: UIImageView!
    @IBOutlet weak var firstCakeImageBackgroundView: UIView!
    @IBOutlet weak var secondCakeImageBackgroundView: UIView!
    @IBOutlet weak var cakeTableView1: UITableView!
    
    @IBOutlet weak var leftTableView: UITableView!
    
 
    
//    var userPickCakeSelectVCValue: [CakeData] = [] {
//        didSet {
//            print("이것은 코드에서 나는 소리가 아니여 \(userPickCakeSelectVCValue)")
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backgroundEffectAndCornerRadius(selectUIView: firstCakeImageBackgroundView)
        backgroundEffectAndCornerRadius(selectUIView: secondCakeImageBackgroundView)
        addPlusImage(firstCakeImageBackgroundView)
        addPlusImage(secondCakeImageBackgroundView)
        setupImageView()
        leftTableView.dataSource = self
        
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

    
//    func navigateToSelectCakeViewController() {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        //viewController 인스턴스화
//        let vc = mainStoryboard.instantiateViewController(identifier: "SelecteCakeViewController") as! SelectCakeViewController
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
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
