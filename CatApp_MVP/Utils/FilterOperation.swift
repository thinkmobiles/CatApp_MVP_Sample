//
//  FilterOperation.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import UIKit

final class FilterOperation: Operation {
    
    let filter: CIFilter
    let inputImage: UIImage
    
    private(set) var outputImage: UIImage?
    private(set) var error: Error?

    init(filter: CIFilter, image: UIImage) {
        self.filter = filter
        self.inputImage = image
    }

    override func main() {
        if isCancelled { return }
        let inputCIImage = CIImage(cgImage: self.inputImage.cgImage!)
        if isCancelled { return }
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        guard let outputCIImage = filter.outputImage else {
            error = .failedToApplyFilter
            return
        }
        if isCancelled { return }
        guard let cgImage = CIContext(options: nil).createCGImage(outputCIImage, from: outputCIImage.extent) else {
            error = .failedToRenderImage
            return
        }
        outputImage = UIImage(cgImage: cgImage)
    }
    
}

extension FilterOperation {

    enum Error {
        case invalidInputData
        case failedToApplyFilter
        case failedToRenderImage
    }

}
