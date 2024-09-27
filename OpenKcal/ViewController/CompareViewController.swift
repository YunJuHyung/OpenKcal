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
    
    //    func printWhichCakeIsLowerCalories(cake: CakeData) -> String{
    //
    //    }
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
    
    var leftSelectedCake: CakeData? // 선택된 케이크를 왼쪽 테이블 셀에 저장할 프로퍼티
    //didSet으로 프로퍼티 값이 변경된 직후에 호출해서 조건부 확인
    {
        didSet {
            //didset 과정에서 이미 data는 상관없음
            if leftSelectedCake == nil {
                
            }
            else {
                //결국 코드로 하는거 패배하고 gui로
                self.leftCakeSubView.isHidden = true
                
                self.cakeImageView1.image = UIImage(named: leftSelectedCake?.name ?? "")
            }
        }
    }
    
    var rightSelectedCake: CakeData? // 선택된 케이크를 오른쪽 테이블 셀에 저장할 프로퍼티
    
    {
        didSet {
            if rightSelectedCake == nil {
            }
            else {
                self.rightCakeSubView.isHidden = true
                self.cakeImageView2.image = UIImage(named: rightSelectedCake?.name ?? "")
            }
        }
    }
    var plusImageView: UIImageView?
    
    @IBOutlet weak var leftCakeSubView: UIImageView!
    @IBOutlet weak var rightCakeSubView: UIImageView!
    @IBOutlet weak var cakeImageView1: UIImageView!
    @IBOutlet weak var cakeImageView2: UIImageView!
    @IBOutlet weak var firstCakeImageBackgroundView: UIView!
    @IBOutlet weak var secondCakeImageBackgroundView: UIView!

    @IBOutlet weak var viewEmbededTV: UIView!
    
    @IBOutlet weak var leftTableView: UITableView!
    
    @IBOutlet weak var rightTableView: UITableView!
    
    @IBOutlet weak var showLessCaloriesLabel: UILabel!
    
    @IBOutlet weak var TVResetButton: UIButton!
    
    func navigateToSelectCakeViewController(uiImageView: UIImageView) {
        if let selectCakeVC = storyboard?.instantiateViewController(withIdentifier: "SelectCakeViewController") as? SelectCakeViewController {
            print(#fileID, #function, #line, "케이크 선택 진입@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22")
            
            switch uiImageView {
            case cakeImageView1:
                print(#fileID, #function, #line, "right TableView Set")
                selectCakeVC.cakeDataCloserType = { [weak self] selectedCake in
                    // 선택된 케이크 데이터를 저장
                    self?.leftSelectedCake = selectedCake
                    //선택된 케이크 이름과 일치하는 사진을 Assets에서 불러옴
                    
                    // 바꾼 addPlusImage
                    
                    self?.leftTableView.reloadData()
                }
            case cakeImageView2:
                print(#fileID, #function, #line, "left TableView Set")
                selectCakeVC.cakeDataCloserType = { [weak self] selectedCake in
                    // 선택된 케이크 데이터를 저장
                    self?.rightSelectedCake = selectedCake
                    // 필요한 로직 수행 (ex. 테이블 업데이트)
                    self?.cakeImageView2.image =
                    UIImage(named: selectedCake.name)
                    
                    self?.rightTableView.reloadData()
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
        if tableView == leftTableView {
            return leftSelectedCake != nil ? 1 : 0
        }
        else if tableView == rightTableView {
            return rightSelectedCake != nil ? 1 : 0
        } else {
            print(#fileID, #function, #line, "numberOfRowsInSection Error")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resuableCell", for: indexPath)
        print(#fileID, #function, #line, "checkFuncTableViewCellForRowAt")
        
        
        if tableView == leftTableView, let cake = self.leftSelectedCake {
            let printingListCell = printSetCakeDataCell()
            print("cake 에 대한 정보: \(cake)")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = printingListCell.printTitleSetCakeDataCell(cake: cake)
            
        }
        if tableView == rightTableView, let cake = self.rightSelectedCake {
            let printingListCell = printSetCakeDataCell()
            print("cake 에 대한 정보: \(cake)")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = printingListCell.printTitleSetCakeDataCell(cake: cake)
            
        }
        makeLabelMessageCompareCaroies()
        return cell
    }
    
    //선택된 케이크 칼로리 비교 텍스트 만드는 메서드
    func makeLabelMessageCompareCaroies() {
        //케이꾸가 없음
        print(#fileID, #function, #line, "진입한지 확인 ***********************")
        print("leftSelectedCake: \(String(describing: leftSelectedCake)), rightSelectedCake: \(String(describing: rightSelectedCake))")
        
        guard let leftCake = leftSelectedCake, let rightCake = rightSelectedCake else {
            showLessCaloriesLabel.text = "이미지 칸을 눌러 비교할 케이크를 선택해주세요!"
            return
        }
        let leftCakeKcalInteger = Int(leftCake.kcal)
        let rightCakeKcalInteger = Int(rightCake.kcal)
        if let leftCakeKcalInteger = leftCakeKcalInteger,
           let rightCakeKcalInteger = rightCakeKcalInteger {
            print(#fileID, #function, #line, "진입한지 확인 %%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            
            if leftCakeKcalInteger < rightCakeKcalInteger {
                let lowerKcal = rightCakeKcalInteger - leftCakeKcalInteger
                showLessCaloriesLabel.text = "\(leftCake.name)의 칼로리가 \(lowerKcal)만큼 더 낮네요!🍰"
            } else if rightCakeKcalInteger < leftCakeKcalInteger {
                let lowerKcal = leftCakeKcalInteger - rightCakeKcalInteger
                showLessCaloriesLabel.text = "\(rightCake.name)의 칼로리가 \(lowerKcal)만큼 더 낮네요!🍰"
            } else {
                showLessCaloriesLabel.text = "두 케이크의 칼로리가 같네요!🍰"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstCakeImageBackgroundView.makeBackgroundEffect()
        secondCakeImageBackgroundView.makeBackgroundEffect()
        viewEmbededTV.makeBackgroundEffect()
        setupGestureImageView()
        leftTableView.dataSource = self
        rightTableView.dataSource = self
    }
    
    
    
    @IBAction func makeTVClear(_ sender: UIButton) {
        cakeImageView1.image = nil
        cakeImageView2.image = nil
        leftCakeSubView.isHidden = false
        rightCakeSubView.isHidden = false
        self.leftSelectedCake = nil
        self.rightSelectedCake = nil
        self.leftTableView.reloadData()
        self.rightTableView.reloadData()
        
        
    }
    //제스쳐 인터렉션을 동시에 가능하게 하는 함수
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    private func setupGestureImageView() {
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

//배경 둥글게 + 그림자
extension UIView {
    func makeBackgroundEffect() {
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}
