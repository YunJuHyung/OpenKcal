//
//  CompareViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import UIKit

//케이크를 비교해서 어떤 케이크의 칼로리가 더 낮은지 볼 수 있는 화면입니다.
class printSetCakeDataCell: CompareViewController {
    //아마 재사용 가능하게만들어서 오른쪽에도 사용하게 하는 것을 의도함
    // extenstion이 나은지 아니면 그냥 프로토콜이 나은지?
    
    func printTitleSetCakeDataCell(cake: CakeData) -> String {
        return
                """
                이름: \(cake.name)
                맛: \(cake.flavor)
                칼로리: \(cake.kcal)
                당: \(cake.sugar)
                포화지방: \(cake.saturatedFat)
                단백질: \(cake.protein)
                """
     
    }
}
class CompareViewController: UIViewController,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    var selectedCake: CakeData? // 선택된 케이크를 저장할 프로퍼티
    
    @IBOutlet weak var cakeImageView1: UIImageView!
    @IBOutlet weak var cakeImageView2: UIImageView!
    @IBOutlet weak var firstCakeImageBackgroundView: UIView!
    @IBOutlet weak var secondCakeImageBackgroundView: UIView!
    @IBOutlet weak var cakeTableView1: UITableView!
    
    @IBOutlet weak var leftTableView: UITableView!
    
    @IBOutlet weak var rightTableView: UITableView!
    
    
    func navigateToSelectCakeViewController(uiImageView: UIImageView) {
        if let selectCakeVC = storyboard?.instantiateViewController(withIdentifier: "SelectCakeViewController") as? SelectCakeViewController {
            
            switch uiImageView {
            case cakeImageView1:
                print(#fileID, #function, #line, "right TableView Set")
                selectCakeVC.cakeDataCloserType = { [weak self] selectedCake in
                    // 선택된 케이크 데이터를 저장
                    self?.selectedCake = selectedCake
                    self?.leftTableView.reloadData()
                    // 필요한 로직 수행 (ex. 테이블 업데이트)
                    print("선택된 케이크: \(selectedCake.name)")
            }
            case cakeImageView2:
                print(#fileID, #function, #line, "left TableView Set")
                selectCakeVC.cakeDataCloserType = { [weak self] selectedCake in
                    // 선택된 케이크 데이터를 저장
                    self?.selectedCake = selectedCake
                    self?.rightTableView.reloadData()
                    // 필요한 로직 수행 (ex. 테이블 업데이트)
                    print("선택된 케이크: \(selectedCake.name)")
            }
            
            default:
                print(#fileID, #function, #line, "find line")
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
        print(#fileID, #function, #line, "checkFuncTableViewCellForRowAt")
        if let cake = self.selectedCake {
            let printingListCell = printSetCakeDataCell()
            print("cake 에 대한 정보: \(cake)")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = printingListCell.printTitleSetCakeDataCell(cake: cake)
        }
        
        return cell
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        makeCakeUIViewBackgroundEffect(selectUIView: firstCakeImageBackgroundView)
        makeCakeUIViewBackgroundEffect(selectUIView: secondCakeImageBackgroundView)
        addPlusImage(firstCakeImageBackgroundView)
        addPlusImage(secondCakeImageBackgroundView)
        setupImageView()
        leftTableView.dataSource = self
        rightTableView.dataSource = self
        
    }
    
    //코드 재사용이 이건가요? 원래도 받는 파라미터는 UIView였습니다만...
    func makeCakeUIViewBackgroundEffect(selectUIView: UIView) {
        selectUIView.layer.cornerRadius = 10
        selectUIView.layer.shadowColor = UIColor.black.cgColor
        selectUIView.layer.shadowOpacity = 0.5
        selectUIView.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectUIView.layer.shadowRadius = 4
        selectUIView.layer.masksToBounds = false
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
    
    //제스쳐 인터렉션을 동시에 가능하게 하는 함수
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    /*
     Return Value
     true to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously. The default implementation returns false—no two gestures can be recognized simultaneously.
     */
//    tapGesture1.delegate = self
//    tapGesture2.delegate = self

    private func setupImageView() {
        
        // UITapGestureRecognizer를 생성하고, 액션 메서드 설정
        // A gesture recognizer has one or more target-action pairs associated with it. If there are multiple target-action pairs, they’re discrete, and not cumulative -- 공식문서
        // UITapGestureRecognizer 인스턴스는 한 번에 하나의 뷰만 인식하도록 설계
        //MARK: (수정사항: 함수로 만들어보기)
        
        //target.self 현재의 viewController를 가르킴
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped1))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped2))

        // 이미지 뷰에 제스처 인식기 추가
        cakeImageView1.addGestureRecognizer(tapGesture1)
        cakeImageView1.isUserInteractionEnabled = true
        
        cakeImageView2.addGestureRecognizer(tapGesture2)
        cakeImageView2.isUserInteractionEnabled = true
    }
    
    @objc private func imageViewTapped1() {
        // 터치 이벤트 처리
        
        print("Image view tapped!")
        //네비로 연결 하기
        navigateToSelectCakeViewController(uiImageView: cakeImageView1)
    }

    @objc private func imageViewTapped2() {
        // 터치 이벤트 처리
        
        print("Image view tapped!")
        //네비로 연결 하기
        navigateToSelectCakeViewController(uiImageView: cakeImageView2)
    }
    
    
}
