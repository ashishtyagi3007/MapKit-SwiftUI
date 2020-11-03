//
//  ContentView.swift
//  MapKit SwiftUI
//
//  Created by Ashish Tyagi on 03/11/20.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var directions: [String] = []
    @State private var showDirections = false

    
    var body: some View {
       VStack {
        MapView(directions: $directions)
        
        Button(action: {
                self.showDirections.toggle()
              }, label: {
                Text("Show directions")
                    .foregroundColor(.white)
              })
              .disabled(directions.isEmpty)
              .padding()
            }
       .background(Color.init(.systemPurple))
       .sheet(isPresented: $showDirections, content: {
              VStack(spacing: 0) {
                Text("Directions")
                  .font(.largeTitle)
                  .bold()
                  .padding()
                
                Divider().background(Color.black)
                
                List(0..<self.directions.count, id: \.self) { i in
                  Text(self.directions[i]).padding()
                }
              }
            })
       }
     }



///UIViewRepresentable that will act as a wrapper around a UIKit MKMapView. This will allow us to implement MKMapViewDelegate functions that we can use to draw a route overlay on the map.



struct MapView: UIViewRepresentable {
    @Binding var directions: [String]

    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> MapViewCoordinator {
      return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 28.457523, longitude: 77.026344),
          span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        
        // Gurgaon
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 28.457523, longitude: 77.026344))
        
        // Delhi
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 28.644800, longitude: 77.216721))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
          guard let route = response?.routes.first else { return }
          mapView.addAnnotations([p1, p2])
          mapView.addOverlay(route.polyline)
          mapView.setVisibleMapRect(
            route.polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
            animated: true)
          self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
        }
        return mapView
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
        ///rendererFor method, which is in charge of drawing the line that represents the route between the two places.
            
          let renderer = MKPolylineRenderer(overlay: overlay)
          renderer.strokeColor = .black
          renderer.lineWidth = 8
          return renderer
            
        }
      }
    
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


