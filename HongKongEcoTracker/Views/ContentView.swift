import SwiftUI
import Charts

// MARK: - 主界面
struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 碳足迹概览
            CarbonFootprintOverview()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Home".localized)
                }
                .tag(0)
            
            // 实时数据页面
            RealTimeDataView()
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Live Data".localized)
                }
                .tag(1)
            
            // 挑战页面
            ChallengeView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Challenges".localized)
                }
                .tag(2)
            
            // 社区排名
            CommunityRankingView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community".localized)
                }
                .tag(3)
            
            // 个人档案
            ProfileView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile".localized)
                }
                .tag(4)
        }
        .accentColor(.green)
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            // 语言改变时刷新UI
        }
    }
}

// MARK: - 碳足迹概览
struct CarbonFootprintOverview: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showingAddEntry = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 欢迎横幅
                    WelcomeBanner()
                        .padding(.horizontal)
                    
                    // 今日碳足迹卡片
                    TodayCarbonCard(carbonFootprint: dataManager.getTodayFootprint())
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateCards)
                    
                    // 快速操作按钮
                    QuickActionButtons(showingAddEntry: $showingAddEntry)
                        .padding(.horizontal)
                    
                    // 本周趋势图表
                    WeeklyTrendChart(data: dataManager.getWeeklyData())
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateCards)
                    
                    // 分类排放
                    CategoryBreakdownView(footprint: dataManager.getTodayFootprint())
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
                    
                    // 环保建议
                    EcoTipsView()
                        .padding(.horizontal)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
                }
                .padding(.vertical)
            }
            .navigationTitle("Eco Tracker".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    LanguageToggleButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddCarbonEntryView()
                    .environmentObject(dataManager)
                    .environmentObject(localizationManager)
            }
            .onAppear {
                animateCards = true
            }
        }
    }
}

// MARK: - 欢迎横幅
struct WelcomeBanner: View {
    @State private var currentTime = Date()
    @EnvironmentObject var localizationManager: LocalizationManager
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Let's make Hong Kong greener together! 🌱".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(currentTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                Text("Hong Kong".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12:
            return "Good Morning!".localized
        case 12..<17:
            return "Good Afternoon!".localized
        case 17..<22:
            return "Good Evening!".localized
        default:
            return "Good Night!".localized
        }
    }
}

// MARK: - 快速操作按钮
struct QuickActionButtons: View {
    @Binding var showingAddEntry: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                icon: "plus.circle.fill",
                title: "Add Entry".localized,
                color: .green,
                action: { showingAddEntry = true }
            )
            
            QuickActionButton(
                icon: "chart.bar.fill",
                title: "View Stats".localized,
                color: .blue,
                action: { /* Navigate to stats */ }
            )
            
            QuickActionButton(
                icon: "trophy.fill",
                title: "Challenges".localized,
                color: .orange,
                action: { /* Navigate to challenges */ }
            )
        }
    }
}

struct QuickActionButton: View {
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

// MARK: - 今日碳足迹卡片
struct TodayCarbonCard: View {
    let carbonFootprint: CarbonFootprint
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Carbon Footprint".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Target: 20 kg CO₂ per day".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(carbonFootprint.totalEmission, specifier: "%.1f")")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("kg CO₂")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(progressText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                    
                    Text("vs yesterday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            ProgressView(value: carbonFootprint.totalEmission, total: 20)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var progressText: String {
        let target = 20.0
        let current = carbonFootprint.totalEmission
        
        if current <= target {
            return String(format: "%.1f kg left".localized, target - current)
        } else {
            return String(format: "%.1f kg over".localized, current - target)
        }
    }
    
    private var progressColor: Color {
        let target = 20.0
        let current = carbonFootprint.totalEmission
        
        if current <= target * 0.8 {
            return .green
        } else if current <= target {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - 本周趋势图表
struct WeeklyTrendChart: View {
    let data: [CarbonFootprint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
            }
            
            if data.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Start tracking your carbon footprint to see trends")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
            } else {
                Chart {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, footprint in
                        LineMark(
                            x: .value("Day", index),
                            y: .value("Emission", footprint.totalEmission)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Day", index),
                            y: .value("Emission", footprint.totalEmission)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 分类排放视图
struct CategoryBreakdownView: View {
    let footprint: CarbonFootprint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Category Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 12) {
                CategoryRow(
                    icon: "car.fill",
                    title: "Transportation",
                    emission: footprint.transportation.emission,
                    color: .blue,
                    percentage: footprint.transportation.emission / footprint.totalEmission
                )
                
                CategoryRow(
                    icon: "bolt.fill",
                    title: "Energy",
                    emission: footprint.energy.emission,
                    color: .orange,
                    percentage: footprint.energy.emission / footprint.totalEmission
                )
                
                CategoryRow(
                    icon: "fork.knife",
                    title: "Food",
                    emission: footprint.food.emission,
                    color: .red,
                    percentage: footprint.food.emission / footprint.totalEmission
                )
                
                CategoryRow(
                    icon: "trash.fill",
                    title: "Waste",
                    emission: footprint.waste.emission,
                    color: .brown,
                    percentage: footprint.waste.emission / footprint.totalEmission
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct CategoryRow: View {
    let icon: String
    let title: String
    let emission: Double
    let color: Color
    let percentage: Double
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(emission, specifier: "%.1f") kg")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(percentage * 100, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 环保建议视图
struct EcoTipsView: View {
    let tips = [
        EcoTip(
            icon: "tram.fill",
            title: "Use Public Transport",
            description: "Take MTR or buses to reduce carbon emissions",
            color: .blue
        ),
        EcoTip(
            icon: "leaf.fill",
            title: "Choose Local Food",
            description: "Buy locally grown vegetables to reduce transport emissions",
            color: .green
        ),
        EcoTip(
            icon: "bolt.fill",
            title: "Save Energy",
            description: "Turn off unused appliances and use LED lights",
            color: .orange
        ),
        EcoTip(
            icon: "arrow.3.trianglepath",
            title: "Recycle More",
            description: "Separate waste properly and recycle whenever possible",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Eco Tips")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(tips, id: \.title) { tip in
                    EcoTipCard(tip: tip)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct EcoTip {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct EcoTipCard: View {
    let tip: EcoTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: tip.icon)
                    .foregroundColor(tip.color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(tip.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(tip.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("Add Carbon Entry")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Track your daily activities")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // 交通
                    InputSection(
                        title: "Transportation",
                        icon: "car.fill",
                        color: .blue
                    ) {
                        VStack(spacing: 16) {
                            InputField(
                                title: "Walking Distance",
                                value: $walkingDistance,
                                unit: "km",
                                icon: "figure.walk"
                            )
                            
                            InputField(
                                title: "Public Transport",
                                value: $publicTransportDistance,
                                unit: "km",
                                icon: "tram.fill"
                            )
                            
                            InputField(
                                title: "Private Vehicle",
                                value: $privateVehicleDistance,
                                unit: "km",
                                icon: "car.fill"
                            )
                        }
                    }
                    
                    // 能源
                    InputSection(
                        title: "Energy",
                        icon: "bolt.fill",
                        color: .orange
                    ) {
                        VStack(spacing: 16) {
                            InputField(
                                title: "Electricity Usage",
                                value: $electricityUsage,
                                unit: "kWh",
                                icon: "bolt.fill"
                            )
                            
                            InputField(
                                title: "Gas Usage",
                                value: $gasUsage,
                                unit: "m³",
                                icon: "flame.fill"
                            )
                        }
                    }
                    
                    // 食物
                    InputSection(
                        title: "Food",
                        icon: "fork.knife",
                        color: .red
                    ) {
                        VStack(spacing: 16) {
                            InputField(
                                title: "Meat Consumption",
                                value: $meatConsumption,
                                unit: "kg",
                                icon: "fork.knife"
                            )
                            
                            InputField(
                                title: "Vegetables",
                                value: $vegetablesConsumption,
                                unit: "kg",
                                icon: "leaf.fill"
                            )
                        }
                    }
                    
                    // 废物
                    InputSection(
                        title: "Waste",
                        icon: "trash.fill",
                        color: .brown
                    ) {
                        VStack(spacing: 16) {
                            InputField(
                                title: "Plastic Waste",
                                value: $plasticWaste,
                                unit: "kg",
                                icon: "trash.fill"
                            )
                            
                            InputField(
                                title: "Organic Waste",
                                value: $organicWaste,
                                unit: "kg",
                                icon: "leaf.fill"
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveEntry() {
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

struct InputSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct InputField: View {
    let title: String
    @Binding var value: Double
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack {
                TextField("0", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 40)
            }
        }
    }
}

// MARK: - 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}