import Foundation
import Combine

// MARK: - 数据管理器
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var carbonFootprints: [CarbonFootprint] = []
    @Published var userProfile: UserEcoProfile?
    @Published var challenges: [EcoChallenge] = []
    
    private let userDefaults = UserDefaults.standard
    private let carbonFootprintKey = "carbonFootprints"
    private let userProfileKey = "userProfile"
    private let challengesKey = "challenges"
    
    private init() {
        loadData()
        generateSampleData()
    }
    
    // MARK: - 数据加载
    private func loadData() {
        loadCarbonFootprints()
        loadUserProfile()
        loadChallenges()
    }
    
    private func loadCarbonFootprints() {
        if let data = userDefaults.data(forKey: carbonFootprintKey),
           let footprints = try? JSONDecoder().decode([CarbonFootprint].self, from: data) {
            self.carbonFootprints = footprints
        }
    }
    
    private func loadUserProfile() {
        if let data = userDefaults.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserEcoProfile.self, from: data) {
            self.userProfile = profile
        }
    }
    
    private func loadChallenges() {
        if let data = userDefaults.data(forKey: challengesKey),
           let challenges = try? JSONDecoder().decode([EcoChallenge].self, from: data) {
            self.challenges = challenges
        }
    }
    
    // MARK: - 数据保存
    private func saveCarbonFootprints() {
        if let data = try? JSONEncoder().encode(carbonFootprints) {
            userDefaults.set(data, forKey: carbonFootprintKey)
        }
    }
    
    private func saveUserProfile() {
        if let profile = userProfile,
           let data = try? JSONEncoder().encode(profile) {
            userDefaults.set(data, forKey: userProfileKey)
        }
    }
    
    private func saveChallenges() {
        if let data = try? JSONEncoder().encode(challenges) {
            userDefaults.set(data, forKey: challengesKey)
        }
    }
    
    // MARK: - 公共方法
    func addCarbonFootprint(_ footprint: CarbonFootprint) {
        carbonFootprints.append(footprint)
        saveCarbonFootprints()
        updateUserProfile()
    }
    
    func updateUserProfile() {
        let totalPoints = challenges.filter { $0.isCompleted }.reduce(0) { $0 + $1.points }
        let weeklyEmission = carbonFootprints.suffix(7).reduce(0) { $0 + $1.totalEmission }
        let monthlyEmission = carbonFootprints.suffix(30).reduce(0) { $0 + $1.totalEmission }
        let yearlyEmission = carbonFootprints.reduce(0) { $0 + $1.totalEmission }
        
        let level = min(totalPoints / 100 + 1, 20)
        
        userProfile = UserEcoProfile(
            userId: "user_123",
            username: "Eco Master",
            totalPoints: totalPoints,
            level: level,
            badges: generateBadges(),
            weeklyEmission: weeklyEmission,
            monthlyEmission: monthlyEmission,
            yearlyEmission: yearlyEmission,
            joinDate: Date()
        )
        
        saveUserProfile()
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
            saveChallenges()
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
            saveChallenges()
            updateUserProfile()
        }
    }
    
    // MARK: - 样本数据生成
    private func generateSampleData() {
        if carbonFootprints.isEmpty {
            generateSampleFootprints()
        }
        
        if userProfile == nil {
            updateUserProfile()
        }
        
        if challenges.isEmpty {
            generateSampleChallenges()
        }
    }
    
    private func generateSampleFootprints() {
        let sampleFootprints = [
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 2.0, publicTransport: 8.0),
                energy: EnergyEmission(electricityUsage: 12.0, gasUsage: 1.5),
                food: FoodEmission(meatConsumption: 0.2, vegetablesConsumption: 0.6),
                waste: WasteEmission(plasticWaste: 0.1, organicWaste: 0.7)
            ),
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 1.5, publicTransport: 10.0),
                energy: EnergyEmission(electricityUsage: 14.0, gasUsage: 2.0),
                food: FoodEmission(meatConsumption: 0.3, vegetablesConsumption: 0.5),
                waste: WasteEmission(plasticWaste: 0.2, organicWaste: 0.8)
            ),
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 3.0, publicTransport: 6.0),
                energy: EnergyEmission(electricityUsage: 11.0, gasUsage: 1.8),
                food: FoodEmission(meatConsumption: 0.1, vegetablesConsumption: 0.8),
                waste: WasteEmission(plasticWaste: 0.15, organicWaste: 0.6)
            ),
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 2.5, publicTransport: 9.0),
                energy: EnergyEmission(electricityUsage: 13.0, gasUsage: 1.7),
                food: FoodEmission(meatConsumption: 0.25, vegetablesConsumption: 0.7),
                waste: WasteEmission(plasticWaste: 0.18, organicWaste: 0.75)
            ),
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 1.8, publicTransport: 12.0),
                energy: EnergyEmission(electricityUsage: 15.0, gasUsage: 2.2),
                food: FoodEmission(meatConsumption: 0.4, vegetablesConsumption: 0.4),
                waste: WasteEmission(plasticWaste: 0.25, organicWaste: 0.9)
            ),
            CarbonFootprint(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                transportation: TransportationEmission(walking: 2.2, publicTransport: 7.0),
                energy: EnergyEmission(electricityUsage: 10.0, gasUsage: 1.6),
                food: FoodEmission(meatConsumption: 0.15, vegetablesConsumption: 0.9),
                waste: WasteEmission(plasticWaste: 0.12, organicWaste: 0.65)
            ),
            CarbonFootprint(
                date: Date(),
                transportation: TransportationEmission(walking: 2.0, publicTransport: 10.0),
                energy: EnergyEmission(electricityUsage: 15.0, gasUsage: 2.0),
                food: FoodEmission(meatConsumption: 0.3, vegetablesConsumption: 0.5),
                waste: WasteEmission(plasticWaste: 0.2, organicWaste: 0.8)
            )
        ]
        
        carbonFootprints = sampleFootprints
        saveCarbonFootprints()
    }
    
    private func generateSampleChallenges() {
        challenges = [
            EcoChallenge(
                title: "Car-Free Week",
                description: "Use public transport or walk for 7 consecutive days",
                category: .transportation,
                points: 100,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "Energy Saver",
                description: "Reduce electricity usage by 20% for one week",
                category: .energy,
                points: 80,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "Vegetarian Challenge",
                description: "Choose vegetarian meals for 3 consecutive days",
                category: .food,
                points: 60,
                duration: 3,
                isCompleted: true,
                startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                endDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())
            ),
            EcoChallenge(
                title: "Zero Waste Life",
                description: "Reduce waste production by 50% for one week",
                category: .waste,
                points: 120,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "Green Commute",
                description: "Cycle or walk to work for 5 consecutive days",
                category: .transportation,
                points: 90,
                duration: 5,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            ),
            EcoChallenge(
                title: "Eco Shopping",
                description: "Only buy eco-friendly packaged products for one week",
                category: .lifestyle,
                points: 70,
                duration: 7,
                isCompleted: false,
                startDate: nil,
                endDate: nil
            )
        ]
        
        saveChallenges()
    }
    
    private func generateBadges() -> [EcoBadge] {
        var badges: [EcoBadge] = []
        
        if challenges.contains(where: { $0.category == .transportation && $0.isCompleted }) {
            badges.append(EcoBadge(
                name: "Transport Master",
                description: "Completed transportation challenges",
                iconName: "car.fill",
                earnedDate: Date(),
                category: .transportation
            ))
        }
        
        if challenges.contains(where: { $0.category == .energy && $0.isCompleted }) {
            badges.append(EcoBadge(
                name: "Energy Expert",
                description: "Completed energy challenges",
                iconName: "bolt.fill",
                earnedDate: Date(),
                category: .energy
            ))
        }
        
        if challenges.contains(where: { $0.category == .food && $0.isCompleted }) {
            badges.append(EcoBadge(
                name: "Vegetarian Pioneer",
                description: "Completed food challenges",
                iconName: "fork.knife",
                earnedDate: Date(),
                category: .food
            ))
        }
        
        return badges
    }
    
    // MARK: - 数据查询
    func getTodayFootprint() -> CarbonFootprint {
        let today = Calendar.current.startOfDay(for: Date())
        return carbonFootprints.first { Calendar.current.isDate($0.date, inSameDayAs: today) } ?? CarbonFootprint(
            transportation: TransportationEmission(),
            energy: EnergyEmission(),
            food: FoodEmission(),
            waste: WasteEmission()
        )
    }
    
    func getWeeklyData() -> [CarbonFootprint] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        return carbonFootprints.filter { footprint in
            footprint.date >= weekAgo && footprint.date <= today
        }.sorted { $0.date < $1.date }
    }
    
    func getMonthlyData() -> [CarbonFootprint] {
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        
        return carbonFootprints.filter { footprint in
            footprint.date >= monthAgo && footprint.date <= today
        }.sorted { $0.date < $1.date }
    }
}
