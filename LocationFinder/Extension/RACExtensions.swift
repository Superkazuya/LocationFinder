import MapKit
import ReactiveCocoa

import UIKit

struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var text: UInt8 = 3
    static var image: UInt8 = 4
    static var CGFloat: UInt8 = 5
    static var CGRect: UInt8 = 6
}

extension SignalProducerType
{
    func ignoreError() -> SignalProducer<Value, NoError>
    {
        return self.flatMapError { _ in SignalProducer<Value, NoError>.empty}
    }
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
    var associatedProperty = objc_getAssociatedObject(host, key) as? T
    
    if associatedProperty == nil {
        associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    return associatedProperty!
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .startWithNext { newValue in
                setter(newValue)
        }
        return property
    }
}

extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { self.alpha = $0 }, getter: { self.alpha  })
    }
    
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { self.hidden = $0 }, getter: { self.hidden  })
    }
    
    public var rac_frame: MutableProperty<CGRect> {
        return lazyMutableProperty(self, key: &AssociationKey.CGRect, setter: { self.frame = $0 }, getter: { self.frame })
    }
}

extension UIImageView {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self, key: &AssociationKey.image, setter: { self.image = $0 }, getter: { self.image })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { self.text = $0 }, getter: { self.text ?? "" })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {
            
            self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .startWithNext { newValue in
                    self.text = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text!
    }
}

extension SignalType {
    public func animateWithDuration(duration: NSTimeInterval)-> Signal<Value, Error>
    {
        return Signal{ sink in
            self.observe{ event in
                switch event {
                case .Next(let val):
                    UIView.animateWithDuration(duration, animations: {sink.sendNext(val) })
                case .Interrupted:
                    sink.sendInterrupted()
                case .Failed(let err):
                    sink.sendFailed(err)
                case .Completed:
                    sink.sendCompleted()
                }
            }
        }.observeOn(UIScheduler())
        
    }
}


extension SignalProducerType {
    public func animateWithDuration(duration: NSTimeInterval) -> SignalProducer<Value, Error>
    {
        return lift { $0.animateWithDuration(duration) }
    }
}


extension AssociationKey {
    //static var hidden: UInt8 = 1
    //static var alpha: UInt8 = 2
    //static var text: UInt8 = 3
    //static var image: UInt8 = 4
    static var array: UInt8 = 19
    static var MKCoordinateRegion: UInt8 = 20
}

private func cast<T>(object: AnyObject?) -> T
{
    return (object as! RACTuple).second as! T
}


extension MKMapViewDelegate where Self: NSObject
{
    public func signalUserLocation() -> SignalProducer<MKUserLocation, NoError> {
        let locationSignal = self.rac_signalForSelector("mapView:didUpdateUserLocation:", fromProtocol: MKMapViewDelegate.self).toSignalProducer()
        
        //let errorSignal: SignalProducer<NSError, NoError> = self.rac_signalForSelector("mapView:didFailToLocateUserWithError", fromProtocol: MKMapViewDelegate.self).toSignalProducer()
            //.ignoreError()
            //.map(cast)
        
        return locationSignal
            .ignoreError()
            .map (cast)
    }
    
    public func signalRegionDidChangedAnimated() -> SignalProducer<(), NSError> {
        let signal = self.rac_signalForSelector("mapView:regionDidChangeAnimated:", fromProtocol: MKMapViewDelegate.self)
        return signal.toSignalProducer().map{_ in ()}
    }
    
    public func signalDidAddAnnotationViews() ->SignalProducer<[MKAnnotationView], NoError>
    {
        return self.rac_signalForSelector("mapView:didAddAnnotationViews:", fromProtocol: MKMapViewDelegate.self).toSignalProducer()
        .ignoreError()
        .map(cast)
    }
    
    
    public func signalDidSelectAnnotationView() ->SignalProducer<MKAnnotationView, NoError>
    {
        return self.rac_signalForSelector("mapView:didSelectAnnotationView:", fromProtocol: MKMapViewDelegate.self).toSignalProducer()
        .ignoreError()
        .map(cast)
    }
    
     public func signalDidDeselectAnnotationView() ->SignalProducer<MKAnnotationView, NoError>
    {
        return self.rac_signalForSelector("mapView:didDeselectAnnotationView:", fromProtocol: MKMapViewDelegate.self).toSignalProducer()
        .ignoreError()
        .map(cast)
    }
    
}


extension MKMapView
{
    
    public var rac_annotaions: MutableProperty<[MKAnnotation]> {
        return lazyMutableProperty(self, key: &AssociationKey.array, setter: {self.removeAnnotations(self.annotations); self.addAnnotations($0)}, getter: { self.annotations })
    }
    
    public var rac_regionAnimated: MutableProperty<MKCoordinateRegion> {
        return lazyMutableProperty(self, key: &AssociationKey.MKCoordinateRegion, setter: { self.setRegion($0, animated: true)} , getter: { self.region })
    }
}