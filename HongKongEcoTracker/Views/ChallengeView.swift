import SwiftUI

// MARK: - 挑战页面
struct ChallengeView: View {
    @EnvironmentObject var ecoService: EcoChallengeService
    @State private var selectedCategory: EcoChallenge.ChallengeCategory?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分类筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            title: "全部",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(EcoChallenge.ChallengeCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // 挑战列表
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredChallenges) { challenge in
                            ChallengeCard(challenge: challenge)
                                .environmentObject(ecoService)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("环保挑战")
        }
    }
    
    private var filteredChallenges: [EcoChallenge] {
        if let category = selectedCategory {
            return ecoService.challenges.filter { $0.category == category }
        }
        return ecoService.challenges
    }
}

// MARK: - 分类筛选按钮
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.green.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - 挑战卡片
struct ChallengeCard: View {
    let challenge: EcoChallenge
    @EnvironmentObject var ecoService: EcoChallengeService
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 分类图标
                CategoryIcon(category: challenge.category)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // 积分显示
                VStack {
                    Text("\(challenge.points)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("积分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条（如果挑战已开始）
            if let startDate = challenge.startDate, let endDate = challenge.endDate {
                ChallengeProgressView(
                    startDate: startDate,
                    endDate: endDate,
                    isCompleted: challenge.isCompleted
                )
            }
            
            // 操作按钮
            HStack {
                if challenge.isCompleted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("已完成")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                } else if challenge.startDate != nil {
                    Button("查看进度") {
                        showingDetail = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    Button("开始挑战") {
                        ecoService.startChallenge(challenge)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                Spacer()
                
                Button("详情") {
                    showingDetail = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingDetail) {
            ChallengeDetailView(challenge: challenge)
                .environmentObject(ecoService)
        }
    }
}

// MARK: - 分类图标
struct CategoryIcon: View {
    let category: EcoChallenge.ChallengeCategory
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(iconColor)
            .frame(width: 40, height: 40)
            .background(iconColor.opacity(0.1))
            .cornerRadius(8)
    }
    
    private var iconName: String {
        switch category {
        case .transportation: return "car.fill"
        case .energy: return "bolt.fill"
        case .food: return "fork.knife"
        case .waste: return "trash.fill"
        case .lifestyle: return "heart.fill"
        }
    }
    
    private var iconColor: Color {
        switch category {
        case .transportation: return .blue
        case .energy: return .orange
        case .food: return .red
        case .waste: return .brown
        case .lifestyle: return .pink
        }
    }
}

// MARK: - 挑战进度视图
struct ChallengeProgressView: View {
    let startDate: Date
    let endDate: Date
    let isCompleted: Bool
    
    private var progress: Double {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / totalDuration, 0), 1)
    }
    
    private var remainingDays: Int {
        let remaining = endDate.timeIntervalSince(Date())
        return max(Int(remaining / 86400), 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isCompleted ? "挑战完成" : "进行中")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted ? .green : .blue)
                
                Spacer()
                
                if !isCompleted {
                    Text("剩余 \(remainingDays) 天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? .green : .blue))
        }
    }
}

// MARK: - 挑战详情视图
struct ChallengeDetailView: View {
    let challenge: EcoChallenge
    @EnvironmentObject var ecoService: EcoChallengeService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 挑战信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            CategoryIcon(category: challenge.category)
                            
                            VStack(alignment: .leading) {
                                Text(challenge.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(challenge.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text(challenge.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // 挑战详情
                    VStack(alignment: .leading, spacing: 12) {
                        Text("挑战详情")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DetailRow(title: "积分奖励", value: "\(challenge.points) 积分")
                        DetailRow(title: "挑战时长", value: "\(challenge.duration) 天")
                        
                        if let startDate = challenge.startDate {
                            DetailRow(title: "开始时间", value: DateFormatter.shortDate.string(from: startDate))
                        }
                        
                        if let endDate = challenge.endDate {
                            DetailRow(title: "结束时间", value: DateFormatter.shortDate.string(from: endDate))
                        }
                        
                        DetailRow(title: "状态", value: challenge.isCompleted ? "已完成" : "进行中")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // 环保建议
                    EcoTipsSection(category: challenge.category)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("挑战详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 详情行
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 环保建议部分
struct EcoTipsSection: View {
    let category: EcoChallenge.ChallengeCategory
    
    private var tips: [String] {
        switch category {
        case .transportation:
            return [
                "选择步行或骑自行车短途出行",
                "使用公共交通代替私家车",
                "拼车减少单人出行",
                "选择电动车或混合动力车"
            ]
        case .energy:
            return [
                "关闭不使用的电器",
                "使用LED节能灯泡",
                "调节空调温度到26°C",
                "选择节能家电"
            ]
        case .food:
            return [
                "选择本地和季节性食材",
                "减少肉类消费",
                "避免食物浪费",
                "选择有机食品"
            ]
        case .waste:
            return [
                "减少使用一次性用品",
                "分类回收废物",
                "选择可重复使用的产品",
                "购买包装较少的商品"
            ]
        case .lifestyle:
            return [
                "选择环保的生活方式",
                "支持环保品牌",
                "参与环保活动",
                "教育他人环保知识"
            ]
        }
    }
    
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

// MARK: - 日期格式化器扩展
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    ChallengeView()
        .environmentObject(EcoChallengeService())
}
