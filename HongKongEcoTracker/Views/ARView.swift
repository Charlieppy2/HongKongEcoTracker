import SwiftUI
import ARKit
import RealityKit
import CoreLocation

// MARK: - AR View
struct ARView: View {
    @StateObject private var arViewModel = ARViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showingSettings = false
    @State private var showingDataPanel = false
    @State private var selectedARMode: ARMode = .environmentalData
    @State private var isScanning = false
    
    var body: some View {
        ZStack {
            // AR Camera View
            ARCameraView(arViewModel: arViewModel)
                .ignoresSafeArea()
            
            // Top Control Panel
            VStack {
                TopControlPanel(
                    selectedMode: $selectedARMode,
                    isScanning: $isScanning,
                    showingSettings: $showingSettings
                )
                .padding(.top, 50)
                
                Spacer()
                
                // Bottom Data Panel
                if showingDataPanel {
                    BottomDataPanel(
                        arViewModel: arViewModel,
                        locationManager: locationManager
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            
            // AR Overlay Elements
            AROverlayElements(arViewModel: arViewModel)
            
            // Scanning Indicator
            if isScanning {
                ScanningIndicator()
            }
        }
        .onAppear {
            arViewModel.startARSession()
            locationManager.requestLocation()
        }
        .onDisappear {
            arViewModel.stopARSession()
        }
        .sheet(isPresented: $showingSettings) {
            ARSettingsView(arViewModel: arViewModel)
        }
    }
}

// MARK: - AR Camera View
struct ARCameraView: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView()
        arView.session = arViewModel.session
        arView.session.delegate = arViewModel
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR view if needed
    }
}

// MARK: - Top Control Panel
struct TopControlPanel: View {
    @Binding var selectedMode: ARMode
    @Binding var isScanning: Bool
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack {
            // Mode Selector
            ARModeSelector(selectedMode: $selectedMode)
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 16) {
                // Scan Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isScanning.toggle()
                    }
                }) {
                    Image(systemName: isScanning ? "stop.circle.fill" : "viewfinder")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isScanning ? Color.red : Color.green)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                
                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - AR Mode Selector
struct ARModeSelector: View {
    @Binding var selectedMode: ARMode
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(ARMode.allCases, id: \.self) { mode in
                ARModeButton(
                    mode: mode,
                    isSelected: selectedMode == mode
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.6))
                .backdrop(BlurView(style: .systemMaterial))
        )
    }
}

// MARK: - AR Mode Button
struct ARModeButton: View {
    let mode: ARMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(mode.title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bottom Data Panel
struct BottomDataPanel: View {
    let arViewModel: ARViewModel
    let locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Panel Header
            HStack {
                Text("Environmental Data")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Refresh data
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            
            // Data Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ARDataCard(
                        title: "Air Quality",
                        value: "Good",
                        icon: "wind",
                        color: .green
                    )
                    
                    ARDataCard(
                        title: "Temperature",
                        value: "26°C",
                        icon: "thermometer",
                        color: .orange
                    )
                    
                    ARDataCard(
                        title: "Humidity",
                        value: "65%",
                        icon: "humidity",
                        color: .blue
                    )
                    
                    ARDataCard(
                        title: "Carbon Footprint",
                        value: "12.5 kg",
                        icon: "leaf",
                        color: .green
                    )
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .backdrop(BlurView(style: .systemMaterial))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - AR Data Card
struct ARDataCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - AR Overlay Elements
struct AROverlayElements: View {
    let arViewModel: ARViewModel
    
    var body: some View {
        ZStack {
            // Environmental Markers
            ForEach(arViewModel.environmentalMarkers) { marker in
                ARMarkerView(marker: marker)
            }
            
            // Reticle (Crosshair)
            ReticleView()
            
            // Distance Indicator
            if let distance = arViewModel.nearestDistance {
                DistanceIndicator(distance: distance)
            }
        }
    }
}

// MARK: - AR Marker View
struct ARMarkerView: View {
    let marker: ARMarker
    
    var body: some View {
        VStack(spacing: 8) {
            // Marker Icon
            Image(systemName: marker.icon)
                .font(.title)
                .foregroundColor(marker.color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(marker.color, lineWidth: 2)
                        )
                )
            
            // Marker Label
            Text(marker.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.7))
                )
        }
        .scaleEffect(marker.scale)
        .opacity(marker.opacity)
        .animation(.easeInOut(duration: 0.3), value: marker.scale)
    }
}

// MARK: - Reticle View
struct ReticleView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer Ring
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            // Inner Dot
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
            
            // Corner Brackets
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(width: 20, height: 3)
                    .offset(
                        x: index % 2 == 0 ? 35 : -35,
                        y: index < 2 ? 35 : -35
                    )
                    .rotationEffect(.degrees(Double(index) * 90))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Distance Indicator
struct DistanceIndicator: View {
    let distance: Double
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                
                Text(String(format: "%.1f m", distance))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
            )
            .padding(.bottom, 200)
        }
    }
}

// MARK: - Scanning Indicator
struct ScanningIndicator: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Scanning Animation
            VStack(spacing: 20) {
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    
                    // Scanning Arc
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color.green, lineWidth: 4)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Center Icon
                    Image(systemName: "viewfinder")
                        .font(.title)
                        .foregroundColor(.green)
                }
                
                Text("Scanning Environment...")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - AR Settings View
struct ARSettingsView: View {
    let arViewModel: ARViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("AR Features") {
                    Toggle("Environmental Markers", isOn: .constant(true))
                    Toggle("Distance Indicators", isOn: .constant(true))
                    Toggle("Data Overlays", isOn: .constant(true))
                }
                
                Section("Display Settings") {
                    HStack {
                        Text("Marker Size")
                        Spacer()
                        Text("Medium")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Transparency")
                        Spacer()
                        Text("80%")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data Sources") {
                    HStack {
                        Text("Air Quality API")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Weather API")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("AR Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Blur View
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - AR Mode Enum
enum ARMode: CaseIterable {
    case environmentalData
    case landmarks
    case ecoFacilities
    case carbonTracking
    
    var title: String {
        switch self {
        case .environmentalData: return "Data"
        case .landmarks: return "Landmarks"
        case .ecoFacilities: return "Facilities"
        case .carbonTracking: return "Carbon"
        }
    }
    
    var icon: String {
        switch self {
        case .environmentalData: return "chart.bar.fill"
        case .landmarks: return "building.2.fill"
        case .ecoFacilities: return "leaf.fill"
        case .carbonTracking: return "cloud.fill"
        }
    }
}

// MARK: - Preview
struct ARView_Previews: PreviewProvider {
    static var previews: some View {
        ARView()
    }
}
