//
//  ContentView.swift
//  HomeWorkCoreML
//
//  Created by Adel Khaziakhmetov on 22.10.2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    private var model               : ContentViewModel  = ContentViewModel()
    @State
    private var isShowPhotoLibrary  : Bool              = false
    @State
    private var image               : UIImage           = UIImage()
 
    var body: some View {
        VStack {
            Image(uiImage: self.image)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
 
            Button(action: {
                model.clearResult()
                isShowPhotoLibrary = true
            }) {
                HStack {
                    Text("Выбрать фото")
                        .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Button(action: {
                model.checkPhoto(with: image)
            }) {
                HStack {
                    Text("Проверить на клавиатурность")
                        .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Результат проверки:")
                    .font(.title)
                Text(model.resultString)
                    .font(.caption)
            }
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(selectedImage: self.$image, sourceType: .photoLibrary)
        }
    }
}
