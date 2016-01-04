//
//  FixedFilterStack.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import CoreImage

/**
*   This class represents the filterstack that is used when using the UI.
*   It represents a chain of filters that will be applied to the taken image.
*   That way we make sure the order of filters stays the same, and we don't need to take
*   care about creating the single filters.
*/
@objc(IMGLYFixedFilterStack) public class FixedFilterStack: NSObject {

    // MARK: - Properties

    public var enhancementFilter: EnhancementFilter = {
        let filter = InstanceFactory.enhancementFilter()
        filter.enabled = false
        filter.storeEnhancedImage = true
        return filter
        }()

    public var orientationCropFilter = InstanceFactory.orientationCropFilter()
    public var effectFilter = InstanceFactory.effectFilterWithType(FilterType.None)
    public var brightnessFilter = InstanceFactory.colorAdjustmentFilter()
    public var tiltShiftFilter = InstanceFactory.tiltShiftFilter()
    public var textFilter = InstanceFactory.textFilter()
    public var stickerFilters = [Filter]()

    public var activeFilters: [Filter] {
        setCropRectForStickerFilters()
        setCropRectForTextFilters()
        var activeFilters: [Filter] = [enhancementFilter, orientationCropFilter, tiltShiftFilter, effectFilter, brightnessFilter, textFilter]
        activeFilters += stickerFilters
        return activeFilters
    }

    private func setCropRectForStickerFilters () {
        for stickerFilter in stickerFilters where stickerFilter is StickerFilter {
            // swiftlint:disable force_cast
            (stickerFilter as! StickerFilter).cropRect = orientationCropFilter.cropRect
            // swiftlint:enable force_fast
        }
    }

    private func setCropRectForTextFilters () {
        //for stickerFilter in stickerFilters {
         //   (stickerFilter as! IMGLYStickerFilter).cropRect = orientationCropFilter.cropRect
        //}
        textFilter.cropRect = orientationCropFilter.cropRect
    }

    public func rotateStickersRight () {
        rotateStickers(CGFloat(M_PI_2), negateX: true, negateY: false)
    }

    public func rotateStickersLeft () {
        rotateStickers(CGFloat(-M_PI_2), negateX: false, negateY: true)
    }

    public func rotateTextRight () {
        rotateText(CGFloat(M_PI_2), negateX: true, negateY: false)
    }

    public func rotateTextLeft () {
        rotateText(CGFloat(-M_PI_2), negateX: false, negateY: true)
    }

    private func rotateStickers(angle: CGFloat, negateX: Bool, negateY: Bool) {
        let xFactor: CGFloat = negateX ? -1.0 : 1.0
        let yFactor: CGFloat = negateY ? -1.0 : 1.0

        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                stickerFilter.transform = CGAffineTransformRotate(stickerFilter.transform, angle)
                stickerFilter.center.x -= 0.5
                stickerFilter.center.y -= 0.5
                let center = stickerFilter.center
                stickerFilter.center.x = xFactor * center.y
                stickerFilter.center.y = yFactor * center.x
                stickerFilter.center.x += 0.5
                stickerFilter.center.y += 0.5
            }
        }
    }

    private func rotateText (angle: CGFloat, negateX: Bool, negateY: Bool) {
        let xFactor: CGFloat = negateX ? -1.0 : 1.0
        let yFactor: CGFloat = negateY ? -1.0 : 1.0
        textFilter.transform = CGAffineTransformRotate(textFilter.transform, angle)
        textFilter.center.x -= 0.5
        textFilter.center.y -= 0.5
        let center = textFilter.center
        textFilter.center.x = xFactor * center.y
        textFilter.center.y = yFactor * center.x
        textFilter.center.x += 0.5
        textFilter.center.y += 0.5
    }


    public func flipStickersHorizontal () {
        flipStickers(true)
    }

    public func flipStickersVertical () {
        flipStickers(false)
    }

    public func flipTextHorizontal () {
        flipText(true)
    }

    public func flipTextVertical () {
        flipText(false)
    }

    private func flipStickers(horizontal: Bool) {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                if let sticker = stickerFilter.sticker {
                    let flippedOrientation = UIImageOrientation(rawValue:(sticker.imageOrientation.rawValue + 4) % 8)
                    stickerFilter.sticker = UIImage(CGImage: sticker.CGImage!, scale: sticker.scale, orientation: flippedOrientation!)
                }
                stickerFilter.center.x -= 0.5
                stickerFilter.center.y -= 0.5
                let center = stickerFilter.center
                if horizontal {
                    flipRotationHorizontal(stickerFilter)
                    stickerFilter.center.x = -center.x
                } else {
                    flipRotationVertical(stickerFilter)
                    stickerFilter.center.y = -center.y
                }
                stickerFilter.center.x += 0.5
                stickerFilter.center.y += 0.5
            }
        }
    }

    private func flipRotationHorizontal(stickerFilter: StickerFilter) {
        flipRotation(stickerFilter, axisAngle: CGFloat(M_PI))
    }

    private func flipRotationVertical(stickerFilter: StickerFilter) {
        flipRotation(stickerFilter, axisAngle: CGFloat(M_PI_2))
    }

    private func flipRotation(stickerFilter: StickerFilter, axisAngle: CGFloat) {
        var angle = atan2(stickerFilter.transform.b, stickerFilter.transform.a)
        let twoPI = CGFloat(M_PI * 2.0)
        // normalize angle
        while angle >= twoPI {
            angle -= twoPI
        }

        while angle < 0 {
            angle += twoPI
        }

        let delta = axisAngle - angle
        stickerFilter.transform = CGAffineTransformRotate(stickerFilter.transform, delta * 2.0)
    }

    private func flipText(horizontal: Bool) {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? TextFilter {
                stickerFilter.center.x -= 0.5
                stickerFilter.center.y -= 0.5
                let center = stickerFilter.center
                if horizontal {
                    flipRotationHorizontal(stickerFilter)
                    stickerFilter.center.x = -center.x
                } else {
                    flipRotationVertical(stickerFilter)
                    stickerFilter.center.y = -center.y
                }
                stickerFilter.center.x += 0.5
                stickerFilter.center.y += 0.5
            }
        }
    }

    private func flipRotationHorizontal(textFilter: TextFilter) {
        flipRotation(textFilter, axisAngle: CGFloat(M_PI))
    }

    private func flipRotationVertical(textFilter: TextFilter) {
        flipRotation(textFilter, axisAngle: CGFloat(M_PI_2))
    }

    private func flipRotation(textFilter: TextFilter, axisAngle: CGFloat) {
        var angle = atan2(textFilter.transform.b, textFilter.transform.a)
        let twoPI = CGFloat(M_PI * 2.0)
        // normalize angle
        while angle >= twoPI {
            angle -= twoPI
        }

        while angle < 0 {
            angle += twoPI
        }

        let delta = axisAngle - angle
        textFilter.transform = CGAffineTransformRotate(textFilter.transform, delta * 2.0)
    }

    // MARK: - Initializers
    required override public init () {
        super.init()
    }

}

extension FixedFilterStack: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init()
        // swiftlint:disable force_cast
        copy.enhancementFilter = enhancementFilter.copyWithZone(zone) as! EnhancementFilter
        copy.orientationCropFilter = orientationCropFilter.copyWithZone(zone) as! OrientationCropFilter
        copy.effectFilter = effectFilter.copyWithZone(zone) as! EffectFilter
        copy.brightnessFilter = brightnessFilter.copyWithZone(zone) as! ContrastBrightnessSaturationFilter
        copy.tiltShiftFilter = tiltShiftFilter.copyWithZone(zone) as! TiltshiftFilter
        copy.textFilter = textFilter.copyWithZone(zone) as! TextFilter
        copy.stickerFilters = NSArray(array: stickerFilters, copyItems: true) as! [Filter]
        // swiftlint:enable force_cast
        return copy
    }
}