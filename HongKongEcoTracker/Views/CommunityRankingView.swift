import SwiftUI

// MARK: - Community Ranking View
struct CommunityRankingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDistrict = "All Districts"
    
    let districts = ["All Districts", "Central & Western", "Wan Chai", "Eastern", "Southern", "Yau Tsim Mong", "Sham Shui Po", "Kowloon City", "Wong Tai Sin", "Kwun Tong", "Tsuen Wan", "Tuen Mun", "Yuen Long", "North", "Tai Po", "Sha Tin", "Sai Kung", "Kwai Tsing", "Islands"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // District filter
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
                
                // Ranking list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRankings) { ranking in
                            RankingCard(ranking: ranking)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Community Ranking")
            .refreshable {
                await rankingService.refreshRankings()
            }
        }
    }
    
    private var filteredRankings: [CommunityRanking] {
        if selectedDistrict == "All Districts" {
            return rankingService.rankings
        }
        return rankingService.rankings.filter { $0.district == selectedDistrict }
    }
    
    @StateObject private var rankingService = CommunityRankingService()
}

// MARK: - District Filter Button
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

// MARK: - Ranking Card
struct RankingCard: View {
    let ranking: CommunityRanking
    
    var body: some View {
        HStack(spacing: 16) {
            // Ranking
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
            
            // User avatar
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
            
            // User information
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
                    
                    Text(String(format: "%.1f kg CO₂/week", ranking.weeklyEmission))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing) {
                Text("\(ranking.totalPoints)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("points")
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

// MARK: - Community Ranking Service
class CommunityRankingService: ObservableObject {
    @Published var rankings: [CommunityRanking] = []
    
    init() {
        generateMockRankings()
    }
    
    func refreshRankings() async {
        // Simulate network request delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            generateMockRankings()
        }
    }
    
    private func generateMockRankings() {
        let mockUsers = [
            ("Eco Master", "Central & Western", 1250, 8.5),
            ("Green Life", "Wan Chai", 1180, 9.2),
            ("Earth Guardian", "Eastern", 1150, 7.8),
            ("Eco Pioneer", "Southern", 1120, 8.9),
            ("Green Warrior", "Yau Tsim Mong", 1080, 9.5),
            ("Eco Expert", "Sham Shui Po", 1050, 8.1),
            ("Earth Friend", "Kowloon City", 1020, 8.7),
            ("Green Angel", "Wong Tai Sin", 980, 9.0),
            ("Eco Ambassador", "Kwun Tong", 950, 8.3),
            ("Green Dream", "Tsuen Wan", 920, 8.6),
            ("Eco Hero", "Tuen Mun", 890, 9.1),
            ("Green Hope", "Yuen Long", 860, 8.4),
            ("Eco Warrior", "North", 830, 8.8),
            ("Green Future", "Tai Po", 800, 8.2),
            ("Eco Star", "Sha Tin", 770, 8.9),
            ("Green Life", "Sai Kung", 740, 8.5),
            ("Eco Master 2", "Kwai Tsing", 710, 8.7),
            ("Green Guardian", "Islands", 680, 8.3)
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

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User information card
                    UserInfoCard(profile: dataManager.userProfile)
                    
                    // Achievement badges
                    AchievementsSection(profile: dataManager.userProfile)
                    
                    // Statistics
                    StatisticsSection(profile: dataManager.userProfile)
                    
                    // Eco goals
                    EcoGoalsSection()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Personal Profile")
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
        }
    }
}

// MARK: - User Info Card
struct UserInfoCard: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and basic information
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 4) {
                    Text(profile?.username ?? "User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(profile?.levelTitle ?? "Eco Novice")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            // Points and level
            HStack(spacing: 30) {
                VStack {
                    Text("\(profile?.totalPoints ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("Lv.\(profile?.level ?? 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(String(format: "%.0f", profile?.joinDate.timeIntervalSinceNow ?? 0))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Join Days")
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

// MARK: - Achievements Section
struct AchievementsSection: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
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

// MARK: - Badge Card
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

// MARK: - Statistics Section
struct StatisticsSection: View {
    let profile: UserEcoProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eco Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatisticRow(title: "Weekly Emission", value: String(format: "%.1f kg CO₂", profile?.weeklyEmission ?? 0))
                StatisticRow(title: "Monthly Emission", value: String(format: "%.1f kg CO₂", profile?.monthlyEmission ?? 0))
                StatisticRow(title: "Yearly Emission", value: String(format: "%.1f kg CO₂", profile?.yearlyEmission ?? 0))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Statistics Row
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

// MARK: - Eco Goals Section
struct EcoGoalsSection: View {
    @State private var weeklyGoal: Double = 15.0
    @State private var monthlyGoal: Double = 60.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eco Goals")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                GoalProgressView(
                    title: "Weekly Goal",
                    current: 8.5,
                    target: weeklyGoal,
                    unit: "kg CO₂"
                )
                
                GoalProgressView(
                    title: "Monthly Goal",
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

// MARK: - Goal Progress View
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
                
                Text(String(format: "%.1f / %.1f %@", current, target, unit))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Edit Profile")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Notification Settings")
                    }
                }
                
                Section("Privacy") {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Privacy Settings")
                    }
                    
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("Data Sharing")
                    }
                }
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("About App")
                    }
                    
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                        Text("Help & Support")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
