import Foundation
import MapKit

extension ViewController {
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let pin = mapView.dequeueReusableAnnotationViewWithIdentifier(CONSTANT.MAP.ANNOTATION_IDENTIFIER) ?? AnnotationView(annotation: annotation, reuseIdentifier: CONSTANT.MAP.ANNOTATION_IDENTIFIER)
        
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let v = view.annotation as? MapAnnotation else { return }
        //TODO: hmmmm
        v.mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let a = view.annotation as? MapAnnotation, idx = viewModel.mapAnnotations.value.indexOf(a) else {return}
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0), animated: true, scrollPosition: .Middle)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        guard let a = view.annotation as? MapAnnotation, idx = viewModel.mapAnnotations.value.indexOf(a) else {return}
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0), animated: true)
    }
}