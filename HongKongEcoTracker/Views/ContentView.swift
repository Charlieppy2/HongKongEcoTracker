import SwiftUI
import Charts

// MARK: - 主界面
struct ContentView: View {
    @StateObject private var ecoService = EcoChallengeService()
    @StateObject private var carbonTracker = CarbonFootprintTracker()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 碳足迹概览
            CarbonFootprintOverview()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("碳足迹")
                }
                .tag(0)
            
            // 挑战页面
            ChallengeView()
                .environmentObject(ecoService)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("挑战")
                }
                .tag(1)
            
            // 社区排名
            CommunityRankingView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("社区")
                }
                .tag(2)
            
            // 个人档案
            ProfileView()
                .environmentObject(ecoService)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("档案")
                }
                .tag(3)
        }
        .accentColor(.green)
    }
}

// MARK: - 碳足迹概览
struct CarbonFootprintOverview: View {
    @StateObject private var tracker = CarbonFootprintTracker()
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日碳足迹卡片
                    TodayCarbonCard(carbonFootprint: tracker.todayFootprint)
                    
                    // 本周趋势图表
                    WeeklyTrendChart(data: tracker.weeklyData)
                    
                    // 分类排放
                    CategoryBreakdownView(footprint: tracker.todayFootprint)
                    
                    // 环保建议
                    EcoTipsView()
                }
                .padding()
            }
            .navigationTitle("环保追踪")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddCarbonEntryView()
                    .environmentObject(tracker)
            }
        }
    }
}

// MARK: - 今日碳足迹卡片
struct TodayCarbonCard: View {
    let carbonFootprint: CarbonFootprint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("今日碳足迹")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(carbonFootprint.totalEmission, specifier: "%.1f") kg CO₂")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // 进度条
            ProgressView(value: carbonFootprint.totalEmission, total: 20.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
            
            Text("目标: 20 kg CO₂/天")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 本周趋势图表
struct WeeklyTrendChart: View {
    let data: [CarbonFootprint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周趋势")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(data.enumerated().map { index, footprint in
                ChartData(
                    day: Calendar.current.shortWeekdaySymbols[index],
                    emission: footprint.totalEmission
                )
            }, id: \.day) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Emission", item.emission)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Emission", item.emission)
                )
                .foregroundStyle(.green.opacity(0.2))
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ChartData {
    let day: String
    let emission: Double
}

// MARK: - 分类排放视图
struct CategoryBreakdownView: View {
    let footprint: CarbonFootprint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("排放分类")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                CategoryRow(
                    icon: "car.fill",
                    title: "交通",
                    emission: footprint.transportation.emission,
                    color: .blue
                )
                
                CategoryRow(
                    icon: "bolt.fill",
                    title: "能源",
                    emission: footprint.energy.emission,
                    color: .orange
                )
                
                CategoryRow(
                    icon: "fork.knife",
                    title: "食物",
                    emission: footprint.food.emission,
                    color: .red
                )
                
                CategoryRow(
                    icon: "trash.fill",
                    title: "废物",
                    emission: footprint.waste.emission,
                    color: .brown
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CategoryRow: View {
    let icon: String
    let title: String
    let emission: Double
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(emission, specifier: "%.1f") kg")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 环保建议视图
struct EcoTipsView: View {
    let tips = [
        "使用公共交通可以减少碳排放",
        "选择本地食材减少运输排放",
        "关闭不使用的电器节省能源",
        "回收利用减少废物排放"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("环保建议")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 添加碳足迹条目视图
struct AddCarbonEntryView: View {
    @EnvironmentObject var tracker: CarbonFootprintTracker
    @Environment(\.dismiss) var dismiss
    
    @State private var transportation = TransportationEmission()
    @State private var energy = EnergyEmission()
    @State private var food = FoodEmission()
    @State private var waste = WasteEmission()
    
    var body: some View {
        NavigationView {
            Form {
                Section("交通") {
                    HStack {
                        Text("步行距离 (km)")
                        Spacer()
                        TextField("0", value: $transportation.walking, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("公共交通 (km)")
                        Spacer()
                        TextField("0", value: $transportation.publicTransport, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("私家车 (km)")
                        Spacer()
                        TextField("0", value: $transportation.privateVehicle, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("能源") {
                    HStack {
                        Text("电力使用 (kWh)")
                        Spacer()
                        TextField("0", value: $energy.electricityUsage, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("燃气使用 (m³)")
                        Spacer()
                        TextField("0", value: $energy.gasUsage, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("食物") {
                    HStack {
                        Text("肉类 (kg)")
                        Spacer()
                        TextField("0", value: $food.meatConsumption, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("蔬菜 (kg)")
                        Spacer()
                        TextField("0", value: $food.vegetablesConsumption, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("废物") {
                    HStack {
                        Text("塑料废物 (kg)")
                        Spacer()
                        TextField("0", value: $waste.plasticWaste, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("有机废物 (kg)")
                        Spacer()
                        TextField("0", value: $waste.organicWaste, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("添加碳足迹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let footprint = CarbonFootprint(
                            transportation: transportation,
                            energy: energy,
                            food: food,
                            waste: waste
                        )
                        tracker.addFootprint(footprint)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 碳足迹追踪器
class CarbonFootprintTracker: ObservableObject {
    @Published var todayFootprint: CarbonFootprint
    @Published var weeklyData: [CarbonFootprint] = []
    
    init() {
        // 初始化今日数据
        self.todayFootprint = CarbonFootprint(
            transportation: TransportationEmission(walking: 2.0, publicTransport: 10.0),
            energy: EnergyEmission(electricityUsage: 15.0, gasUsage: 2.0),
            food: FoodEmission(meatConsumption: 0.3, vegetablesConsumption: 0.5),
            waste: WasteEmission(plasticWaste: 0.2, organicWaste: 0.8)
        )
        
        // 生成模拟的周数据
        generateWeeklyData()
    }
    
    func addFootprint(_ footprint: CarbonFootprint) {
        todayFootprint = footprint
        // 在实际应用中，这里应该保存到数据库
    }
    
    private func generateWeeklyData() {
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let footprint = CarbonFootprint(
                date: date,
                transportation: TransportationEmission(
                    walking: Double.random(in: 1...3),
                    publicTransport: Double.random(in: 8...15)
                ),
                energy: EnergyEmission(
                    electricityUsage: Double.random(in: 10...20),
                    gasUsage: Double.random(in: 1...3)
                ),
                food: FoodEmission(
                    meatConsumption: Double.random(in: 0.2...0.5),
                    vegetablesConsumption: Double.random(in: 0.3...0.8)
                ),
                waste: WasteEmission(
                    plasticWaste: Double.random(in: 0.1...0.3),
                    organicWaste: Double.random(in: 0.5...1.0)
                )
            )
            weeklyData.append(footprint)
        }
        weeklyData.reverse()
    }
}

#Preview {
    ContentView()
}
