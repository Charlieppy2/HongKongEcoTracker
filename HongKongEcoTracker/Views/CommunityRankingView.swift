import SwiftUI

// MARK: - 社区排名视图
struct CommunityRankingView: View {
    @StateObject private var rankingService = CommunityRankingService()
    @State private var selectedDistrict = "全部"
    
    let districts = ["全部", "中西区", "湾仔区", "东区", "南区", "油尖旺区", "深水埗区", "九龙城区", "黄大仙区", "观塘区", "荃湾区", "屯门区", "元朗区", "北区", "大埔区", "沙田区", "西贡区", "葵青区", "离岛区"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 地区筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(districts, id: \.self) { district in
                            DistrictFilterButton(
                                title: district,
                                isSelected: selectedDistrict == district
                            ) {
                                selectedDistrict = district
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // 排名列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRankings) { ranking in
                            RankingCard(ranking: ranking)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("社区排名")
            .refreshable {
                await rankingService.refreshRankings()
            }
        }
    }
    
    private var filteredRankings: [CommunityRanking] {
        if selectedDistrict == "全部" {
            return rankingService.rankings
        }
        return rankingService.rankings.filter { $0.district == selectedDistrict }
    }
}

// MARK: - 地区筛选按钮
struct DistrictFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color.green.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// MARK: - 排名卡片
struct RankingCard: View {
    let ranking: CommunityRanking
    
    var body: some View {
        HStack(spacing: 16) {
            // 排名
            VStack {
                Text("\(ranking.rank)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
                
                if ranking.rank <= 3 {
                    Image(systemName: rankIcon)
                        .foregroundColor(rankColor)
                        .font(.title3)
                }
            }
            .frame(width: 50)
            
            // 用户头像
            AsyncImage(url: URL(string: ranking.avatar ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // 用户信息
            VStack(alignment: .leading, spacing: 4) {
                Text(ranking.username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(ranking.district)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("\(ranking.weeklyEmission, specifier: "%.1f") kg CO₂/周")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 积分
            VStack(alignment: .trailing) {
                Text("\(ranking.totalPoints)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("积分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var rankColor: Color {
        switch ranking.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .green
        }
    }
    
    private var rankIcon: String {
        switch ranking.rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
}

// MARK: - 社区排名服务
class CommunityRankingService: ObservableObject {
    @Published var rankings: [CommunityRanking] = []
    
    init() {
        generateMockRankings()
    }
    
    func refreshRankings() async {
        // 模拟网络请求延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            generateMockRankings()
        }
    }
    
    private func generateMockRankings() {
        let mockUsers = [
            ("环保达人", "中西区", 1250, 8.5),
            ("绿色生活", "湾仔区", 1180, 9.2),
            ("地球守护者", "东区", 1150, 7.8),
            ("环保先锋", "南区", 1120, 8.9),
            ("绿色战士", "油尖旺区", 1080, 9.5),
            ("环保专家", "深水埗区", 1050, 8.1),
            ("地球朋友", "九龙城区", 1020, 8.7),
            ("绿色天使", "黄大仙区", 980, 9.0),
            ("环保使者", "观塘区", 950, 8.3),
            ("绿色梦想", "荃湾区", 920, 8.6),
            ("环保英雄", "屯门区", 890, 9.1),
            ("绿色希望", "元朗区", 860, 8.4),
            ("环保战士", "北区", 830, 8.8),
            ("绿色未来", "大埔区", 800, 8.2),
            ("环保之星", "沙田区", 770, 8.9),
            ("绿色生活家", "西贡区", 740, 8.5),
            ("环保达人2", "葵青区", 710, 8.7),
            ("绿色守护者", "离岛区", 680, 8.3)
        ]
        
        rankings = mockUsers.enumerated().map { index, user in
            CommunityRanking(
                userId: "user_\(index + 1)",
                username: user.0,
                totalPoints: user.2,
                weeklyEmission: user.3,
                rank: index + 1,
                district: user.1,
                avatar: nil
            )
        }
    }
}

// MARK: - 个人档案视图
struct ProfileView: View {
    @EnvironmentObject var ecoService: EcoChallengeService
    @State private var userProfile: UserEcoProfile?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    UserInfoCard(profile: userProfile)
                    
                    // 成就徽章
                    AchievementsSection(profile: userProfile)
                    
                    // 统计数据
                    StatisticsSection(profile: userProfile)
                    
                    // 环保目标
                    EcoGoalsSection()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("个人档案")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                loadUserProfile()
            }
        }
    }
    
    private func loadUserProfile() {
        // 模拟加载用户档案
        userProfile = UserEcoProfile(
            userId: "user_123",
            username: "环保达人",
            totalPoints: 1250,
            level: 8,
            badges: [
                EcoBadge(name: "交通达人", description: "连续7天使用公共交通", iconName: "car.fill", earnedDate: Date(), category: .transportation),
                EcoBadge(name: "节能专家", description: "减少20%电力使用", iconName: "bolt.fill", earnedDate: Date(), category: .energy),
                EcoBadge(name: "素食先锋", description: "连续3天素食", iconName: "fork.knife", earnedDate: Date(), category: .food)
            ],
            weeklyEmission: 8.5,
            monthlyEmission: 35.2,
            yearlyEmission: 420.8,
            joinDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        )
    }
}

// MARK: - 用户信息卡片
struct UserInfoCard: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(spacing: 16) {
            // 头像和基本信息
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 4) {
                    Text(profile?.username ?? "用户")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(profile?.levelTitle ?? "环保新手")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            // 积分和等级
            HStack(spacing: 30) {
                VStack {
                    Text("\(profile?.totalPoints ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("总积分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("Lv.\(profile?.level ?? 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("等级")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(profile?.joinDate.timeIntervalSinceNow ?? 0, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("加入天数")
                        .font(.caption)
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

// MARK: - 成就徽章部分
struct AchievementsSection: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("成就徽章")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(profile?.badges ?? []) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 徽章卡片
struct BadgeCard: View {
    let badge: EcoBadge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.iconName)
                .font(.title)
                .foregroundColor(.green)
                .frame(width: 50, height: 50)
                .background(Color.green.opacity(0.1))
                .cornerRadius(25)
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

// MARK: - 统计数据部分
struct StatisticsSection: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("环保统计")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatisticRow(title: "本周排放", value: "\(profile?.weeklyEmission ?? 0, specifier: "%.1f") kg CO₂")
                StatisticRow(title: "本月排放", value: "\(profile?.monthlyEmission ?? 0, specifier: "%.1f") kg CO₂")
                StatisticRow(title: "本年排放", value: "\(profile?.yearlyEmission ?? 0, specifier: "%.1f") kg CO₂")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 统计行
struct StatisticRow: View {
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

// MARK: - 环保目标部分
struct EcoGoalsSection: View {
    @State private var weeklyGoal: Double = 15.0
    @State private var monthlyGoal: Double = 60.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("环保目标")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                GoalProgressView(
                    title: "周目标",
                    current: 8.5,
                    target: weeklyGoal,
                    unit: "kg CO₂"
                )
                
                GoalProgressView(
                    title: "月目标",
                    current: 35.2,
                    target: monthlyGoal,
                    unit: "kg CO₂"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 目标进度视图
struct GoalProgressView: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    
    private var progress: Double {
        min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(current, specifier: "%.1f") / \(target, specifier: "%.1f") \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("账户") {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("编辑档案")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("通知设置")
                    }
                }
                
                Section("隐私") {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("隐私设置")
                    }
                    
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("数据分享")
                    }
                }
                
                Section("关于") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("关于应用")
                    }
                    
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                        Text("帮助与支持")
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CommunityRankingView()
}
