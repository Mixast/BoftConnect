import Foundation
import UIKit
import CoreImage


func designFor(button: UIButton) {  // Кастамизирую кнопку
    button.layer.borderWidth = 1
    button.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    button.layer.cornerRadius = 10
    button.backgroundColor = .clear
    button.layer.shadowOffset = CGSize(width: 3, height: 3)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.6
}



let filterDeck = [
//     CICategoryBlur - mode
    "CIBoxBlur"
    , "CIDiscBlur"
    , "CIGaussianBlur"
    , "CIMaskedVariableBlur"
    , "CIMedianFilter"
    , "CIMotionBlur"
    , "CINoiseReduction"
    , "CIZoomBlur"
//    CICategoryColorAdjustment - mode
    , "CIColorClamp"
    , "CIColorControls"
    , "CIColorMatrix"
    , "CIColorPolynomial"
    , "CIExposureAdjust"
    , "CIGammaAdjust"
    , "CIHueAdjust"
    , "CILinearToSRGBToneCurve"
    , "CISRGBToneCurveToLinear"
    , "CITemperatureAndTint"
    , "CIToneCurve"
    , "CIVibrance"
    , "CIWhitePointAdjust"
//    CICategoryColorEffect - mode
    , "CIColorCrossPolynomial"
    , "CIColorCube"
    , "CIColorCubeWithColorSpace"
    , "CIColorInvert"
    , "CIColorMap"
    , "CIColorMonochrome"
    , "CIColorPosterize"
    , "CIFalseColor"
    , "CIMaskToAlpha"
    , "CIMaximumComponent"
    , "CIMinimumComponent"
    , "CIPhotoEffectChrome"
    , "CIPhotoEffectFade"
    , "CIPhotoEffectInstant"
    , "CIPhotoEffectMono"
    , "CIPhotoEffectNoir"
    , "CIPhotoEffectProcess"
    , "CIPhotoEffectTonal"
    , "CIPhotoEffectTransfer"
    , "CISepiaTone"
    , "CIVignette"
    , "CIVignetteEffect"
//    CICategoryCompositeOperation - mode
    , "CIAdditionCompositing"
    , "CIColorBlendMode"
    , "CIColorBurnBlendMode"
    , "CIColorDodgeBlendMode"
    , "CIDarkenBlendMode"
    , "CIDifferenceBlendMode"
    , "CIDivideBlendMode"
    , "CIExclusionBlendMode"
    , "CIHardLightBlendMode"
    , "CIHueBlendMode"
    , "CILightenBlendMode"
    , "CILinearBurnBlendMode"
    , "CILinearDodgeBlendMode"
    , "CILuminosityBlendMode"
    , "CIMaximumCompositing"
    , "CIMinimumCompositing"
    , "CIMultiplyBlendMode"
    , "CIMultiplyCompositing"
    , "CIOverlayBlendMode"
    , "CIPinLightBlendMode"
    , "CISaturationBlendMode"
    , "CIScreenBlendMode"
    , "CISoftLightBlendMode"
    , "CISourceAtopCompositing"
    , "CISourceInCompositing"
    , "CISourceOutCompositing"
    , "CISourceOverCompositing"
    , "CISubtractBlendMode"
//    CICategoryDistortionEffect - mode
    
    , "CIBumpDistortion"
    , "CIBumpDistortionLinear"
    , "CICircleSplashDistortion"
    , "CICircularWrap"
    , "CIDroste"
    , "CIDisplacementDistortion"
    , "CIGlassDistortion"
    , "CIGlassLozenge"
    , "CIHoleDistortion"
    , "CILightTunnel"
    , "CIPinchDistortion"
    , "CIStretchCrop"
    , "CITorusLensDistortion"
    , "CITwirlDistortion"
    , "CIVortexDistortion"

//    CICategoryGeometryAdjustment - mode
    , "CIAffineTransform"
    , "CICrop"
    , "CILanczosScaleTransform"
    , "CIPerspectiveCorrection"
    , "CIPerspectiveTransform"
    , "CIPerspectiveTransformWithExtent"
    , "CIStraightenFilter"
    
//    CICategoryHalftoneEffect - mode
    
    , "CICircularScreen"
    , "CICMYKHalftone"
    , "CIDotScreen"
    , "CIHatchedScreen"
    , "CILineScreen"
    
//    CICategorySharpen - mode
    
    , "CISharpenLuminance"
    , "CIUnsharpMask"

//    CICategoryStylize - mode
    
    
    , "CIBlendWithAlphaMask"
    , "CIBlendWithMask"
    , "CIBloom"
    , "CIComicEffect"
    , "CIConvolution3X3"
    , "CIConvolution5X5"
    , "CIConvolution7X7"
    , "CIConvolution9Horizontal"
    , "CIConvolution9Vertical"
    , "CICrystallize"
    , "CIDepthOfField"
    , "CIEdges"
    , "CIEdgeWork"
    , "CIGloom"
    , "CIHeightFieldFromMask"
    , "CIHexagonalPixellate"
    , "CIHighlightShadowAdjust"
    , "CILineOverlay"
    , "CIPixellate"
    , "CIPointillize"
    , "CIShadedMaterial"
    , "CISpotColor"
    , "CISpotLight"
    
//    CICategoryTileEffect - mode
    
    
    , "CIAffineClamp"
    , "CIAffineTile"
    , "CIEightfoldReflectedTile"
    , "CIFourfoldReflectedTile"
    , "CIFourfoldRotatedTile"
    , "CIFourfoldTranslatedTile"
    , "CIGlideReflectedTile"
    , "CIKaleidoscope"
    , "CIOpTile"
    , "CIParallelogramTile"
    , "CIPerspectiveTile"
    , "CISixfoldReflectedTile"
    , "CISixfoldRotatedTile"
    , "CITriangleKaleidoscope"
    , "CITriangleTile"
    , "CITwelvefoldReflectedTile"
    
    
//    CICategoryTransition - mode
    
    , "CIAccordionFoldTransition"
    , "CIBarsSwipeTransition"
    , "CICopyMachineTransition"
    , "CIDisintegrateWithMaskTransition"
    , "CIDissolveTransition"
    , "CIFlashTransition"
    , "CIModTransition"
    , "CIPageCurlTransition"
    , "CIPageCurlWithShadowTransition"
    , "CIRippleTransition"
    , "CISwipeTransition"

    
]

 
