//
//  CakeData.swift
//  OpenKcal
//
//  Created by 윤주형 on 9/5/24.
//

import Foundation
import RealmSwift



// Define an observable class to encapsulate all Core Data-related functionality.


class CakeData: Object {
    
    //케이크 성분
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var brand: String = ""
    @Persisted var flavor: String = ""
    @Persisted var kcal: String = ""
    @Persisted var saturatedFat: String = ""
    @Persisted var sugar: String = ""
    @Persisted var protein: String = ""
    
    
    
    // 반복되는 userinput()
    func getUserInput(prompt: String) -> String {
        print(prompt)
        let userInput = String(readLine() ?? "")
        return userInput
    }
    
    //
    
    func writeBySome(name: String? = nil, brand: String? = nil, flavor: String? = nil) {
        
        
    }
    // 케이크 정보 생성
    func createCakeData(nameData: String?, brandData: String?, flavorData: String?, kcalData: String?, saturatedFatData: String?, sugarData: String?, proteinData: String?) {
        let realm = try! Realm()
        print("2222222222222222")
        
        
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
        print("33333333333")
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
    
    // SelecteCakeViewController에서 드롭다운에서 선택된 item으로 cakeListTableViewList에서 list로 데이터 보여주기
    func readCakeData(name: String?, brand: String?, flavor: String?) {
        let realm = try! Realm()
        
        var filteredData = realm.objects(CakeData.self)
        
        
        /*
         // 브랜드
         let dropDownBrandMenu = [
             "스타벅스",
             "투썸 플레이스",
             "이디야",
         ]
         // 케이크 맛 종류
         let dropDownFlavorMenu = [
             "초코",
             "과일",
             "치즈",
         ]
         */
        
        // 필터링 조건 추가 (옵셔널 파라미터 처리)
        if let name = name, !name.isEmpty {
            filteredData = filteredData.filter("name CONTAINS[c] %@", name)
        }
        
        if let brand = brand, !brand.isEmpty {
            filteredData = filteredData.filter("brand CONTAINS[c] %@", brand)
        }
        
        if let flavor = flavor, !flavor.isEmpty {
            filteredData = filteredData.filter("flavor CONTAINS[c] %@", flavor)
        }
        
        let cakeNames = filteredData.map { $0.name }
        
        print(cakeNames)
    }
    //케이크 정보 변경/업데이트
    func updateCakeData(cakeName: String/*유저 한테 입력 리스트에서 선택된것*/) {
        
    }
}
    
//    //delete 미구현 상태
////    func deleteCakeData() {
////        // All modifications to a realm must happen in a write block.
////        
////        // Get all todos in the realm
//
////        let todos = realm.objects(CakeData.self)
////
////        
////        let todosInProgress = todos.where {
////            //선택된 케이크의 이름
////            $0.status == "InProgress"
////        }
////        print("A list of all todos in progress: \(todosInProgress)")
////
////        let todoToDelete = todos[0]
////        try! realm.write {
////            // Delete the Todo.
////            realm.delete(todoToDelete)
////        }
////    }
//}
