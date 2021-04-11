
// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  @Binding var centerCoordinate : CLLocationCoordinate2D

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.frame = CGRect(origin: .zero, size: CGSize(width: 800, height: 400))
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    view.centerCoordinate = centerCoordinate
    let ma = MKPointAnnotation()
    ma.coordinate = centerCoordinate
    view.addAnnotation(ma)
    view.region = MKCoordinateRegion.init(center: centerCoordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.2, longitudeDelta: 0.2))
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
      self.parent = parent
    }
  }
}

extension MKPointAnnotation {
  static var example: MKPointAnnotation {
    let annotation = MKPointAnnotation()
    annotation.title = "London"
    annotation.subtitle = "Home to the 2012 Summer Olympics."
    annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
    return annotation
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate) )
  }
}
