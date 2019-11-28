//
//  ContentView.swift
//  Instafilter
//
//  Created by Liem Vo on 11/24/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
	
	@State private var image: Image?
	@State private var filterIntensity = 0.5
	
	@State private var showingImagePicker = false
	@State private var showingFilterSheet = false
	
	@State private var inputImage: UIImage?
	@State private var processedImage: UIImage?
	
	@State var currentFilter: CIFilter = CIFilter.sepiaTone()
	let context = CIContext()
	
	
	var body: some View {
		
		let intensity = Binding<Double> (
			get: {
				self.filterIntensity
			},
			set: {
				self.filterIntensity = $0
				self.applyProcessing()
			}
		)
		return NavigationView {
			VStack {
				ZStack {
					Rectangle()
						.fill(Color.secondary)
					if image != nil {
						image?.resizable()
						.scaledToFit()
					} else {
						Text("Tap to select a  picture")
							.foregroundColor(.white)
							.font(.headline)
					}
				}
				.onTapGesture {
					self.showingImagePicker = true
				}
				
				HStack {
					Text("Intensity")
					Slider(value: intensity)
				}
				
				HStack {
					Button("Change Filter") {
						self.showingFilterSheet = true
					}
					Spacer()
					Button("Save") {
						guard let processedImage = self.processedImage else { return }
						let imageSaver = ImageSaver()
						imageSaver.successHandler = {
							print("Success!!!")
						}
						imageSaver.errorHandler = {
							print("\($0.localizedDescription)")
						}
						imageSaver.writeToPhotoAlbum(image: processedImage)
					}
				}
			}
			.padding([.horizontal, .bottom])
			.navigationBarTitle("Intafilter")
			.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
				ImagePicker(image: self.$inputImage)
			}
			.actionSheet(isPresented: $showingFilterSheet){
				ActionSheet(title: Text("Select a filter"), buttons: [
					.default(Text("Crystallize")){
						self.setFilter(CIFilter.crystallize())
					},
					.default(Text("Edges")) {
						self.setFilter(CIFilter.edges())
					},
					.default(Text("Gaussian Blur")) {
						self.setFilter(CIFilter.gaussianBlur())
					},
					.default(Text("Pixellate")) {
						self.setFilter(CIFilter.pixellate())
					},
					.default(Text("Sepia Tone")) {
						self.setFilter(CIFilter.sepiaTone())
					},
					.default(Text("Unsharp Mask")) {
						self.setFilter(CIFilter.unsharpMask())
					},
					.default(Text("Vignette")) {
						self.setFilter(CIFilter.vignette())
					},
					.default(Text("Cancel"))
				])
			}
		}
	}
	
	private func loadImage() {
		guard let inputImage  = inputImage else { return }
		let beginImage = CIImage(image: inputImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		applyProcessing()
	}
	
	private func  applyProcessing() {
		let inputKeys = currentFilter.inputKeys
		
		
		if inputKeys.contains(kCIInputIntensityKey) {
			currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
		}
		
		if inputKeys.contains(kCIInputRadiusKey) {
			currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
		}
		
		if inputKeys.contains(kCIInputScaleKey) {
			currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
		}
		
		guard let outputImage = currentFilter.outputImage else { return }
		
		if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
			let uiImage  = UIImage(cgImage: cgimg)
			image  = Image(uiImage: uiImage)
			processedImage = uiImage
		}
	}
	
	private func setFilter(_ filter: CIFilter) {
		currentFilter = filter
		loadImage()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
