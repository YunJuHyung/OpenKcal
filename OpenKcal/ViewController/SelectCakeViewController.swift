//
//  SelecteCakeViewController.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import DropDown
import UIKit
import RealmSwift
import SwiftUI

class SelectCakeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCakes.count
    }
    
    var cakeDataCloserType: ((CakeData) -> Void)?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCake = filteredCakes[indexPath.row]
        
        if let cakeDataCloserType = cakeDataCloserType{
            cakeDataCloserType(selectedCake)
        }
        // 선택된 케이크 데이터를 sender로 전달하여 세그웨이 수행
        print("sender: selectedCake")
        navigationController?.popViewController(animated: true)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CakeDataCell", for: indexPath)
        
        // 필터링된 케이크 데이터를 셀에 표시
        let cake = filteredCakes[indexPath.row]
        
//        print("-------------------------------------------")
//        print("분기점")
//        print(cake)
        cell.textLabel?.text = cake.name
        //아래 내용은 안나오긴함 detail칸 안만들었음
        cell.detailTextLabel?.text = "Flavor: \(cake.flavor), Kcal: \(cake.kcal)"
        
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
        
    
    let cakeData = CakeData()
    let imageView = UIImageView()
    
    
    //    let cakeDataModel = CakeData()
    var filteredCakes: [CakeData] = [] // 필터링된 케이크 데이터를 저장할 배열
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
        
        //  classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
        cakeListTableView.delegate = self
        cakeListTableView.dataSource = self
        
        
        
    }
    
    // tableview 가 비어있을시 이미지와 라벨로 카테고리를 선택하게 유도할려고 했음
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
        self.BrandDropDownView.layer.cornerRadius = 20
        self.brandDropDownButton.layer.masksToBounds = true
        self.flavorDropDownView.layer.cornerRadius = 20
        self.flavorDropDownView.layer.masksToBounds = true
    }
    let dropDownBrandMenu = [
        "브랜드 선택",
        "스타벅스",
        "투썸플레이스",
        "이디야",
    ]
    let dropDownFlavorMenu = [
        "케이크 맛 선택",
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
                
                
                classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
                //                print("item 확인용1 \(item)")
                //                classifyByCategoires(selectedBrand: item, selectedFlavor: nil)
                //                print("item 확인용2 \(item)")
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
                
                classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
                
                
                //                print("item 확인용1 \(item)")
                //                classifyByCategoires(selectedBrand: nil, selectedFlavor: item)
                //                print("item 확인용2 \(item)")
            }
            
        }
        //        if brandDisplayLabel.text?.isEmpty != true && flavorDisplayLabel.text?.isEmpty != true{
        //            print("원 클릭")
        //            classifyByCategoires(selectedBrand: self.brandDisplayLabel.text, selectedFlavor: self.flavorDisplayLabel.text)
        
        
        dropDownView.animationduration = 0.2 //드롭 다운 애니메이션 시간
        dropDownView.show()
        //브랜드별 케이크 데이터 필터링
        //현재 카테고리의 아이템이 무엇인지 찾기
        
    }
    
    
    //MARK: -- clickDropDownAction의 카테고리 이벤트
    
    
    func classifyByCategoires(selectedBrand: String?, selectedFlavor: String?) {
        print("들어오는지 확인")
        
        let realm = try! Realm()
        var filteredData = realm.objects(CakeData.self)
        let exceptionHandlingBrandString: String = "브랜드 선택"
        let exceptionHandlingFlavorString: String = "케이크 맛 선택"
        
        //가독성을 위해 옵셔널 바인딩을 사용
        if let selectedBrand = selectedBrand, selectedBrand != exceptionHandlingBrandString  {
            filteredData = filteredData.filter("brand == %@", selectedBrand)
        }
        
        if let selectedFlavor = selectedFlavor, selectedFlavor != exceptionHandlingFlavorString {
            filteredData = filteredData.filter("flavor == %@", selectedFlavor)
        }
        
        if let selectedBrand = selectedBrand,selectedBrand != exceptionHandlingBrandString,
           let selectedFlavor = selectedFlavor, selectedFlavor != exceptionHandlingFlavorString {
            filteredData = filteredData.filter("brand == %@ AND flavor == %@", selectedBrand, selectedFlavor)
        }
        
        if selectedBrand == exceptionHandlingBrandString &&
             selectedFlavor == exceptionHandlingFlavorString {
            
            print("테이블 빈처리")
            // 존재하지 않는 조건을 필터링하여 빈 Results를 생성 항상 false를 만들어냄 -> 값이 안나옴
            filteredData = filteredData.filter("brand == %@", String(selectedBrand ?? ""))
        }
        self.filteredCakes = Array(filteredData)
        print(" 데이터 체크용 프린트 \(filteredCakes)")
        self.cakeListTableView.reloadData()
    }
}
