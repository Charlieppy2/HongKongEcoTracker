import SwiftUI
import RealityKit
import ARKit

// MARK: - AR Reality View
struct ARRealityView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var showingARView = false
    
    var body: some View {
        ZStack {
            if showingARView {
                ARViewContainer(arViewModel: arViewModel)
                    .ignoresSafeArea()
            } else {
                ARPreviewView(showingARView: $showingARView)
            }
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView()
        arView.session = arViewModel.session
        
        // Add environmental entities
        addEnvironmentalEntities(to: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR view if needed
    }
    
    private func addEnvironmentalEntities(to arView: ARView) {
        // Create air quality indicator
        let airQualityEntity = createAirQualityEntity()
        airQualityEntity.position = SIMD3<Float>(0, 0, -2)
        arView.scene.addAnchor(EntityAnchor(anchor: airQualityEntity))
        
        // Create carbon footprint visualization
        let carbonEntity = createCarbonFootprintEntity()
        carbonEntity.position = SIMD3<Float>(1, 0, -2)
        arView.scene.addAnchor(EntityAnchor(anchor: carbonEntity))
        
        // Create eco facility marker
        let facilityEntity = createEcoFacilityEntity()
        facilityEntity.position = SIMD3<Float>(-1, 0, -2)
        arView.scene.addAnchor(EntityAnchor(anchor: facilityEntity))
    }
    
    private func createAirQualityEntity() -> Entity {
        let entity = Entity()
        
        // Create air quality sphere
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: .green, isMetallic: false)]
        )
        
        // Add pulsing animation
        let pulseAnimation = FromToByAnimation<Transform>(
            name: "pulse",
            from: Transform(scale: SIMD3<Float>(1, 1, 1)),
            to: Transform(scale: SIMD3<Float>(1.5, 1.5, 1.5)),
            duration: 2.0,
            timing: .easeInOut,
            isAdditive: false
        )
        
        sphere.playAnimation(pulseAnimation.repeat())
        entity.addChild(sphere)
        
        return entity
    }
    
    private func createCarbonFootprintEntity() -> Entity {
        let entity = Entity()
        
        // Create carbon particles
        for i in 0..<20 {
            let particle = ModelEntity(
                mesh: .generateSphere(radius: 0.02),
                materials: [SimpleMaterial(color: .orange, isMetallic: false)]
            )
            
            let angle = Float(i) * 2 * Float.pi / 20
            let radius: Float = 0.3
            
            particle.position = SIMD3<Float>(
                cos(angle) * radius,
                Float.random(in: -0.2...0.2),
                sin(angle) * radius
            )
            
            // Add floating animation
            let floatAnimation = FromToByAnimation<Transform>(
                name: "float",
                from: Transform(translation: particle.position),
                to: Transform(translation: SIMD3<Float>(
                    particle.position.x,
                    particle.position.y + 0.5,
                    particle.position.z
                )),
                duration: Double.random(in: 2...4),
                timing: .easeInOut,
                isAdditive: false
            )
            
            particle.playAnimation(floatAnimation.repeat())
            entity.addChild(particle)
        }
        
        return entity
    }
    
    private func createEcoFacilityEntity() -> Entity {
        let entity = Entity()
        
        // Create facility building
        let building = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(0.2, 0.3, 0.2)),
            materials: [SimpleMaterial(color: .green, isMetallic: false)]
        )
        
        // Add solar panels on top
        let solarPanel = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(0.25, 0.02, 0.15)),
            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
        )
        solarPanel.position = SIMD3<Float>(0, 0.16, 0)
        
        building.addChild(solarPanel)
        entity.addChild(building)
        
        return entity
    }
}

// MARK: - AR Preview View
struct ARPreviewView: View {
    @Binding var showingARView: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.green.opacity(0.8), .blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // AR Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "arkit")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // Title and Description
                VStack(spacing: 16) {
                    Text("AR Environmental Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Experience Hong Kong's environmental data in augmented reality. See air quality, carbon footprints, and eco facilities in real-time.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Features List
                VStack(spacing: 12) {
                    ARFeatureRow(icon: "wind", title: "Real-time Air Quality", description: "See air quality data overlaid on your surroundings")
                    ARFeatureRow(icon: "leaf", title: "Carbon Footprint Tracking", description: "Visualize your environmental impact in 3D")
                    ARFeatureRow(icon: "building.2", title: "Eco Facilities Discovery", description: "Find nearby green buildings and recycling centers")
                    ARFeatureRow(icon: "location", title: "Location-based Data", description: "Get environmental insights for your current location")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Start AR Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingARView = true
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arkit")
                            .font(.title2)
                        
                        Text("Start AR Experience")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - AR Feature Row
struct ARFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

// MARK: - AR Data Visualization
struct ARDataVisualization: View {
    let data: AREnvironmentalData
    
    var body: some View {
        VStack(spacing: 20) {
            // Air Quality Visualization
            AirQualityVisualization(level: data.airQuality)
            
            // Temperature Gauge
            TemperatureGauge(temperature: data.temperature)
            
            // Carbon Footprint Chart
            CarbonFootprintChart(footprint: data.carbonFootprint)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .backdrop(BlurView(style: .systemMaterial))
        )
    }
}

// MARK: - Air Quality Visualization
struct AirQualityVisualization: View {
    let level: AREnvironmentalData.AirQualityLevel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Air Quality")
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(level.color, lineWidth: 8)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Text(level.description)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Temperature Gauge
struct TemperatureGauge: View {
    let temperature: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Temperature")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                
                Text("\(Int(temperature))°C")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Carbon Footprint Chart
struct CarbonFootprintChart: View {
    let footprint: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Carbon Footprint")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                Image(systemName: "cloud.fill")
                    .foregroundColor(.orange)
                
                Text("\(String(format: "%.1f", footprint)) kg CO₂")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - AR Gesture Controls
struct ARGestureControls: View {
    @StateObject private var gestureHandler = ARGestureHandler()
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 20) {
                // Tap to select
                ARControlButton(
                    icon: "hand.tap",
                    title: "Tap",
                    description: "Select markers"
                )
                
                // Pinch to zoom
                ARControlButton(
                    icon: "hand.pinch",
                    title: "Pinch",
                    description: "Zoom in/out"
                )
                
                // Drag to move
                ARControlButton(
                    icon: "hand.draw",
                    title: "Drag",
                    description: "Move objects"
                )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - AR Control Button
struct ARControlButton: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview
struct ARRealityView_Previews: PreviewProvider {
    static var previews: some View {
        ARRealityView()
    }
}
