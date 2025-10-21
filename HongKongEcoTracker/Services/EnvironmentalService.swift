import Foundation
import Combine
import CoreLocation

// MARK: - 香港政府开放数据API服务
class HongKongGovernmentAPI {
    static let shared = HongKongGovernmentAPI()
    
    // 香港政府开放数据平台基础URL
    private let baseURL = "https://data.weather.gov.hk/weatherAPI/opendata/"
    private let environmentBaseURL = "https://api.data.gov.hk/v1/facility-based-geo"
    
    private init() {}
    
    // MARK: - 空气质量数据
    func fetchAirQualityData() async throws -> AirQualityData {
        let url = URL(string: "\(baseURL)air_quality.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AirQualityData.self, from: data)
    }
    
    // MARK: - 天气数据
    func fetchWeatherData() async throws -> WeatherData {
        let url = URL(string: "\(baseURL)weather.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherData.self, from: data)
    }
    
    // MARK: - 环境监测站数据
    func fetchEnvironmentalMonitoringData() async throws -> [EnvironmentalStation] {
        let url = URL(string: "\(baseURL)environmental_monitoring.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([EnvironmentalStation].self, from: data)
    }
    
    // MARK: - 香港环保设施数据
    func fetchEcoFacilities() async throws -> [EcoFacility] {
        let url = URL(string: "\(environmentBaseURL)/eco-facilities")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([EcoFacility].self, from: data)
    }
    
    // MARK: - 香港回收站数据
    func fetchRecyclingStations() async throws -> [RecyclingStation] {
        let url = URL(string: "\(environmentBaseURL)/recycling-stations")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([RecyclingStation].self, from: data)
    }
    
    // MARK: - 香港绿色建筑数据
    func fetchGreenBuildings() async throws -> [GreenBuilding] {
        let url = URL(string: "\(environmentBaseURL)/green-buildings")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([GreenBuilding].self, from: data)
    }
}

// MARK: - 空气质量数据模型
struct AirQualityData: Codable {
    let generalStation: String
    let roadsideStation: String
    let aqhi: Int
    let healthRiskLevel: String
    let actionRequired: String
    let pollutants: [Pollutant]
    let updateTime: String
    
    var riskLevelColor: String {
        switch aqhi {
        case 1...3: return "green"
        case 4...6: return "yellow"
        case 7...10: return "orange"
        default: return "red"
        }
    }
}

struct Pollutant: Codable {
    let name: String
    let concentration: Double
    let unit: String
    let aqhi: Int
}

// MARK: - 天气数据模型
struct WeatherData: Codable {
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: String
    let pressure: Double
    let visibility: Double
    let uvIndex: Int
    let updateTime: String
    
    var temperatureDescription: String {
        switch temperature {
        case ..<10: return "寒冷"
        case 10..<20: return "涼爽"
        case 20..<30: return "溫暖"
        default: return "炎熱"
        }
    }
}

// MARK: - 环境监测站
struct EnvironmentalStation: Codable, Identifiable {
    let id = UUID()
    let stationName: String
    let district: String
    let latitude: Double
    let longitude: Double
    let airQualityIndex: Int
    let noiseLevel: Double
    let temperature: Double
    let humidity: Int
    let lastUpdate: String
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 环保设施
struct EcoFacility: Codable, Identifiable {
    let id = UUID()
    let name: String
    let type: EcoFacilityType
    let district: String
    let address: String
    let latitude: Double
    let longitude: Double
    let description: String
    let openingHours: String
    let contactInfo: String
    let features: [String]
    
    enum EcoFacilityType: String, CaseIterable, Codable {
        case recycling = "回收站"
        case greenSpace = "綠化空間"
        case solarPanel = "太陽能板"
        case windTurbine = "風力發電"
        case electricVehicle = "電動車充電站"
        case bikeSharing = "共享單車"
        case ecoPark = "環保公園"
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 回收站
struct RecyclingStation: Codable, Identifiable {
    let id = UUID()
    let name: String
    let district: String
    let address: String
    let latitude: Double
    let longitude: Double
    let acceptedMaterials: [RecyclableMaterial]
    let openingHours: String
    let contactInfo: String
    let capacity: Int
    let currentLoad: Int
    
    enum RecyclableMaterial: String, CaseIterable, Codable {
        case paper = "紙張"
        case plastic = "塑膠"
        case metal = "金屬"
        case glass = "玻璃"
        case electronics = "電子產品"
        case batteries = "電池"
        case clothing = "衣物"
        case organic = "有機廢物"
    }
    
    var loadPercentage: Double {
        return Double(currentLoad) / Double(capacity) * 100
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 绿色建筑
struct GreenBuilding: Codable, Identifiable {
    let id = UUID()
    let name: String
    let district: String
    let address: String
    let latitude: Double
    let longitude: Double
    let certification: GreenBuildingCertification
    let energyRating: String
    let waterEfficiency: String
    let wasteManagement: String
    let greenFeatures: [String]
    let carbonFootprint: Double
    let lastAssessment: String
    
    enum GreenBuildingCertification: String, CaseIterable, Codable {
        case platinum = "鉑金級"
        case gold = "金級"
        case silver = "銀級"
        case bronze = "銅級"
        case certified = "認證級"
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 实时环保数据服务
class RealTimeEnvironmentalService: ObservableObject {
    @Published var airQualityData: AirQualityData?
    @Published var weatherData: WeatherData?
    @Published var environmentalStations: [EnvironmentalStation] = []
    @Published var ecoFacilities: [EcoFacility] = []
    @Published var recyclingStations: [RecyclingStation] = []
    @Published var greenBuildings: [GreenBuilding] = []
    @Published var isLoading = false
    @Published var lastUpdateTime: Date?
    
    private let api = HongKongGovernmentAPI.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAllData()
    }
    
    // MARK: - 加载所有数据
    func loadAllData() {
        isLoading = true
        
        // 模拟API调用延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 加载模拟数据
            self.loadMockData()
            self.isLoading = false
        }
    }
    
    // MARK: - 加载模拟数据
    private func loadMockData() {
        // 模拟空气质量数据
        self.airQualityData = AirQualityData(
            generalStation: "中環",
            roadsideStation: "銅鑼灣",
            aqhi: 4,
            healthRiskLevel: "中等",
            actionRequired: "一般市民可正常活動",
            pollutants: [
                Pollutant(name: "PM2.5", concentration: 25.5, unit: "μg/m³", aqhi: 3),
                Pollutant(name: "PM10", concentration: 35.2, unit: "μg/m³", aqhi: 4),
                Pollutant(name: "NO2", concentration: 45.8, unit: "μg/m³", aqhi: 4)
            ],
            updateTime: "2024-10-21 18:25"
        )
        
        // 模拟天气数据
        self.weatherData = WeatherData(
            temperature: 26.5,
            humidity: 78,
            windSpeed: 12.3,
            windDirection: "東北",
            pressure: 1013.2,
            visibility: 8.5,
            uvIndex: 6,
            updateTime: "2024-10-21 18:25"
        )
        
        // 模拟环境监测站
        self.environmentalStations = [
            EnvironmentalStation(
                stationName: "中環監測站",
                district: "中西區",
                latitude: 22.2819,
                longitude: 114.1556,
                airQualityIndex: 4,
                noiseLevel: 65.2,
                temperature: 26.8,
                humidity: 76,
                lastUpdate: "2024-10-21 18:20"
            ),
            EnvironmentalStation(
                stationName: "銅鑼灣監測站",
                district: "灣仔區",
                latitude: 22.2783,
                longitude: 114.1828,
                airQualityIndex: 5,
                noiseLevel: 72.1,
                temperature: 27.2,
                humidity: 79,
                lastUpdate: "2024-10-21 18:22"
            ),
            EnvironmentalStation(
                stationName: "尖沙咀監測站",
                district: "油尖旺區",
                latitude: 22.2974,
                longitude: 114.1721,
                airQualityIndex: 3,
                noiseLevel: 68.5,
                temperature: 26.5,
                humidity: 77,
                lastUpdate: "2024-10-21 18:18"
            )
        ]
        
        // 模拟环保设施
        self.ecoFacilities = [
            EcoFacility(
                name: "維多利亞公園",
                type: .ecoPark,
                district: "灣仔區",
                address: "香港銅鑼灣興發街1號",
                latitude: 22.2811,
                longitude: 114.1897,
                description: "香港最大的公園，擁有豐富的綠化空間和環保設施",
                openingHours: "06:00-23:00",
                contactInfo: "2570 6170",
                features: ["太陽能照明", "雨水收集", "有機堆肥", "電動車充電站"]
            ),
            EcoFacility(
                name: "香港公園",
                type: .greenSpace,
                district: "中西區",
                address: "香港中環紅棉路19號",
                latitude: 22.2789,
                longitude: 114.1606,
                description: "市中心的綠洲，提供多種環保設施",
                openingHours: "06:00-23:00",
                contactInfo: "2521 5041",
                features: ["太陽能板", "風力發電", "雨水回收", "共享單車站"]
            ),
            EcoFacility(
                name: "九龍公園",
                type: .ecoPark,
                district: "油尖旺區",
                address: "香港尖沙咀柯士甸道22號",
                latitude: 22.3019,
                longitude: 114.1719,
                description: "九龍半島的主要綠化空間",
                openingHours: "06:00-23:00",
                contactInfo: "2724 3344",
                features: ["太陽能照明", "有機堆肥", "電動車充電站", "環保廁所"]
            )
        ]
        
        // 模拟回收站
        self.recyclingStations = [
            RecyclingStation(
                name: "中環回收站",
                district: "中西區",
                address: "香港中環德輔道中99號",
                latitude: 22.2819,
                longitude: 114.1556,
                acceptedMaterials: [.paper, .plastic, .metal, .glass, .electronics],
                openingHours: "08:00-20:00",
                contactInfo: "2525 1234",
                capacity: 1000,
                currentLoad: 350
            ),
            RecyclingStation(
                name: "銅鑼灣回收站",
                district: "灣仔區",
                address: "香港銅鑼灣軒尼詩道500號",
                latitude: 22.2783,
                longitude: 114.1828,
                acceptedMaterials: [.paper, .plastic, .metal, .glass, .batteries, .clothing],
                openingHours: "09:00-21:00",
                contactInfo: "2570 5678",
                capacity: 800,
                currentLoad: 620
            ),
            RecyclingStation(
                name: "尖沙咀回收站",
                district: "油尖旺區",
                address: "香港尖沙咀彌敦道100號",
                latitude: 22.2974,
                longitude: 114.1721,
                acceptedMaterials: [.paper, .plastic, .metal, .glass, .electronics, .organic],
                openingHours: "08:00-19:00",
                contactInfo: "2368 9012",
                capacity: 1200,
                currentLoad: 890
            )
        ]
        
        // 模拟绿色建筑
        self.greenBuildings = [
            GreenBuilding(
                name: "國際金融中心",
                district: "中西區",
                address: "香港中環金融街8號",
                latitude: 22.2847,
                longitude: 114.1592,
                certification: .platinum,
                energyRating: "A+",
                waterEfficiency: "優秀",
                wasteManagement: "優秀",
                greenFeatures: ["太陽能板", "雨水收集", "LED照明", "智能空調系統"],
                carbonFootprint: 1250.5,
                lastAssessment: "2024-09-15"
            ),
            GreenBuilding(
                name: "時代廣場",
                district: "灣仔區",
                address: "香港銅鑼灣勿地臣街1號",
                latitude: 22.2783,
                longitude: 114.1828,
                certification: .gold,
                energyRating: "A",
                waterEfficiency: "良好",
                wasteManagement: "良好",
                greenFeatures: ["太陽能板", "LED照明", "智能電梯"],
                carbonFootprint: 1850.2,
                lastAssessment: "2024-08-20"
            ),
            GreenBuilding(
                name: "海港城",
                district: "油尖旺區",
                address: "香港尖沙咀廣東道3-27號",
                latitude: 22.2974,
                longitude: 114.1721,
                certification: .silver,
                energyRating: "B+",
                waterEfficiency: "良好",
                wasteManagement: "良好",
                greenFeatures: ["LED照明", "智能空調", "雨水收集"],
                carbonFootprint: 2100.8,
                lastAssessment: "2024-07-10"
            )
        ]
        
        self.lastUpdateTime = Date()
    }
    
    // MARK: - 刷新数据
    func refreshData() {
        loadAllData()
    }
    
    // MARK: - 根据位置获取附近设施
    func getNearbyFacilities(for location: CLLocation, radius: Double = 1000) -> [EcoFacility] {
        return ecoFacilities.filter { facility in
            facility.location.distance(from: location) <= radius
        }.sorted { facility1, facility2 in
            facility1.location.distance(from: location) < facility2.location.distance(from: location)
        }
    }
    
    // MARK: - 根据位置获取附近回收站
    func getNearbyRecyclingStations(for location: CLLocation, radius: Double = 1000) -> [RecyclingStation] {
        return recyclingStations.filter { station in
            station.location.distance(from: location) <= radius
        }.sorted { station1, station2 in
            station1.location.distance(from: location) < station2.location.distance(from: location)
        }
    }
    
    // MARK: - 根据材料类型筛选回收站
    func getRecyclingStations(for material: RecyclingStation.RecyclableMaterial) -> [RecyclingStation] {
        return recyclingStations.filter { station in
            station.acceptedMaterials.contains(material)
        }
    }
    
    // MARK: - 获取环保建议
    func getEcoRecommendations() -> [EcoRecommendation] {
        var recommendations: [EcoRecommendation] = []
        
        // 基于空气质量建议
        if let airQuality = airQualityData {
            if airQuality.aqhi > 6 {
                recommendations.append(EcoRecommendation(
                    title: "空氣質素警告",
                    description: "空氣質素指數較高，建議減少戶外活動",
                    priority: .high,
                    category: .airQuality
                ))
            }
        }
        
        // 基于天气建议
        if let weather = weatherData {
            if weather.temperature > 30 {
                recommendations.append(EcoRecommendation(
                    title: "節能建議",
                    description: "天氣炎熱，建議合理使用冷氣，設定溫度不低於26°C",
                    priority: .medium,
                    category: .energy
                ))
            }
        }
        
        return recommendations
    }
}

// MARK: - 环保建议
struct EcoRecommendation: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let priority: Priority
    let category: Category
    
    enum Priority: String, CaseIterable, Codable {
        case high = "高"
        case medium = "中"
        case low = "低"
    }
    
    enum Category: String, CaseIterable, Codable {
        case airQuality = "空氣質素"
        case energy = "能源"
        case waste = "廢物"
        case water = "水資源"
        case transportation = "交通"
        case general = "一般"
    }
}

// MARK: - 碳足迹计算服务
class CarbonFootprintCalculator {
    static let shared = CarbonFootprintCalculator()
    
    private init() {}
    
    // MARK: - 交通排放计算
    func calculateTransportationEmission(distance: Double, transportType: TransportType) -> Double {
        let emissionFactors: [TransportType: Double] = [
            .walking: 0.0,
            .cycling: 0.0,
            .bus: 0.1,
            .mtr: 0.08,
            .taxi: 0.25,
            .privateCar: 0.2,
            .motorcycle: 0.15
        ]
        
        return distance * (emissionFactors[transportType] ?? 0.0)
    }
    
    // MARK: - 能源排放计算
    func calculateEnergyEmission(electricityUsage: Double, gasUsage: Double, waterUsage: Double) -> Double {
        // 香港特定排放系数
        let electricityFactor = 0.7 // kg CO2/kWh
        let gasFactor = 1.9 // kg CO2/m³
        let waterFactor = 0.3 // kg CO2/m³
        
        return (electricityUsage * electricityFactor) + (gasUsage * gasFactor) + (waterUsage * waterFactor)
    }
    
    // MARK: - 食物排放计算
    func calculateFoodEmission(foodItems: [FoodItem]) -> Double {
        var totalEmission = 0.0
        
        for item in foodItems {
            let emissionFactor = getFoodEmissionFactor(for: item.category)
            totalEmission += item.weight * emissionFactor
        }
        
        return totalEmission
    }
    
    private func getFoodEmissionFactor(for category: FoodCategory) -> Double {
        switch category {
        case .meat: return 27.0
        case .dairy: return 3.2
        case .vegetables: return 2.0
        case .fruits: return 1.5
        case .grains: return 1.8
        case .processed: return 3.5
        }
    }
}

// MARK: - 交通类型枚举
enum TransportType: String, CaseIterable, Codable {
    case walking = "步行"
    case cycling = "骑自行车"
    case bus = "巴士"
    case mtr = "地铁"
    case taxi = "的士"
    case privateCar = "私家车"
    case motorcycle = "摩托车"
}

// MARK: - 食物项目
struct FoodItem: Codable {
    let name: String
    let weight: Double // kg
    let category: FoodCategory
}

enum FoodCategory: String, CaseIterable, Codable {
    case meat = "肉类"
    case dairy = "乳制品"
    case vegetables = "蔬菜"
    case fruits = "水果"
    case grains = "谷物"
    case processed = "加工食品"
}
