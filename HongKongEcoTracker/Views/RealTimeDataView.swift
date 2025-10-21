import SwiftUI
import CoreLocation

// MARK: - 实时数据视图
struct RealTimeDataView: View {
    @StateObject private var environmentalService = RealTimeEnvironmentalService()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var showingMap = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部实时数据卡片
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if let airQuality = environmentalService.airQualityData {
                            AirQualityCard(airQuality: airQuality)
                        }
                        
                        if let weather = environmentalService.weatherData {
                            WeatherCard(weather: weather)
                        }
                        
                        EnvironmentalStationsCard(stations: environmentalService.environmentalStations)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // 标签页选择器
                Picker("数据类别", selection: $selectedTab) {
                    Text("环保设施").tag(0)
                    Text("回收站").tag(1)
                    Text("绿色建筑").tag(2)
                    Text("环保建议").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
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
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("实时环保数据")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        environmentalService.refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingMap = true
                    }) {
                        Image(systemName: "map")
                    }
                }
            }
            .refreshable {
                environmentalService.refreshData()
            }
            .sheet(isPresented: $showingMap) {
                EnvironmentalMapView(
                    facilities: environmentalService.ecoFacilities,
                    recyclingStations: environmentalService.recyclingStations,
                    greenBuildings: environmentalService.greenBuildings
                )
            }
        }
    }
}

// MARK: - 空气质量卡片
struct AirQualityCard: View {
    let airQuality: AirQualityData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wind")
                    .foregroundColor(.blue)
                Text("空气质量")
                    .font(.headline)
                Spacer()
                Text("AQHI: \(airQuality.aqhi)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(riskColor)
            }
            
            Text(airQuality.healthRiskLevel)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(airQuality.actionRequired)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("更新: \(airQuality.updateTime)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .frame(width: 200)
    }
    
    private var riskColor: Color {
        switch airQuality.aqhi {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...10: return .orange
        default: return .red
        }
    }
}

// MARK: - 天气卡片
struct WeatherCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max")
                    .foregroundColor(.orange)
                Text("天气")
                    .font(.headline)
                Spacer()
                Text("\(Int(weather.temperature))°C")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(weather.temperatureDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("湿度: \(weather.humidity)%")
                Spacer()
                Text("风速: \(String(format: "%.1f", weather.windSpeed)) km/h")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text("更新: \(weather.updateTime)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .frame(width: 200)
    }
}

// MARK: - 环境监测站卡片
struct EnvironmentalStationsCard: View {
    let stations: [EnvironmentalStation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.green)
                Text("监测站")
                    .font(.headline)
                Spacer()
                Text("\(stations.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if let nearestStation = stations.first {
                Text(nearestStation.stationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("AQI: \(nearestStation.airQualityIndex)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("活跃监测站数量")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .frame(width: 200)
    }
}

// MARK: - 环保设施视图
struct EcoFacilitiesView: View {
    let facilities: [EcoFacility]
    @State private var selectedType: EcoFacility.EcoFacilityType?
    
    var body: some View {
        VStack {
            // 类型筛选器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(EcoFacility.EcoFacilityType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = (selectedType == type) ? nil : type
                        }) {
                            Text(type.rawValue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedType == type ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 设施列表
            List(filteredFacilities) { facility in
                EcoFacilityRow(facility: facility)
            }
            .listStyle(.plain)
        }
    }
    
    private var filteredFacilities: [EcoFacility] {
        if let selectedType = selectedType {
            return facilities.filter { $0.type == selectedType }
        }
        return facilities
    }
}

// MARK: - 环保设施行
struct EcoFacilityRow: View {
    let facility: EcoFacility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(facility.name)
                    .font(.headline)
                Spacer()
                Text(facility.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(facility.district)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(facility.address)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !facility.features.isEmpty {
                Text("特色: \(facility.features.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 回收站视图
struct RecyclingStationsView: View {
    let stations: [RecyclingStation]
    @State private var selectedMaterial: RecyclingStation.RecyclableMaterial?
    
    var body: some View {
        VStack {
            // 材料筛选器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(RecyclingStation.RecyclableMaterial.allCases, id: \.self) { material in
                        Button(action: {
                            selectedMaterial = (selectedMaterial == material) ? nil : material
                        }) {
                            Text(material.rawValue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedMaterial == material ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedMaterial == material ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 回收站列表
            List(filteredStations) { station in
                RecyclingStationRow(station: station)
            }
            .listStyle(.plain)
        }
    }
    
    private var filteredStations: [RecyclingStation] {
        if let selectedMaterial = selectedMaterial {
            return stations.filter { $0.acceptedMaterials.contains(selectedMaterial) }
        }
        return stations
    }
}

// MARK: - 回收站行
struct RecyclingStationRow: View {
    let station: RecyclingStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(station.name)
                    .font(.headline)
                Spacer()
                Text("\(Int(station.loadPercentage))%")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(loadColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(station.district)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(station.address)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("接受材料: \(station.acceptedMaterials.map { $0.rawValue }.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: station.loadPercentage / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: loadColor))
        }
        .padding(.vertical, 4)
    }
    
    private var loadColor: Color {
        switch station.loadPercentage {
        case 0..<50: return .green
        case 50..<80: return .yellow
        default: return .red
        }
    }
}

// MARK: - 绿色建筑视图
struct GreenBuildingsView: View {
    let buildings: [GreenBuilding]
    @State private var selectedCertification: GreenBuilding.GreenBuildingCertification?
    
    var body: some View {
        VStack {
            // 认证等级筛选器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(GreenBuilding.GreenBuildingCertification.allCases, id: \.self) { certification in
                        Button(action: {
                            selectedCertification = (selectedCertification == certification) ? nil : certification
                        }) {
                            Text(certification.rawValue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCertification == certification ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCertification == certification ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 建筑列表
            List(filteredBuildings) { building in
                GreenBuildingRow(building: building)
            }
            .listStyle(.plain)
        }
    }
    
    private var filteredBuildings: [GreenBuilding] {
        if let selectedCertification = selectedCertification {
            return buildings.filter { $0.certification == selectedCertification }
        }
        return buildings
    }
}

// MARK: - 绿色建筑行
struct GreenBuildingRow: View {
    let building: GreenBuilding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(building.name)
                    .font(.headline)
                Spacer()
                Text(building.certification.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(certificationColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(building.district)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(building.address)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("能源评级: \(building.energyRating)")
                Spacer()
                Text("碳足迹: \(String(format: "%.1f", building.carbonFootprint)) kg CO₂")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var certificationColor: Color {
        switch building.certification {
        case .platinum: return .purple
        case .gold: return .yellow
        case .silver: return .gray
        case .bronze: return .brown
        case .certified: return .green
        }
    }
}

// MARK: - 环保建议视图
struct EcoRecommendationsView: View {
    let recommendations: [EcoRecommendation]
    
    var body: some View {
        List(recommendations) { recommendation in
            EcoRecommendationRow(recommendation: recommendation)
        }
        .listStyle(.plain)
    }
}

// MARK: - 环保建议行
struct EcoRecommendationRow: View {
    let recommendation: EcoRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recommendation.title)
                    .font(.headline)
                Spacer()
                Text(recommendation.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(recommendation.category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

// MARK: - 环保地图视图
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
            .navigationTitle("环保地图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
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
                    description: "接受材料: \(station.acceptedMaterials.map { $0.rawValue }.joined(separator: ", "))"
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
                    description: "认证等级: \(building.certification.rawValue)"
                )
            }
        default:
            return []
        }
    }
}

// MARK: - 地图项目
struct MapItem: Identifiable {
    let id: UUID
    let name: String
    let address: String
    let district: String
    let iconName: String
    let color: Color
    let description: String
}

// MARK: - 地图项目行
struct MapItemRow: View {
    let item: MapItem
    
    var body: some View {
        HStack {
            Image(systemName: item.iconName)
                .foregroundColor(item.color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.district)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(item.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}

#Preview {
    RealTimeDataView()
}
