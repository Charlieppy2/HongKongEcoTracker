import Foundation
import Combine

// MARK: - 环保署API服务
class EnvironmentalProtectionDepartmentAPI {
    static let shared = EnvironmentalProtectionDepartmentAPI()
    private let baseURL = "https://data.weather.gov.hk/weatherAPI/opendata/"
    
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

// MARK: - 环保挑战服务
class EcoChallengeService: ObservableObject {
    @Published var challenges: [EcoChallenge] = []
    @Published var userProfile: UserEcoProfile?
    
    init() {
        loadDefaultChallenges()
    }
    
    private func loadDefaultChallenges() {
        challenges = [
            EcoChallenge(
                title: "一周无车日",
                description: "连续7天使用公共交通或步行出行",
                category: .transportation,
                points: 100,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "节能达人",
                description: "一周内减少20%的电力使用",
                category: .energy,
                points: 80,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "素食挑战",
                description: "连续3天选择素食",
                category: .food,
                points: 60,
                duration: 3,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "零废生活",
                description: "一周内减少50%的废物产生",
                category: .waste,
                points: 120,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            )
        ]
    }
    
    func startChallenge(_ challenge: EcoChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = EcoChallenge(
                title: challenge.title,
                description: challenge.description,
                category: challenge.category,
                points: challenge.points,
                duration: challenge.duration,
                isCompleted: false,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: challenge.duration, to: Date())
            )
        }
    }
    
    func completeChallenge(_ challenge: EcoChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = EcoChallenge(
                title: challenge.title,
                description: challenge.description,
                category: challenge.category,
                points: challenge.points,
                duration: challenge.duration,
                isCompleted: true,
                startDate: challenge.startDate,
                endDate: challenge.endDate
            )
            
            // 更新用户积分
            updateUserPoints(challenge.points)
        }
    }
    
    private func updateUserPoints(_ points: Int) {
        // 这里应该更新用户档案的积分
        // 实际实现中需要与后端API交互
    }
}
