import SwiftUI
import CoreLocation

// MARK: - 实时数据视图
struct RealTimeDataView: View {
    @StateObject private var environmentalService = RealTimeEnvironmentalService()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var showingMap = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 实时数据概览
                    RealTimeOverviewCard()
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateCards)
                    
                    // 顶部实时数据卡片
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if let airQuality = environmentalService.airQualityData {
                                AirQualityCard(airQuality: airQuality)
                                    .scaleEffect(animateCards ? 1.0 : 0.9)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateCards)
                            }
                            
                            if let weather = environmentalService.weatherData {
                                WeatherCard(weather: weather)
                                    .scaleEffect(animateCards ? 1.0 : 0.9)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
                            }
                            
                            EnvironmentalStationsCard(stations: environmentalService.environmentalStations)
                                .scaleEffect(animateCards ? 1.0 : 0.9)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
                        }
                        .padding(.horizontal)
                    }
                    
                    // 快速访问按钮
                    QuickAccessButtons(showingMap: $showingMap)
                        .padding(.horizontal)
                    
                    // 标签页选择器
                    VStack(spacing: 16) {
                        Picker("数据类别", selection: $selectedTab) {
                            Text("环保设施").tag(0)
                            Text("回收站").tag(1)
                            Text("绿色建筑").tag(2)
                            Text("环保建议").tag(3)
                        }
                        .pickerStyle(.segmented)
                        
                        // 内容区域
                        TabView(selection: $selectedTab) {
                            EcoFacilitiesView(facilities: environmentalService.ecoFacilities)
                                .tag(0)
                            
                            RecyclingStationsView(stations: environmentalService.recyclingStations)
                                .tag(1)
                            
                            GreenBuildingsView(buildings: environmentalService.greenBuildings)
                                .tag(2)
                            
                            EcoRecommendationsView(recommendations: environmentalService.getEcoRecommendations())
                                .tag(3)
                        }
                        .frame(height: 400)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Live Data")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        environmentalService.refreshData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingMap) {
                EnvironmentalMapView(
                    facilities: environmentalService.ecoFacilities,
                    recyclingStations: environmentalService.recyclingStations,
                    greenBuildings: environmentalService.greenBuildings
                )
            }
            .onAppear {
                environmentalService.loadAllData()
                locationManager.requestLocation()
                animateCards = true
            }
        }
    }
}

// MARK: - 实时数据概览卡片
struct RealTimeOverviewCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hong Kong Live Data")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Real-time environmental information")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 20) {
                OverviewStat(
                    icon: "aqi.medium",
                    title: "Air Quality",
                    value: "Good",
                    color: .green
                )
                
                OverviewStat(
                    icon: "thermometer",
                    title: "Temperature",
                    value: "26°C",
                    color: .orange
                )
                
                OverviewStat(
                    icon: "location.fill",
                    title: "Stations",
                    value: "3 Active",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct OverviewStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 快速访问按钮
struct QuickAccessButtons: View {
    @Binding var showingMap: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            QuickAccessButton(
                icon: "map.fill",
                title: "Map View",
                color: .blue,
                action: { showingMap = true }
            )
            
            QuickAccessButton(
                icon: "location.fill",
                title: "Nearby",
                color: .green,
                action: { /* Show nearby facilities */ }
            )
            
            QuickAccessButton(
                icon: "bell.fill",
                title: "Alerts",
                color: .orange,
                action: { /* Show alerts */ }
            )
        }
    }
}

struct QuickAccessButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 空气质量卡片
struct AirQualityCard: View {
    let airQuality: AirQualityData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "aqi.medium")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Air Quality")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("AQHI")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(airQuality.aqhi)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(aqhiColor)
                }
                
                Text(airQuality.healthRiskLevel)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(aqhiColor)
                
                Text(airQuality.actionRequired)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text("Updated: \(airQuality.updateTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var aqhiColor: Color {
        switch airQuality.aqhi {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 天气卡片
struct WeatherCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Weather")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(weather.temperature, specifier: "%.1f")°C")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(weather.humidity)%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text("\(weather.windSpeed, specifier: "%.1f") m/s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(weather.windDirection)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "eye")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text("\(weather.visibility, specifier: "%.1f") km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("UV: \(weather.uvIndex)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Updated: \(weather.updateTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 环境监测站卡片
struct EnvironmentalStationsCard: View {
    let stations: [EnvironmentalStation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                
                Text("Stations")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(stations.count) Active")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !stations.isEmpty {
                    ForEach(stations.prefix(2), id: \.stationName) { station in
                        HStack {
                            Text(station.stationName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("AQI: \(station.airQualityIndex)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(aqiColor(station.airQualityIndex))
                        }
                    }
                } else {
                    Text("No stations available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Real-time monitoring")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func aqiColor(_ aqi: Int) -> Color {
        switch aqi {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 环保设施视图
struct EcoFacilitiesView: View {
    let facilities: [EcoFacility]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(facilities, id: \.id) { facility in
                    EcoFacilityCard(facility: facility)
                }
            }
            .padding()
        }
    }
}

struct EcoFacilityCard: View {
    let facility: EcoFacility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: facilityTypeIcon)
                    .foregroundColor(.green)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(facility.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(facility.district)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(facility.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(facility.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(facility.openingHours)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "phone")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(facility.contactInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var facilityTypeIcon: String {
        switch facility.type {
        case .ecoPark:
            return "tree.fill"
        case .greenSpace:
            return "leaf.fill"
        case .recycling:
            return "arrow.3.trianglepath"
        case .solarPanel:
            return "sun.max.fill"
        case .windTurbine:
            return "wind"
        case .electricVehicle:
            return "car.fill"
        case .bikeSharing:
            return "bicycle"
        }
    }
}

// MARK: - 回收站视图
struct RecyclingStationsView: View {
    let stations: [RecyclingStation]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(stations, id: \.id) { station in
                    RecyclingStationCard(station: station)
                }
            }
            .padding()
        }
    }
}

struct RecyclingStationCard: View {
    let station: RecyclingStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.3.trianglepath")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(station.district)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(station.currentLoad)/\(station.capacity)")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("Capacity")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(station.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("Materials:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(station.acceptedMaterials.map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(station.openingHours)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "phone")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(station.contactInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 绿色建筑视图
struct GreenBuildingsView: View {
    let buildings: [GreenBuilding]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(buildings, id: \.id) { building in
                    GreenBuildingCard(building: building)
                }
            }
            .padding()
        }
    }
}

struct GreenBuildingCard: View {
    let building: GreenBuilding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(building.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(building.district)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(building.certification.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(certificationColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(building.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Energy Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(building.energyRating)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Carbon Footprint")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(building.carbonFootprint, specifier: "%.1f") kg")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var certificationColor: Color {
        switch building.certification {
        case .platinum:
            return .purple
        case .gold:
            return .yellow
        case .silver:
            return .gray
        case .bronze:
            return .orange
        case .certified:
            return .green
        }
    }
}

// MARK: - 环保建议视图
struct EcoRecommendationsView: View {
    let recommendations: [EcoRecommendation]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recommendations, id: \.title) { recommendation in
                    EcoRecommendationCard(recommendation: recommendation)
                }
                
                if recommendations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("All Good!")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("No environmental alerts at the moment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}

struct EcoRecommendationCard: View {
    let recommendation: EcoRecommendation
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: priorityIcon)
                .foregroundColor(priorityColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var priorityIcon: String {
        switch recommendation.priority {
        case .high:
            return "exclamationmark.triangle.fill"
        case .medium:
            return "info.circle.fill"
        case .low:
            return "checkmark.circle.fill"
        }
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}

// MARK: - 环保地图视图 (简化为列表)
struct EnvironmentalMapView: View {
    let facilities: [EcoFacility]
    let recyclingStations: [RecyclingStation]
    let greenBuildings: [GreenBuilding]
    @State private var selectedMapType = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // 地图类型选择器
                Picker("地图类型", selection: $selectedMapType) {
                    Text("环保设施").tag(0)
                    Text("回收站").tag(1)
                    Text("绿色建筑").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 简化的地图视图 - 显示列表而不是实际地图
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(currentItems) { item in
                            MapItemRow(item: item)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Environmental Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // 关闭地图
                    }
                }
            }
        }
    }
    
    private var currentItems: [MapItem] {
        switch selectedMapType {
        case 0:
            return facilities.map { facility in
                MapItem(
                    id: facility.id,
                    name: facility.name,
                    address: facility.address,
                    district: facility.district,
                    iconName: "leaf.fill",
                    color: .green,
                    description: facility.description
                )
            }
        case 1:
            return recyclingStations.map { station in
                MapItem(
                    id: station.id,
                    name: station.name,
                    address: station.address,
                    district: station.district,
                    iconName: "arrow.3.trianglepath",
                    color: .blue,
                    description: "Materials: \(station.acceptedMaterials.map { $0.rawValue }.joined(separator: ", "))"
                )
            }
        case 2:
            return greenBuildings.map { building in
                MapItem(
                    id: building.id,
                    name: building.name,
                    address: building.address,
                    district: building.district,
                    iconName: "building.2.fill",
                    color: .purple,
                    description: "Certification: \(building.certification.rawValue)"
                )
            }
        default:
            return []
        }
    }
}

struct MapItem: Identifiable {
    let id: UUID
    let name: String
    let address: String
    let district: String
    let iconName: String
    let color: Color
    let description: String
}

struct MapItemRow: View {
    let item: MapItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .foregroundColor(item.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(item.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 位置管理器
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

// MARK: - 预览
struct RealTimeDataView_Previews: PreviewProvider {
    static var previews: some View {
        RealTimeDataView()
    }
}