import UIKit
import CoreImage

public class Filter {
    public init() { }
    var cFilter: CurrentFilter!
    var image: UIImage!
    var intensity: Float!

    var radius: Float!
    var scale: Float!
    var angle: Float!

    public enum CurrentFilter: String {
        case CIBoxBlur
        case CIDiscBlur
        case CIGaussianBlur
        case CIMaskedVariableBlur
        case CIMedianFilter
        case CIMotionBlur
        case CINoiseReduction
        case CIZoomBlur
        case CIColorClamp
        case CIColorControls
        case CIColorMatrix
        case CIColorPolynomial
        case CIExposureAdjust
        case CIGammaAdjust
        case CIHueAdjust
        case CILinearToSRGBToneCurve
        case CISRGBToneCurveToLinear
        case CITemperatureAndTint
        case CIToneCurve
        case CIVibrance
        case CIWhitePointAdjust
        case CIColorCrossPolynomial
        case CIColorCube
        case CIColorCubeWithColorSpace
        case CIColorInvert
        case CIColorMap
        case CIColorMonochrome
        case CIColorPosterize
        case CIFalseColor
        case CIMaskToAlpha
        case CIMaximumComponent
        case CIMinimumComponent
        case CIPhotoEffectChrome
        case CIPhotoEffectFade
        case CIPhotoEffectInstant
        case CIPhotoEffectMono
        case CIPhotoEffectNoir
        case CIPhotoEffectProcess
        case CIPhotoEffectTonal
        case CIPhotoEffectTransfer
        case CISepiaTone
        case CIVignette
        case CIVignetteEffect
        case CIAdditionCompositing
        case CIColorBlendMode
        case CIColorBurnBlendMode
        case CIColorDodgeBlendMode
        case CIDarkenBlendMode
        case CIDifferenceBlendMode
        case CIDivideBlendMode
        case CIExclusionBlendMode
        case CIHardLightBlendMode
        case CIHueBlendMode
        case CILightenBlendMode
        case CILinearBurnBlendMode
        case CILinearDodgeBlendMode
        case CILuminosityBlendMode
        case CIMaximumCompositing
        case CIMinimumCompositing
        case CIMultiplyBlendMode
        case CIMultiplyCompositing
        case CIOverlayBlendMode
        case CIPinLightBlendMode
        case CISaturationBlendMode
        case CIScreenBlendMode
        case CISoftLightBlendMode
        case CISourceAtopCompositing
        case CISourceInCompositing
        case CISourceOutCompositing
        case CISourceOverCompositing
        case CISubtractBlendMode
        case CIBumpDistortion
        case CIBumpDistortionLinear
        case CICircleSplashDistortion
        case CICircularWrap
        case CIDroste
        case CIDisplacementDistortion
        case CIGlassDistortion
        case CIGlassLozenge
        case CIHoleDistortion
        case CILightTunnel
        case CIPinchDistortion
        case CIStretchCrop
        case CITorusLensDistortion
        case CITwirlDistortion
        case CIVortexDistortion
        case CIAffineTransform
        case CICrop
        case CILanczosScaleTransform
        case CIPerspectiveCorrection
        case CIPerspectiveTransform
        case CIPerspectiveTransformWithExtent
        case CIStraightenFilter
        case CICircularScreen
        case CICMYKHalftone
        case CIDotScreen
        case CIHatchedScreen
        case CILineScreen
        case CISharpenLuminance
        case CIUnsharpMask
        case CIBlendWithAlphaMask
        case CIBlendWithMask
        case CIBloom
        case CIComicEffect
        case CIConvolution3X3
        case CIConvolution5X5
        case CIConvolution7X7
        case CIConvolution9Horizontal
        case CIConvolution9Vertical
        case CICrystallize
        case CIDepthOfField
        case CIEdges
        case CIEdgeWork
        case CIGloom
        case CIHeightFieldFromMask
        case CIHexagonalPixellate
        case CIHighlightShadowAdjust
        case CILineOverlay
        case CIPixellate
        case CIPointillize
        case CIShadedMaterial
        case CISpotColor
        case CISpotLight
        case CIAffineClamp
        case CIAffineTile
        case CIEightfoldReflectedTile
        case CIFourfoldReflectedTile
        case CIFourfoldRotatedTile
        case CIFourfoldTranslatedTile
        case CIGlideReflectedTile
        case CIKaleidoscope
        case CIOpTile
        case CIParallelogramTile
        case CIPerspectiveTile
        case CISixfoldReflectedTile
        case CISixfoldRotatedTile
        case CITriangleKaleidoscope
        case CITriangleTile
        case CITwelvefoldReflectedTile
        case CIAccordionFoldTransition
        case CIBarsSwipeTransition
        case CICopyMachineTransition
        case CIDisintegrateWithMaskTransition
        case CIDissolveTransition
        case CIFlashTransition
        case CIModTransition
        case CIPageCurlTransition
        case CIPageCurlWithShadowTransition
        case CIRippleTransition
        case CISwipeTransition
    }
    
    public func addFilter(inputImage: UIImage?, currentFilter: CurrentFilter?, inputIntensity: Float?, inputRadius: Float?, inputScale: Float?, inputAngle: Float?) -> UIImage {
        if inputImage == nil {
            if image == nil {
                return UIImage()
            }
        } else {
            image = inputImage
        }
        
        if currentFilter == nil {
            if cFilter == nil {
                return image
            }
        } else {
            cFilter = currentFilter
        }
        
        var count = 0
        
        if inputIntensity != nil {
            count += 1
            intensity = inputIntensity
        }
        
        if inputRadius != nil {
            count += 1
            radius = inputRadius
        }
        
        if inputScale != nil {
            count += 1
            scale = inputScale
        }
        
        if inputAngle != nil {
            count += 1
            angle = inputAngle
        }
        
        if count == 0 {
            return image
        }
        
        

        let imageReferal = CIImage(image: image)
        let context = CIContext(options: nil)
        let filter = CIFilter(name: cFilter.rawValue)
        filter?.setValue(imageReferal, forKey: kCIInputImageKey)
        filter?.setDefaults()
        
        
        guard let inputKeys = filter?.inputKeys else {
            return image
        }

        if (inputKeys.contains(kCIInputIntensityKey)) && intensity != nil {
            filter?.setValue( (intensity - 0.5) * 5 , forKey: kCIInputIntensityKey)
        }

        if (inputKeys.contains(kCIInputRadiusKey)) && radius != nil {
            filter?.setValue((radius - 0.5) * 400, forKey: kCIInputRadiusKey)
        }

        if (inputKeys.contains(kCIInputScaleKey)) && scale != nil {
            filter?.setValue((scale - 0.5) * 10, forKey: kCIInputScaleKey)
        }

        if (inputKeys.contains(kCIInputAngleKey)) && angle != nil {
            filter?.setValue((angle - 0.5) * 20, forKey: kCIInputAngleKey)
        }
        
        if (inputKeys.contains(kCIInputCenterKey)) {
            filter?.setValue(CIVector(x: image.size.width / 2, y: image.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        if (inputKeys.contains(kCIInputAmountKey)) && angle != nil {
            filter?.setValue((angle - 0.5) * 20, forKey: kCIInputAmountKey)
        }
        
        if (inputKeys.contains(kCIInputMaskImageKey)) && radius != nil  {
            filter?.setValue((radius - 0.5) * 400, forKey: kCIInputMaskImageKey)
        } else {
            
        }
        

//        switch currentFilter {
//        case .CISpotColor?:
//            print("1")
//        case .CIMotionBlur?:
//
//            print("2")
//        case .CISepiaTone?:
//            print("3")
//        case .CIVignette?:
//            print("4")
//        case .CIUnsharpMask?:
//            print("5")
//        case .CITwirlDistortion?:
//            print("6")
//        case .CIPixellate?:
//            print("7")
//        case .CIGaussianBlur?:
//            print("8")
//        case .CIBumpDistortion?:
//            print("9")
//        case .none: break
//        }

        guard let ciFiltredImage = filter?.outputImage else {
            return image
        }

        guard let cgImage = context.createCGImage(ciFiltredImage, from: ciFiltredImage.extent) else {
            return image
        }
        let resultImage = UIImage(cgImage: cgImage)
        return resultImage
    }
    
}
