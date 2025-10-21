import SwiftUI

// MARK: - Challenge Page
struct ChallengeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: EcoChallenge.ChallengeCategory?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            title: "All Categories",
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
                
                // Challenge list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredChallenges) { challenge in
                            ChallengeCard(challenge: challenge)
                                .environmentObject(dataManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Eco Challenges")
        }
    }
    
    private var filteredChallenges: [EcoChallenge] {
        if let category = selectedCategory {
            return dataManager.challenges.filter { $0.category == category }
        }
        return dataManager.challenges
    }
}

// MARK: - Category Filter Button
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

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: EcoChallenge
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category icon
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
                
                // Points display
                VStack {
                    Text("\(challenge.points)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar (if challenge has started)
            if let startDate = challenge.startDate, let endDate = challenge.endDate {
                ChallengeProgressView(
                    startDate: startDate,
                    endDate: endDate,
                    isCompleted: challenge.isCompleted
                )
            }
            
            // Action buttons
            HStack {
                if challenge.isCompleted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                } else if challenge.startDate != nil {
                    Button("View Progress") {
                        showingDetail = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    Button("Start Challenge") {
                        dataManager.startChallenge(challenge)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                Spacer()
                
                Button("Details") {
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
                .environmentObject(dataManager)
        }
    }
}

// MARK: - Category Icon
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

// MARK: - Challenge Progress View
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
                Text(isCompleted ? "Challenge Completed" : "In Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted ? .green : .blue)
                
                Spacer()
                
                if !isCompleted {
                    Text("remaining \(remainingDays) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? .green : .blue))
        }
    }
}

// MARK: - Challenge Detail View
struct ChallengeDetailView: View {
    let challenge: EcoChallenge
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Challenge information
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
                    
                    // Challenge details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Challenge Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DetailRow(title: "Points Reward", value: "\(challenge.points) points")
                        DetailRow(title: "Duration", value: "\(challenge.duration) days")
                        
                        if let startDate = challenge.startDate {
                            DetailRow(title: "Start Time", value: DateFormatter.shortDate.string(from: startDate))
                        }
                        
                        if let endDate = challenge.endDate {
                            DetailRow(title: "End Time", value: DateFormatter.shortDate.string(from: endDate))
                        }
                        
                        DetailRow(title: "Status", value: challenge.isCompleted ? "Completed" : "In Progress")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Challenge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Detail Row
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

// MARK: - Date Formatter Extension
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
        .environmentObject(DataManager.shared)
}
