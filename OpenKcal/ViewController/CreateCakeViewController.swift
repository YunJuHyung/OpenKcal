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
import FirebaseCore
import FirebaseAuth
import FirebaseStorage


//케이크 데이터를 생성하는 화면입니다.
//realm은 사용하지 않음으로 데이터를 추가할때만 스토리보드에서 화면 연결을 통해 데이터 생성해도됨
class CreateCakeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    // Get a reference to the storage service using the default Firebase App
    
    let storageRef = Storage.storage(url:"gs://openkcal.firebasestorage.app").reference()
    
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
    
    @IBOutlet weak var insertCakeImageView: UIImageView!
    
    
    // realm Create 메소드
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
        guard let cakeImage = insertCakeImageView.image else { return }
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
        
        let realTimeDBRef = self.ref?.child("cakeData")
        
        addCakeToDBIfNotExist(realTimeDBRef, cakeName, cakeData) { success in
            if success {
                self.uploadImageToFirebase(cakeImage: cakeImage, cakeName: cakeName)
                
                let alert = UIAlertController(title: "알림", message: "케이크 \(cakeName)가 추가되었습니다.", preferredStyle: .alert)
                let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
                
                alert.addAction(close)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "알림", message: "같은 이름의 이미 케이크가 있습니다.", preferredStyle: .alert)
                let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
                alert.addAction(close)
                self.present(alert, animated: true, completion: nil)
                print(#fileID, #function, #line, "logic failed")
            }
        }
    }
    
    //Realm delete 메소드
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
        
        // 이미지 뷰에 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        insertCakeImageView.isUserInteractionEnabled = true // 상호작용 활성화
        insertCakeImageView.addGestureRecognizer(tapGesture) // 제스처 연결
        
    }
    
    @objc func imageTapped() {
        print(#fileID, #function, #line, "insert Cake image View is tapped")
        let uiImagePickerController = UIImagePickerController()
        uiImagePickerController.delegate = self
        uiImagePickerController.sourceType = .photoLibrary
        present(uiImagePickerController, animated: true, completion: nil)
    }
    
    
    // 이미지가 선택되었을 때 호출되는 delegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 선택한 이미지를 UIImageView에 설정
            insertCakeImageView.image = selectedImage
            
            dismiss(animated: true, completion: nil)
        }
        
        // 선택을 취소한 경우 호출되는 delegate 메서드
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //RealtimeDB에 같은 name의 이름이 중복하지않는지 체크
    fileprivate func addCakeToDBIfNotExist(_ realTimeDBRef: DatabaseReference?, _ cakeName: String, _ cakeData: [String : String], _ completion: @escaping (Bool) -> Void ) {
        // 데이터 검색
        realTimeDBRef?.queryOrdered(byChild: "name").queryEqual(toValue: cakeName).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                // 이미 같은 이름의 케이크가 존재
                completion(false)
            }
            else {
                //realTimeDB 데이터 추가
                realTimeDBRef?.childByAutoId().setValue(cakeData) { error, _ in
                    if let error = error {
                        print("데이터 추가 오류: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("데이터가 성공적으로 추가되었습니다.")
                        completion(true)
                    }
                }
            }
        })
    }
    
    // 파이어베이스 스토리지에 이미지 업로드
    fileprivate func uploadImageToFirebase(cakeImage: UIImage, cakeName: String) {
        
        // 저장하는 케이크이름.png 저장 ex) 초코케이크.png
        let storageReference = storageRef.child("images/\(cakeName).png")
        
        //스토리지 정보가져오기 + 같은 이름있는지 체크
        storageReference.getMetadata() { metadata, error in
            if let error = error as NSError? {
                if error.code == StorageErrorCode.objectNotFound.rawValue {
                    print(#fileID, #function, #line, "same fileName does not exist")
                } else {
                    print(#fileID, #function, #line, "ERROR : same fileName does exist!!")
                }
            }
        }
        
        // PNG 데이터로 변환
        guard let data = cakeImage.pngData() else {
            print("Failed to convert image to PNG data.")
            return
        }
        print(#fileID, #function, #line, "about png data: \(data)")
        
        // 파일 업로드
        let uploadTask = storageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                // 업로드 중 오류가 발생한 경우
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            // 업로드가 성공하면 metadata에서 파일 정보 가져오기
            if let metadata = metadata {
                let size = metadata.size
                print("Image uploaded successfully with size: \(size) bytes")
                
                // 다운로드 URL 가져오기
                storageReference.downloadURL { (url, error) in
                    if let error = error {
                        // 다운로드 URL을 가져오는 데 오류가 발생한 경우
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    // 다운로드 URL이 성공적으로 반환되면
                    if let downloadURL = url {
                        print("Image download URL: \(downloadURL.absoluteString)")
                    }
                }
            }
        }
        
        // 업로드 상태 체크
        uploadTask.observe(.progress) { snapshot in
            // 업로드 진행 상태 확인 (optional)
            print("Upload progress: \(snapshot.progress?.fractionCompleted ?? 0) %")
        }
        
        // 업로드 완료 후 상태
        uploadTask.observe(.success) { snapshot in
            print("Upload completed successfully.")
        }
        
        // 업로드 실패 상태
        uploadTask.observe(.failure) { snapshot in
            print("Upload failed: \(snapshot.error?.localizedDescription ?? "Unknown error")")
        }
    }
    
}
