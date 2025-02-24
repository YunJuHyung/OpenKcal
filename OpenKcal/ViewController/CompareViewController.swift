//
//  CompareViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

//케이크를 비교해서 어떤 케이크의 칼로리가 더 낮은지 볼 수 있는 화면입니다.
class PrintSetCakeDataCell: CompareViewController {
    func printTitleSetCakeDataCell(cake: CakeDataEntity) -> String {
        return
                """
                이름: \(cake.name)
                브랜드: \(cake.brand)
                맛: \(cake.flavor)
                칼로리: \(cake.kcal)
                당: \(cake.sugar)
                포화지방: \(cake.saturatedFat)
                단백질: \(cake.protein)
                """
        
    }
}

class CompareViewController: UIViewController,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    var ref: DatabaseReference?
    
    let storageRef = Storage.storage(url: "gs://openkcal.firebasestorage.app").reference()
    
    //로딩 인디케이터
    var loadingIndicator = UIActivityIndicatorView()
    
    
    var leftSelectedCake: CakeDataEntity? // 선택된 케이크를 왼쪽 테이블 셀에 저장할 프로퍼티
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
    
    var rightSelectedCake: CakeDataEntity? // 선택된 케이크를 오른쪽 테이블 셀에 저장할 프로퍼티
    
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
    
    @IBOutlet weak var leftLowStarImage: UIImageView!
    
    @IBOutlet weak var rightLowStarImage: UIImageView!
    
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
    
    //케이크 이름과 일치하는 사진이름을 storage에서 가져옴
    fileprivate func getImageDataFromStorage(cakeDataEntityName: String, completion: @escaping (UIImage?) -> Void){
        
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
           }
        let storageReference = storageRef.child("images/\(cakeDataEntityName).png")
        
        storageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                   }
                print(#fileID, #function, #line, "Uh-oh, an error occurred! \(error.localizedDescription)")
                
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image)
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                       }
                }
            }
        }
        
    }
    
    //MARK: -- 선택된 케이크와 일치하는 이름 = 사진을 저장할 때 name 파라미터 넘겨줘서 저장하기
    func navigateToSelectCakeViewController(uiImageView: UIImageView) {
        if let selectCakeVC = storyboard?.instantiateViewController(withIdentifier: "SelectCakeViewController") as? SelectCakeViewController {
            
            switch uiImageView {
            case cakeImageView1:
                print(#fileID, #function, #line, "left TableView Set")
                //VC를 참조하고 있는 클로저 타입을 약한 참조를 통해 메모리 누수 방지
                selectCakeVC.cakeDataCloserType = { [weak self] cakeDataEntity in
                    
                    //케이크 이미지 불러오기
                    self?.getImageDataFromStorage(cakeDataEntityName: cakeDataEntity.name) { image in
                        if let image = image {
                            self?.cakeImageView1.image = image
                        } else {
                            print(#fileID, #function, #line, "imageError")
                        }
                    }
                    //케이크 데이터 불러오기
                    self?.leftSelectedCake = cakeDataEntity
                    self?.leftTableView.reloadData()
                }
            case cakeImageView2:
                print(#fileID, #function, #line, "right TableView Set")
                selectCakeVC.cakeDataCloserType = { [weak self] cakeDataEntity in
                    // 선택된 케이크 데이터를 저장
                    self?.getImageDataFromStorage(cakeDataEntityName: cakeDataEntity.name) { cakeImage in
                        if let cakeImage = cakeImage {
                            self?.cakeImageView2.image = cakeImage
                        } else {
                            print(#fileID, #function, #line, "imageError")
                        }
                    }
                    self?.rightSelectedCake = cakeDataEntity
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
        cell.selectionStyle = .none

        
        if tableView == leftTableView, let cake = self.leftSelectedCake {
            let printingListCell = PrintSetCakeDataCell()
            print("cake 에 대한 정보: \(cake)")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = printingListCell.printTitleSetCakeDataCell(cake: cake)
            
        }
        if tableView == rightTableView, let cake = self.rightSelectedCake {
            let printingListCell = PrintSetCakeDataCell()
            print("cake 에 대한 정보: \(cake)")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = printingListCell.printTitleSetCakeDataCell(cake: cake)
            
        }
        makeLabelMessageCompareCaroies()
        return cell
    }
    
    fileprivate func removeKcalBehind4String(KcalString: String) -> Int {
        
        guard KcalString.count >= 4 else {
            print(#fileID, #function, #line, "\(KcalString.count) kcal 숫자추가안했음 ")
            return -99
        }
        let onlyIntKcal = KcalString.dropLast(4)
        let returnNum = Int(onlyIntKcal)
        return returnNum ?? -98
    }
    
    //선택된 케이크 칼로리 비교 텍스트 만드는 메서드
    func makeLabelMessageCompareCaroies() {
        //케이꾸가 없음
        let attributeText = NSMutableAttributedString()
        print("leftSelectedCake: \(String(describing: leftSelectedCake)), rightSelectedCake: \(String(describing: rightSelectedCake))")
        
        guard let leftCake = leftSelectedCake, let rightCake = rightSelectedCake else {
            showLessCaloriesLabel.text = "이미지 칸을 눌러 비교할 케이크를 선택해주세요!"
            return print("칼로리 비교쪽 안들어간다")
        }
        let leftCakeKcalInteger = removeKcalBehind4String(KcalString: leftCake.kcal)
        let rightCakeKcalInteger = removeKcalBehind4String(KcalString: rightCake.kcal)

            if leftCakeKcalInteger < rightCakeKcalInteger {
                let lowerKcal = rightCakeKcalInteger - leftCakeKcalInteger
                
                showLessCaloriesLabel.attributedText =
                attributeText.normal("\(leftCake.name)의 칼로리가 ")
                    .normalButColorAndBold("\(lowerKcal) ")
                    .normal("만큼 더 낮네요!🍰")
                
                leftLowStarImage.transform = .init(rotationAngle: .pi / -8)
                leftLowStarImage.isHidden = false
                rightLowStarImage.isHidden = true
                
            } else if rightCakeKcalInteger < leftCakeKcalInteger {
                let lowerKcal = leftCakeKcalInteger - rightCakeKcalInteger
                //showLessCaloriesLabel.text = "\(rightCake.name)의 칼로리가 \(lowerKcal)만큼 더 낮네요!🍰"
                
                showLessCaloriesLabel.attributedText =
                attributeText.normal("\(rightCake.name)의 칼로리가 ")
                    .normalButColorAndBold("\(lowerKcal) ")
                    .normal("만큼 더 낮네요!🍰")
                
                let radians: CGFloat = .pi / -8
                rightLowStarImage.transform = CGAffineTransform(rotationAngle: radians)
                rightLowStarImage.isHidden = false
                leftLowStarImage.isHidden = true
                
            } else {
                showLessCaloriesLabel.attributedText = attributeText.normal("두 케이크의 칼로리가 같네요!🍰")
                leftLowStarImage.isHidden = true
                rightLowStarImage.isHidden = true
            }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 로딩 인디케이터 설정
                loadingIndicator = UIActivityIndicatorView(style: .large)
                loadingIndicator.center = self.view.center // 화면 중앙에 배치
                loadingIndicator.hidesWhenStopped = true // 중지되면 숨기기
                self.view.addSubview(loadingIndicator)
        
        //파이어베이스 db가져오기
        ref = Database.database().reference()
        
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
        leftLowStarImage.isHidden = true
        rightLowStarImage.isHidden = true
        showLessCaloriesLabel.text = "이미지 칸을 눌러 비교할 케이크를 선택해주세요!"
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
        
        print("Left Image view tapped!")
        //네비로 연결 하기
        navigateToSelectCakeViewController(uiImageView: cakeImageView1)
    }
    
    @objc private func imageViewTapped2() {
        // 터치 이벤트 처리
        
        print("Right Image view tapped!")
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

//MARK: -- 적용되는 몽글몽글한 폰트 찾기 + attributeText unused 수정하기
extension NSMutableAttributedString {
    var fontSize:CGFloat { return 20 }
    var highlightfontSize:CGFloat { return 26 }
    var boldFont:UIFont { return UIFont(name: "SF Pro Rounded", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "HelveticaNeue", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    var normalFontBold:UIFont { return UIFont(name: "HelveticaNeue-Bold", size: highlightfontSize) ?? UIFont.systemFont(ofSize: highlightfontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
                
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
            .foregroundColor: UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    
    func normalButColorAndBold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFontBold,
            .foregroundColor : UIColor.blue,
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
}
    

extension CGFloat {
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
}


func changeAttributeString(text: String, highlightText: String) -> NSAttributedString {
    // NSMutableAttributedString 생성
    let attributeString = NSMutableAttributedString(string: text)
    
    

//    // highlightText의 Range 찾기
//    if let specifiedRange = text.range(of: highlightText) {
//        // NSRange로 변환
//        let nsRange = NSRange(specifiedRange, in: text)
//        
//        // 스타일 지정
//        attributeString.addAttributes([
//            .foregroundColor: UIColor.blue, // 텍스트 색상
//            .font: UIFont.boldSystemFont(ofSize: 18) // 폰트 스타일
//        ], range: nsRange)
//    }
    
    return attributeString
}

