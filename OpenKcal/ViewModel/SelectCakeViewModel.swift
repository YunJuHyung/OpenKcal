//
//  SelectCakeViewModel.swift
//  OpenKcal
//
//  Created by 윤주형 on 2/24/25.
//

import FirebaseDatabase
import Combine

public class SelectCakeViewModel {
    
    @Published var filteredCakes: [CakeDataEntity] = []


    
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
                    self.filteredCakes = filteredData
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
                    self.filteredCakes = filteredData
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
            
            print("filteredCakes 데이터: \(filteredData.count)")
            self.filteredCakes = filteredData
            
        }
    }
}
