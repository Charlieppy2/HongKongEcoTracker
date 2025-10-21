import SwiftUI
import Charts

// MARK: - 主界面
struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 碳足迹概览
            CarbonFootprintOverview()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Carbon Footprint")
                }
                .tag(0)
            
            // 实时数据页面
            RealTimeDataView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Real-time Data")
                }
                .tag(1)
            
            // 挑战页面
            ChallengeView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Challenges")
                }
                .tag(2)
            
            // 社区排名
            CommunityRankingView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(3)
            
            // 个人档案
            ProfileView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

// MARK: - 碳足迹概览
struct CarbonFootprintOverview: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日碳足迹卡片
                    TodayCarbonCard(carbonFootprint: dataManager.getTodayFootprint())
                    
                    // 本周趋势图表
                    WeeklyTrendChart(data: dataManager.getWeeklyData())
                    
                    // 分类排放
                    CategoryBreakdownView(footprint: dataManager.getTodayFootprint())
                    
                    // 环保建议
                    EcoTipsView()
                }
                .padding()
            }
            .navigationTitle("Eco Tracking")
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
                    .environmentObject(dataManager)
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
                
                Text("Today's Carbon Footprint")
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
            
            Text("Target: 20 kg CO₂/day")
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
            Text("Weekly Trend")
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
            Text("Emission Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                CategoryRow(
                    icon: "car.fill",
                    title: "Transportation",
                    emission: footprint.transportation.emission,
                    color: .blue
                )
                
                CategoryRow(
                    icon: "bolt.fill",
                    title: "Energy",
                    emission: footprint.energy.emission,
                    color: .orange
                )
                
                CategoryRow(
                    icon: "fork.knife",
                    title: "Food",
                    emission: footprint.food.emission,
                    color: .red
                )
                
                CategoryRow(
                    icon: "trash.fill",
                    title: "Waste",
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
        "Use public transport to reduce carbon emissions",
        "Choose local ingredients to reduce transport emissions",
        "Turn off unused appliances to save energy",
        "Recycle to reduce waste emissions"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eco Tips")
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
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var walkingDistance: Double = 0
    @State private var publicTransportDistance: Double = 0
    @State private var privateVehicleDistance: Double = 0
    @State private var electricityUsage: Double = 0
    @State private var gasUsage: Double = 0
    @State private var meatConsumption: Double = 0
    @State private var vegetablesConsumption: Double = 0
    @State private var plasticWaste: Double = 0
    @State private var organicWaste: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transportation") {
                    HStack {
                        Text("Walking Distance (km)")
                        Spacer()
                        TextField("0", value: $walkingDistance, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Public Transport (km)")
                        Spacer()
                        TextField("0", value: $publicTransportDistance, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Private Vehicle (km)")
                        Spacer()
                        TextField("0", value: $privateVehicleDistance, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("Energy") {
                    HStack {
                        Text("Electricity Usage (kWh)")
                        Spacer()
                        TextField("0", value: $electricityUsage, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Gas Usage (m³)")
                        Spacer()
                        TextField("0", value: $gasUsage, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("Food") {
                    HStack {
                        Text("Meat Consumption (kg)")
                        Spacer()
                        TextField("0", value: $meatConsumption, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Vegetables Consumption (kg)")
                        Spacer()
                        TextField("0", value: $vegetablesConsumption, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("Waste") {
                    HStack {
                        Text("Plastic Waste (kg)")
                        Spacer()
                        TextField("0", value: $plasticWaste, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Organic Waste (kg)")
                        Spacer()
                        TextField("0", value: $organicWaste, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("Add Carbon Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let transportation = TransportationEmission(
                            walking: walkingDistance,
                            publicTransport: publicTransportDistance,
                            privateVehicle: privateVehicleDistance
                        )
                        let energy = EnergyEmission(
                            electricityUsage: electricityUsage,
                            gasUsage: gasUsage
                        )
                        let food = FoodEmission(
                            meatConsumption: meatConsumption,
                            vegetablesConsumption: vegetablesConsumption
                        )
                        let waste = WasteEmission(
                            plasticWaste: plasticWaste,
                            organicWaste: organicWaste
                        )
                        
                        let footprint = CarbonFootprint(
                            transportation: transportation,
                            energy: energy,
                            food: food,
                            waste: waste
                        )
                        dataManager.addCarbonFootprint(footprint)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}