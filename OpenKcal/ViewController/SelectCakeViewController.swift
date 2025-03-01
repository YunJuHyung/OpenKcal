//
//  SelecteCakeViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import DropDown
import RealmSwift
import SwiftUI
import FirebaseDatabase
import FirebaseFirestore
import Combine

//케이크의 카테고리를 필터링해서 선택하는 화면입니다.
class SelectCakeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
//    var filteredCakes: [CakeDataEntity] = [] // 필터링된 케이크 데이터를 저장할 배열
    
    let imageView = UIImageView()
    private let viewModel = SelectCakeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    // let refHandle = self.ref?.child("cakeData")
     
    @IBOutlet weak var cakeListTableView: UITableView!
    
    @IBOutlet weak var brandDropDownView: UIView!
    @IBOutlet weak var flavorDropDownView: UIView!
    @IBOutlet weak var brandDisplayLabel: UILabel!
    @IBOutlet weak var flavorDisplayLabel: UILabel!
    
    @IBOutlet weak var brandDropDownButton: UIButton!
    @IBOutlet weak var flavorDropDownButton: UIButton!
    var cakeDataCloserType: ((CakeDataEntity) -> Void)?
    
    //closer사용할때 선택한 아이템을 넘겨줄때만 struct사용하고 아닐때는
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(#fileID, #function, #line, "TableViewnumberOfRowsInSection\(self.filteredCakes)")
        //        print(#fileID, #function, #line, "TableViewnumberOfRowsInSection NUMBER \(self.filteredCakes.count)")
        return viewModel.filteredCakes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCake = viewModel.filteredCakes[indexPath.row]
    
        if let cakeDataCloserType = cakeDataCloserType{
            cakeDataCloserType(selectedCake)
        }
        // 선택된 케이크 데이터를 sender로 전달하여 세그웨이 수행
        navigationController?.popViewController(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CakeDataCell", for: indexPath)
        
        // 필터링된 케이크 데이터를 셀에 표시
        let cake = viewModel.filteredCakes[indexPath.row]
                print(#fileID, #function, #line, "테이블뷰 케이크 cake 확인합니다 \(cake)")
        //        print(#fileID, #function, #line, "테이블뷰 케이크 filteredCakes 확인합니다 \(filteredCakes)")
        
        cell.textLabel?.text = cake.name
        
        return cell
    }
    
    //prepare에서 내가 보내줄건 filteredCakes: [CakeData] or cake: CakeData
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        print("prepare")
    //        super.prepare(for: segue, sender: sender)
    //        print(segue.destination)
    //        if segue.identifier == "CompareViewController" {
    //            if let compareVC = segue.destination as? CompareViewController {
    //                if let selectedCake = sender as? CakeData {
    //                    compareVC.userPickCakeSelectVCValue = [selectedCake]
    //                }
    //            }
    //        }
    //    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cakeListTableView.delegate = self
        cakeListTableView.dataSource = self
        viewModel.classifyByCategoiresUsingFireBase(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
        setupGestureImageView()
        bindViewModel()
    }
    
    private func bindViewModel() {
        print(#fileID, #function, #line, "check bindViewModel")
            viewModel.$filteredCakes
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.cakeListTableView.reloadData()
                }
                .store(in: &cancellables)
        }
    
    // tableview 가 비어있을시 이미지와 라벨로 카테고리를 선택하게 유도할려고 했음
    // tableview에는 이미지 덮어씌우기 불가능
    func defaultImageSetting() {
        imageView.image = UIImage(named: "smileAnimeImage") // 이미지 이름
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor // 테두리 색상
        imageView.layer.masksToBounds = true // 테두리와 모서리 잘림
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // 뷰에 추가
        view.addSubview(imageView)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    //MARK: -- 아직 적용 안됨 : 카테고리 view corner radius
    func categoriesCornerSoftly() {
        self.brandDropDownView.layer.cornerRadius = 20
        self.brandDropDownButton.layer.masksToBounds = true
        self.flavorDropDownView.layer.cornerRadius = 20
        self.flavorDropDownView.layer.masksToBounds = true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupGestureImageView() {
        
        // UITapGestureRecognizer를 생성하고, 액션 메서드 설정
        // A gesture recognizer has one or more target-action pairs associated with it. If there are multiple target-action pairs, they’re discrete, and not cumulative -- 공식문서
        // UITapGestureRecognizer 인스턴스는 한 번에 하나의 뷰만 인식하도록 설계
        //MARK: (수정사항: 함수로 만들어보기)
        
        //target.self 현재의 viewController를 가르킴
        let tapGestureBrandDropDownView = UITapGestureRecognizer(target: self, action: #selector(clickDropDownAction))
        let tapGestureFlavorDropDownView = UITapGestureRecognizer(target: self, action: #selector(clickDropDownAction))
        
        // 이미지 뷰에 제스처 인식기 추가
        // 제스쳐 인식기가 인식되면 나머지 터치를 뷰에서 취소함 고로 false 처리해줌
        tapGestureBrandDropDownView.cancelsTouchesInView = false
        brandDropDownView.addGestureRecognizer(tapGestureBrandDropDownView)
        brandDropDownView.isUserInteractionEnabled = true
        
        tapGestureFlavorDropDownView.cancelsTouchesInView = false
        flavorDropDownView.addGestureRecognizer(tapGestureFlavorDropDownView)
        flavorDropDownView.isUserInteractionEnabled = true
    }
    
    @objc private func clickDropDownAction(_ sender: UITapGestureRecognizer? = nil) {
        
        let dropDownView = DropDown() // DropDown 인스턴스 생성
        
        dropDownView.cellHeight = 40 // 각 칸의 높이
        dropDownView.backgroundColor = .systemOrange
        // MARK: - (수정필요) 칸별 구분선의 x좌표가 bottomOffset을 따라가지 못함
        dropDownView.separatorColor = .black // 각 칸별 구분선 색상
        dropDownView.selectionBackgroundColor = .systemRed
        dropDownView.dismissMode = .automatic
        
        dropDownView.textFont = .systemFont(ofSize: 12)// 칸별 폰트
        dropDownView.direction = .bottom // 드랍 다운 방향
        dropDownView.layer.cornerRadius = 20 // 드롭다운의 모서리를 둥글게 설정
        dropDownView.layer.masksToBounds = true
        
        if let tappedView = sender?.view { //tap제스쳐가 가지고 있는 view에 대해서 옵셔널 처리
            filterDropDownButton(tappedView, dropDownView)
        }
        
        dropDownView.animationduration = 0.2 //드롭 다운 애니메이션 시간
        dropDownView.show()
        
        
    }
    
    //MARK: clickDropDownAction의 filtering이벤트
    fileprivate func filterDropDownButton(_ sender: UIView, _ dropDownView: DropDown) {
        
        switch sender {
        case brandDropDownView:
            dropDownView.dataSource = CakeFilterOptions.dropDownBrandMenu // 어떤 데이터를 보여줄건지
            // 어느 뷰 위치에 넣을것인지
            
            dropDownView.anchorView = self.brandDropDownView
            // 어느 뷰 위치에 넣을것인지
            dropDownView.bottomOffset = CGPoint(x: 0, y: (dropDownView.anchorView?.plainView.bounds.height)!)// 지정뷰의 어느위치에 넣을것인지                            dropDownView.bounds.height   (dropDownView.anchorView?.plainView.bounds.height)!
            // 이걸 설정안하면 뷰를 가리면서 메뉴가 나오게됩니다!
            dropDownView.selectionAction = { [unowned self] (index: Int, item: String) in
                // 선택한 아이템에 따라 필터링 실행
                self.brandDisplayLabel.text = item
                
                
                //fireBase사용
                viewModel.classifyByCategoiresUsingFireBase(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
                
                
                
                //localDB용
                //classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
            }
            
        case flavorDropDownView :
            dropDownView.dataSource = CakeFilterOptions.dropDownFlavorMenu // 어떤 데이터를 보여줄건지
            
            dropDownView.anchorView = self.flavorDropDownView
            // 어느 뷰 위치에 넣을것인지
            dropDownView.bottomOffset = CGPoint(x: 0, y:(dropDownView.anchorView?.plainView.bounds.height)!)// 지정뷰의 어느위치에 넣을것인지
            // 이걸 설정안하면 뷰를 가리면서 메뉴가 나오게됩니다!
            dropDownView.selectionAction = { [unowned self] (index: Int, item: String) in
                // 선택한 아이템에 따라 필터링 실행
                self.flavorDisplayLabel.text = item
                
                //                classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
                //fireBase사용
                viewModel.classifyByCategoiresUsingFireBase(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
                
           }
            
        default:
            print("default messages")
        }
        self.cakeListTableView.reloadData()

    }
    
    //MARK: -- Realm after filterDropDownButton set filtering tableCellData 메소드
    func classifyByCategoires(selectedBrand: String?, selectedFlavor: String?) {
        //
        //        let realm = try! Realm()
        //        var filteredData = realm.objects(CakeData.self)
        //        let exceptionHandlingBrandString: String = "브랜드 선택"
        //        let exceptionHandlingFlavorString: String = "케이크 맛 선택"
        //
        //        //가독성을 위해 옵셔널 바인딩을 사용
        //        if let selectedBrand = selectedBrand, selectedBrand != exceptionHandlingBrandString  {
        //            filteredData = filteredData.filter("brand == %@", selectedBrand)
        //        }
        //
        //        if let selectedFlavor = selectedFlavor, selectedFlavor != exceptionHandlingFlavorString {
        //            filteredData = filteredData.filter("flavor == %@", selectedFlavor)
        //        }
        //
        //        if let selectedBrand = selectedBrand,selectedBrand != exceptionHandlingBrandString,
        //           let selectedFlavor = selectedFlavor, selectedFlavor != exceptionHandlingFlavorString {
        //            filteredData = filteredData.filter("brand == %@ AND flavor == %@", selectedBrand, selectedFlavor)
        //        }
        //
        //        if selectedBrand == exceptionHandlingBrandString &&
        //            selectedFlavor == exceptionHandlingFlavorString {
        //
        //            print("테이블 빈처리")
        //            // 존재하지 않는 조건을 필터링하여 빈 Results를 생성 항상 false를 만들어냄 -> 값이 안나옴
        //            filteredData = filteredData.filter("brand == %@", String(selectedBrand ?? ""))
        //        }
        //        self.filteredCakes = Array(filteredData)
        //        print(#fileID, #function, #line, "데이터 체크용 프린트 \(filteredCakes)")
        //        self.cakeListTableView.reloadData()
    }
    
    
    //MARK: -- Realtime DB에서 중복쿼리문이 안되서 다양한 방법을 구상해봤는데 결국 심플이즈 베스트더라~
    // 서버에서 데이터를 받는게 느려서 Firebase dispatchGroup 사용 항상 데이터가 안들어오면 고려해야됨
    func classifyByCategoiresUsingFireBase(selectedBrand: String?, selectedFlavor: String?) {
        
        var filteredData: [CakeDataEntity] = []
        let ref = Database.database().reference().child("cakeData")
        let dispatchGroup = DispatchGroup()
        
        let exceptionHandlingBrandString: String = "브랜드 선택"
        let exceptionHandlingFlavorString: String = "케이크 맛 선택"
        
        // 아무것도 선택하지 않은 상태
        if selectedBrand == exceptionHandlingBrandString && selectedFlavor == exceptionHandlingFlavorString {
            dispatchGroup.enter()
            
            // 기본 쿼리로 모든 데이터를 가져옴
            ref.observe(.value) { snapshot in
                for child in snapshot.children {
                    
                    let childSnapShot = child as? DataSnapshot
                    let value = childSnapShot?.value as? NSDictionary
                    
                    let name = value?["name"] as? String ?? ""
                    let brand = value?["brand"] as? String ?? ""
                    let flavor = value?["flavor"] as? String ?? ""
                    let kcal = value?["kcal"] as? String ?? ""
                    let saturatedFat = value?["saturatedFat"] as? String ?? ""
                    let sugar = value?["sugar"] as? String ?? ""
                    let protein = value?["protein"] as? String ?? ""
                    
                    let brandData = CakeDataEntity(name: name, brand: brand, flavor: flavor, kcal: kcal, saturatedFat: saturatedFat, sugar: sugar, protein: protein)
                    
                    filteredData.append(brandData)
                    
                }
                dispatchGroup.leave() // 비동기 작업 후 leave 호출
            }
            
        }
        
        // 브랜드만 필터링
        if selectedBrand != exceptionHandlingBrandString && selectedFlavor == exceptionHandlingFlavorString {
            dispatchGroup.enter()
            
            let brandFilteredSnapshot = ref.queryOrdered(byChild: "brand").queryEqual(toValue: selectedBrand)
            
            brandFilteredSnapshot.observe(.value) { snapshot in
                for child in snapshot.children {
                    
                    let childSnapShot = child as? DataSnapshot
                    let value = childSnapShot?.value as? NSDictionary
                    
                    let name = value?["name"] as? String ?? ""
                    let brand = value?["brand"] as? String ?? ""
                    let flavor = value?["flavor"] as? String ?? ""
                    let kcal = value?["kcal"] as? String ?? ""
                    let saturatedFat = value?["saturatedFat"] as? String ?? ""
                    let sugar = value?["sugar"] as? String ?? ""
                    let protein = value?["protein"] as? String ?? ""
                    
                    let brandData = CakeDataEntity(name: name, brand: brand, flavor: flavor, kcal: kcal, saturatedFat: saturatedFat, sugar: sugar, protein: protein)
                    
                    filteredData.append(brandData)
                    
                }
                dispatchGroup.leave()
            }
            
        }
        
        // 맛만 필터링
        if selectedFlavor != exceptionHandlingFlavorString && selectedBrand == exceptionHandlingBrandString {
            dispatchGroup.enter()
            
            let flavorFilteredSnapshot = ref.queryOrdered(byChild: "flavor").queryEqual(toValue: selectedFlavor)
            
            flavorFilteredSnapshot.observe(.value) { snapshot in
                for child in snapshot.children {
                    
                    
                    let childSnapShot = child as? DataSnapshot
                    let value = childSnapShot?.value as? NSDictionary
                    
                    let name = value?["name"] as? String ?? ""
                    let brand = value?["brand"] as? String ?? ""
                    let flavor = value?["flavor"] as? String ?? ""
                    let kcal = value?["kcal"] as? String ?? ""
                    let saturatedFat = value?["saturatedFat"] as? String ?? ""
                    let sugar = value?["sugar"] as? String ?? ""
                    let protein = value?["protein"] as? String ?? ""
                    
                    let brandData = CakeDataEntity(name: name, brand: brand, flavor: flavor, kcal: kcal, saturatedFat: saturatedFat, sugar: sugar, protein: protein)
                    
                    filteredData.append(brandData)
                    
                }
                dispatchGroup.leave() // 비동기 작업 후 leave 호출
            }
            
        }
        
        // 브랜드와 맛 둘 다 필터링
        if selectedBrand != exceptionHandlingBrandString && selectedFlavor != exceptionHandlingFlavorString {
            dispatchGroup.enter()
            
            let brandFilteredSnapshot = ref.queryOrdered(byChild: "brand").queryEqual(toValue: selectedBrand)
            
            brandFilteredSnapshot.observe(.value) { snapshot in
                for child in snapshot.children {
                    
                    let childSnapShot = child as? DataSnapshot
                    let value = childSnapShot?.value as? NSDictionary
                    
                    let name = value?["name"] as? String ?? ""
                    let brand = value?["brand"] as? String ?? ""
                    let flavor = value?["flavor"] as? String ?? ""
                    let kcal = value?["kcal"] as? String ?? ""
                    let saturatedFat = value?["saturatedFat"] as? String ?? ""
                    let sugar = value?["sugar"] as? String ?? ""
                    let protein = value?["protein"] as? String ?? ""
                    
                    let brandData = CakeDataEntity(name: name, brand: brand, flavor: flavor, kcal: kcal, saturatedFat: saturatedFat, sugar: sugar, protein: protein)
                    
                    // realtime DB는 중복쿼리가 안되는 관계로 한참 고민하다가 낸게 그냥 if문으로 거르기
                    if brandData.flavor == selectedFlavor {
                        filteredData.append(brandData)
                        print(brandData)
                    }
                }
                dispatchGroup.leave() // 비동기 작업 후 leave 호출
            }
        }
        
        // 비동기 처리 끝난 후
        dispatchGroup.notify(queue: .main) {
            print("filteredCakes 데이터: \(filteredData)")
            self.viewModel.filteredCakes = filteredData
            self.cakeListTableView.reloadData()
        }
    }
    


    
}

