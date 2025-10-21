import Foundation
import CoreLocation

// MARK: - 碳足迹数据模型
struct CarbonFootprint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let transportation: TransportationEmission
    let energy: EnergyEmission
    let food: FoodEmission
    let waste: WasteEmission
    let totalEmission: Double
    
    init(date: Date = Date(), transportation: TransportationEmission, energy: EnergyEmission, food: FoodEmission, waste: WasteEmission) {
        self.date = date
        self.transportation = transportation
        self.energy = energy
        self.food = food
        self.waste = waste
        self.totalEmission = transportation.emission + energy.emission + food.emission + waste.emission
    }
}

// MARK: - 交通排放
struct TransportationEmission: Codable {
    let walking: Double
    let cycling: Double
    let publicTransport: Double
    let privateVehicle: Double
    let emission: Double
    
    init(walking: Double = 0, cycling: Double = 0, publicTransport: Double = 0, privateVehicle: Double = 0) {
        self.walking = walking
        self.cycling = cycling
        self.publicTransport = publicTransport
        self.privateVehicle = privateVehicle
        
        // 计算总排放量 (kg CO2)
        self.emission = (walking * 0) + (cycling * 0) + (publicTransport * 0.1) + (privateVehicle * 0.2)
    }
}

// MARK: - 能源排放
struct EnergyEmission: Codable {
    let electricityUsage: Double // kWh
    let gasUsage: Double // m³
    let waterUsage: Double // m³
    let emission: Double
    
    init(electricityUsage: Double = 0, gasUsage: Double = 0, waterUsage: Double = 0) {
        self.electricityUsage = electricityUsage
        self.gasUsage = gasUsage
        self.waterUsage = waterUsage
        
        // 香港电力排放系数: 0.7 kg CO2/kWh
        self.emission = (electricityUsage * 0.7) + (gasUsage * 1.9) + (waterUsage * 0.3)
    }
}

// MARK: - 食物排放
struct FoodEmission: Codable {
    let meatConsumption: Double // kg
    let dairyConsumption: Double // kg
    let vegetablesConsumption: Double // kg
    let processedFood: Double // kg
    let emission: Double
    
    init(meatConsumption: Double = 0, dairyConsumption: Double = 0, vegetablesConsumption: Double = 0, processedFood: Double = 0) {
        self.meatConsumption = meatConsumption
        self.dairyConsumption = dairyConsumption
        self.vegetablesConsumption = vegetablesConsumption
        self.processedFood = processedFood
        
        // 食物排放系数 (kg CO2/kg)
        self.emission = (meatConsumption * 27) + (dairyConsumption * 3.2) + (vegetablesConsumption * 2) + (processedFood * 3.5)
    }
}

// MARK: - 废物排放
struct WasteEmission: Codable {
    let plasticWaste: Double // kg
    let paperWaste: Double // kg
    let organicWaste: Double // kg
    let electronicWaste: Double // kg
    let emission: Double
    
    init(plasticWaste: Double = 0, paperWaste: Double = 0, organicWaste: Double = 0, electronicWaste: Double = 0) {
        self.plasticWaste = plasticWaste
        self.paperWaste = paperWaste
        self.organicWaste = organicWaste
        self.electronicWaste = electronicWaste
        
        // 废物排放系数 (kg CO2/kg)
        self.emission = (plasticWaste * 6) + (paperWaste * 1.3) + (organicWaste * 0.5) + (electronicWaste * 12)
    }
}

// MARK: - 环保挑战
struct EcoChallenge: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: ChallengeCategory
    let points: Int
    let duration: Int // days
    var isCompleted: Bool
    var startDate: Date?
    var endDate: Date?
    
    enum ChallengeCategory: String, CaseIterable, Codable {
        case transportation = "交通"
        case energy = "能源"
        case food = "食物"
        case waste = "废物"
        case lifestyle = "生活方式"
    }
    
    init(title: String, description: String, category: ChallengeCategory, points: Int, duration: Int, isCompleted: Bool = false, startDate: Date? = nil, endDate: Date? = nil) {
        self.title = title
        self.description = description
        self.category = category
        self.points = points
        self.duration = duration
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - 用户环保档案
struct UserEcoProfile: Codable {
    let userId: String
    let username: String
    let totalPoints: Int
    let level: Int
    let badges: [EcoBadge]
    let weeklyEmission: Double
    let monthlyEmission: Double
    let yearlyEmission: Double
    let joinDate: Date
    
    var levelTitle: String {
        switch level {
        case 1...5: return "环保新手"
        case 6...10: return "环保达人"
        case 11...15: return "环保专家"
        case 16...20: return "环保大师"
        default: return "环保传奇"
        }
    }
}

// MARK: - 环保徽章
struct EcoBadge: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let earnedDate: Date
    let category: EcoChallenge.ChallengeCategory
}

// MARK: - 社区排名
struct CommunityRanking: Codable, Identifiable {
    let id = UUID()
    let userId: String
    let username: String
    let totalPoints: Int
    let weeklyEmission: Double
    let rank: Int
    let district: String
    let avatar: String?
}
