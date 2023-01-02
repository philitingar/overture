//
//  MeView.swift
//  Overture
//
//  Created by Timi on 29/12/22.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAddress = "you@yoursite.com"
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)

                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)//textContentType() – it tells iOS what kind of information we’re asking the user for. This should allow iOS to provide autocomplete data on behalf of the user, which makes the app nicer to use.
                    .font(.title)
                
                Image(uiImage: qrCode)
                    .interpolation(.none)//makes it not blurry
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                            Button {
                                
                                let imageSaver = ImageSaver()
                                imageSaver.writeToPhotoAlbum(image: qrCode)
                            } label: {
                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                            }
                        }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: name) { _ in updateCode() }
            .onChange(of: emailAddress) { _ in updateCode() }
        } //That will ensure the QR code is updated as soon as the view is shown, or whenever name or emailAddress get changed – perfect for our needs, and much safer than trying to change some state while SwiftUI is updating our view.
    }
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
                    
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
