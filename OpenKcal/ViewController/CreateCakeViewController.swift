//
//  File.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/14/24.
//

import Foundation
import UIKit
import RealmSwift
import SwiftUI
import FirebaseDatabase

//케이크 데이터를 생성하는 화면입니다.
class CreateCakeViewController: UIViewController {
    var ref: DatabaseReference?
    
    let cakeData = CakeData()
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var cakeNameTextField: UITextField!
    
    @IBOutlet weak var brandTextField: UITextField!
    
    @IBOutlet weak var flavorTextField: UITextField!
    
    @IBOutlet weak var kcalTextField: UITextField!
    
    @IBOutlet weak var saturatedFatTextField: UITextField!
    
    @IBOutlet weak var sugarTextField: UITextField!
    
    @IBOutlet weak var proteinTextField: UITextField!

    

    
    // Realm 케이크 정보 생성
    func createCakeData(nameData: String?, brandData: String?, flavorData: String?, kcalData: String?, saturatedFatData: String?, sugarData: String?, proteinData: String?) {
        let realm = try! Realm()
        
        // CakeData 객체 생성 및 데이터 할당
        let cake = CakeData()
        
        cake.name = nameData ?? ""
        cake.brand = brandData ?? ""
        cake.flavor = flavorData ?? ""
        cake.kcal = kcalData ?? ""
        cake.saturatedFat = saturatedFatData ?? ""
        cake.sugar = sugarData ?? ""
        cake.protein = proteinData ?? ""
        
        // Realm에 저장
        do {
            try realm.write {
                realm.add(cake)
                print("케이크 정보가 저장되었습니다.")
                print("저장된 케이크 정보: \(cake.name)")
            }
        } catch {
            print("케이크 정보 저장 실패: \(error)")
        }
    }
    
    @IBAction func insertCakeDataAction(_ sender: UIButton) {
        
        //MARK: (수정 애매) 만약 코드 줄 수 줄일려면 textfield.text를 받고 배열로 빼준다 흠...
        guard let cakeName = cakeNameTextField.text else { return }
        guard let brand = brandTextField.text else { return }
        guard let flavor = flavorTextField.text else { return }
        guard let kcal = kcalTextField.text else { return  }
        guard let saturatedFat = saturatedFatTextField.text else { return  }
        guard let sugar = sugarTextField.text else { return  }
        guard let protein = proteinTextField.text else { return  }
        
        let cakeData = [
            "name": cakeName,
            "brand": brand,
            "flavor": flavor,
            "kcal": kcal,
            "saturatedFat": saturatedFat,
            "sugar": sugar,
            "protein": protein
        ]
        self.ref?.child("cakeData").childByAutoId().setValue(cakeData) { error, _ in
            if let error = error {
                print("데이터 추가 오류: \(error.localizedDescription)")
            } else {
                print("데이터가 성공적으로 추가되었습니다.")
            }
        }
        
        print(#fileID, #function, #line, "func createCakeData 실행확인용")
//        createCakeData(nameData: cakeName, brandData: brand, flavorData: flavor, kcalData: kcal, saturatedFatData: saturatedFat, sugarData: sugar, proteinData: protein)
        
        let alert = UIAlertController(title: "알림", message: "케이크 \(cakeName)가 추가되었습니다.", preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
        
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteCakeDBAll(_ sender: UIButton) {
        //local DB 삭제
        let realm = try! Realm()
        try! realm.write {
            // Delete all objects from the realm.
            realm.deleteAll()
            
            let alert = UIAlertController(title: "알림", message: "전체 케이크 데이터가 삭제되었습니다.", preferredStyle: .alert)
            let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
            
            alert.addAction(close)
            present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        backgroundView.layer.borderColor = UIColor.blue.cgColor
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.borderWidth = 2.0
        
    }
    
    
    
    
}
