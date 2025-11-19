import SwiftUI

struct PersonalGoal: Identifiable {
    let id = UUID()
    var title: String
    var limitMinutes: Int
    var currentMinutes: Int
}

struct PersonalGoalsScreen: View {
    @Binding var instagramMinutes: Int
    @Binding var tiktokMinutes: Int
    @Binding var youtubeMinutes: Int
    @State private var goals: [PersonalGoal] = [
        PersonalGoal(title: "Limit Instagram", limitMinutes: 60, currentMinutes: 0),
        PersonalGoal(title: "Limit TikTok", limitMinutes: 45, currentMinutes: 0),
        PersonalGoal(title: "Limit YouTube", limitMinutes: 90, currentMinutes: 0)
    ]
    @State private var newGoalTitle: String = ""
    @State private var newGoalLimit: String = ""
    @State private var showAddGoal: Bool = false

    func syncGoalsWithMinutes() {
        for i in goals.indices {
            switch goals[i].title {
            case "Limit Instagram":
                goals[i].currentMinutes = instagramMinutes
            case "Limit TikTok":
                goals[i].currentMinutes = tiktokMinutes
            case "Limit YouTube":
                goals[i].currentMinutes = youtubeMinutes
            default:
                break
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // ...existing code...
                Text("Personal Goals")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                List {
                    ForEach(goals) { goal in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.title)
                                    .font(.headline)
                                Spacer()
                                Text("Limit: \(goal.limitMinutes) min")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            ProgressView(value: min(Double(goal.currentMinutes), Double(goal.limitMinutes)), total: Double(goal.limitMinutes))
                                .accentColor(goal.currentMinutes <= goal.limitMinutes ? .green : .red)
                            Text("Used: \(goal.currentMinutes) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete { indexSet in
                        goals.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onAppear {
                    syncGoalsWithMinutes()
                }
                .onChange(of: instagramMinutes) { _ in syncGoalsWithMinutes() }
                .onChange(of: tiktokMinutes) { _ in syncGoalsWithMinutes() }
                .onChange(of: youtubeMinutes) { _ in syncGoalsWithMinutes() }
                Button(action: { showAddGoal = true }) {
                    Text("Add New Goal")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showAddGoal) {
                    VStack(spacing: 16) {
                        Text("Add Personal Goal")
                            .font(.title2)
                            .bold()
                        TextField("Goal Title", text: $newGoalTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Limit (minutes)", text: $newGoalLimit)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Save") {
                            if let limit = Int(newGoalLimit), !newGoalTitle.isEmpty {
                                goals.append(PersonalGoal(title: newGoalTitle, limitMinutes: limit, currentMinutes: 0))
                                newGoalTitle = ""
                                newGoalLimit = ""
                                showAddGoal = false
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                        Button("Cancel") {
                            showAddGoal = false
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct PersonalGoalsScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonalGoalsScreen(
            instagramMinutes: .constant(10),
            tiktokMinutes: .constant(20),
            youtubeMinutes: .constant(30)
        )
    }
}
