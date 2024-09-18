//
//  SelecteCakeViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import DropDown
import UIKit
import RealmSwift


class SelecteCakeViewController: UIViewController,UITableViewDataSource {
    
    let cakeData = CakeData()
    
    
    
    //    let cakeDataModel = CakeData()
    var filteredCakes: [CakeData] = [] // 필터링된 케이크 데이터를 저장할 배열
    var filteredCakes1: [CakeData] = [] // 필터링된 케이크 데이터를 저장할 배열
    @IBOutlet weak var cakeListTableView: UITableView!
    
    @IBOutlet weak var BrandDropDownView: UIView!
    @IBOutlet weak var flavorDropDownView: UIView!
    @IBOutlet weak var brandDisplayLabel: UILabel!
    @IBOutlet weak var flavorDisplayLabel: UILabel!
    
    @IBOutlet weak var brandDropDownButton: UIButton!
    @IBOutlet weak var flavorDropDownButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //       cakeListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CakeDataCell")
        
        //        cakeListTableView.dataSource = self
        //        cakeListTableView.delegate = self
        //tableview 를 사용하기 위해 내가 가져온 data는 나 자신을 표시
//        if brandDisplayLabel.text?.isEmpty != true && flavorDisplayLabel.text?.isEmpty != true{
//            classifyByCategoires(selectedBrand: brandDisplayLabel.text, selectedFlavor: flavorDisplayLabel.text)
//        }
        classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
        cakeListTableView.dataSource = self
    }
    
    
    //MARK: -- 아직 적용 안됨 : 카테고리 view corner radius
    func categoriesCornerSoftly() {
        self.BrandDropDownView.layer.cornerRadius = 20
        self.brandDropDownButton.layer.masksToBounds = true
        self.flavorDropDownView.layer.cornerRadius = 20
        self.flavorDropDownView.layer.masksToBounds = true
    }
    let dropDownBrandMenu = [
        "스타벅스",
        "투썸플레이스",
        "이디야",
    ]
    let dropDownFlavorMenu = [
        "초코",
        "과일",
        "치즈",
    ]
    //추후에 any로 다시 설정하도 범위를 view자체로 확대할 예정
    @IBAction func clickDropDownAction(_ sender: UIButton) {
        
        
        let dropDownView = DropDown() // DropDown 생성
        
        
        dropDownView.cellHeight = 40 // 각 칸의 높이
        dropDownView.backgroundColor = .systemOrange
        // MARK: - 칸별 구분선의 x좌표가 bottomOffset을 따라가지 못함
        dropDownView.separatorColor = .black // 각 칸별 구분선 색상
        dropDownView.textFont = .systemFont(ofSize: 12)// 칸별 폰트
        dropDownView.direction = .bottom // 드랍 다운 방향
        dropDownView.layer.cornerRadius = 20 // 드롭다운의 모서리를 둥글게 설정
        dropDownView.layer.masksToBounds = true // cornerRadius가 적용되도록 설정
        
        
        if sender == brandDropDownButton {
            dropDownView.dataSource = self.dropDownBrandMenu // 어떤 데이터를 보여줄건지
            // 어느 뷰 위치에 넣을것인지
            
            dropDownView.anchorView = self.brandDisplayLabel
            // 어느 뷰 위치에 넣을것인지
            dropDownView.bottomOffset = CGPoint(x: -10, y:(dropDownView.anchorView?.plainView.bounds.height)!)// 지정뷰의 어느위치에 넣을것인지
            // 이걸 설정안하면 뷰를 가리면서 메뉴가 나오게됩니다!
            dropDownView.selectionAction = { [unowned self] (index: Int, item: String) in
                // 선택한 아이템에 따라 필터링 실행
                self.brandDisplayLabel.text = item
                print("item 확인용1 \(item)")
                //classifyByCategoires(selectedBrand: item, selectedFlavor: nil)
                print("item 확인용2 \(item)")
                
            }
        }
        if sender == flavorDropDownButton {
            dropDownView.dataSource = self.dropDownFlavorMenu // 어떤 데이터를 보여줄건지
            
            dropDownView.anchorView = self.flavorDisplayLabel
            // 어느 뷰 위치에 넣을것인지
            dropDownView.bottomOffset = CGPoint(x: 0, y:(dropDownView.anchorView?.plainView.bounds.height)!)// 지정뷰의 어느위치에 넣을것인지
            // 이걸 설정안하면 뷰를 가리면서 메뉴가 나오게됩니다!
            dropDownView.selectionAction = { [unowned self] (index: Int, item: String) in
                // 선택한 아이템에 따라 필터링 실행
                self.flavorDisplayLabel.text = item
                print("item 확인용1 \(item)")
                //classifyByCategoires(selectedBrand: nil, selectedFlavor: item)
                print("item 확인용2 \(item)")
                
            }
        }
        
        dropDownView.animationduration = 0.2 //드롭 다운 애니메이션 시간
        dropDownView.show()
        //브랜드별 케이크 데이터 필터링
        //현재 카테고리의 아이템이 무엇인지 찾기
        
    }
    
    
    
    func classifyByBrand(selectedBrand: String) {
        let realm = try! Realm()
        
        let filteredData = realm.objects(CakeData.self).filter("brand == %@", selectedBrand)
        
        // 필터링된 데이터를 배열에 저장
        self.filteredCakes = Array(filteredData)
        
        print(filteredData)
        print("분기점 ----------")
        print(filteredCakes1)
        
        
        
        // TableView 리로드
        self.cakeListTableView.reloadData()
    }
    
    func classifyByFlavor(selectedFlavor: String) {
        let realm = try! Realm()
        
        let filteredData = realm.objects(CakeData.self).filter("flavor == %@", selectedFlavor)
        
        // 필터링된 데이터를 배열에 저장
        self.filteredCakes = Array(filteredData)
        
        print(filteredData)
        print("분기점 ----------")
        print(filteredCakes1)
        
        
        // TableView 리로드
        self.cakeListTableView.reloadData()
    }
    
    func classifyByCategoires(selectedBrand: String?, selectedFlavor: String?) {
        print("들어오는지 확인")
        print("들어오는지 확인")
        
        let realm = try! Realm()
        var filteredData = realm.objects(CakeData.self)
        
        //가독성을 위해 옵셔널 바인딩을 사용
        if let selectedBrand = selectedBrand, !selectedBrand.isEmpty {
            filteredData = filteredData.filter("brand == %@", selectedBrand)
        }
        
        if let selectedFlavor = selectedFlavor, !selectedFlavor.isEmpty {
            filteredData = filteredData.filter("flavor == %@", selectedFlavor)
        }
        
        if let selectedBrand = selectedBrand,!selectedBrand.isEmpty,
            let selectedFlavor = selectedFlavor, !selectedBrand.isEmpty{
            filteredData = filteredData.filter("brand == %@ AND flavor == %@", selectedBrand, selectedFlavor)
            
        }

        
        self.filteredCakes1 = Array(filteredData)
        
        
        // set배열로 중복 데이터 저장 가능
//        var seenNames = Set<String>()
//        //공통된 이름 추출
//        let commonName = filteredData.map {$0.name}
//        print("filteredData.map {$0.name} = \(filteredData.map {$0.name})")
//        print("commonName = \(commonName)")
//        
//        var checkCommonName: [String] = []
//        for name in commonName {
//            checkCommonName.append(name)
//            print("커먼 닉네임의 네임 = \(name)")
//        }
//        for index in filteredData {
//            if seenNames.contains(checkCommonName) {
//                filteredCakes1.append(index)
//                //확인용
//                print("filteredCakes1 확인용 = \(filteredCakes1.append(index))")
//            }
//            else {
//                seenNames.insert(index.name)
//                //확인용
//                print("seenNames 확인용 = \(index.name)")
//            }
//        }
        
        // TableView 리로드
        self.cakeListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCakes1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CakeDataCell", for: indexPath)
        
        // 필터링된 케이크 데이터를 셀에 표시
        let cake = filteredCakes1[indexPath.row]
        cell.textLabel?.text = cake.name
        cell.detailTextLabel?.text = "Flavor: \(cake.flavor), Kcal: \(cake.kcal)"
        
        return cell
    }
}
