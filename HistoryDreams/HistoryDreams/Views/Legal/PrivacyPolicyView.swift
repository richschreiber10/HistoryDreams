import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("Last updated: [Date]")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                Text("Introduction")
                    .font(.title2)
                Text("Welcome to HistoryDreams. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us at [Contact Email/Link].")
                
                Text("Information We Collect")
                    .font(.title2)
                Text("We may collect personal information that you voluntarily provide to us when you register on the app, express an interest in obtaining information about us or our products and services, when you participate in activities on the app or otherwise when you contact us. The personal information that we collect depends on the context of your interactions with us and the app, the choices you make and the products and features you use. The personal information we collect may include the following: [List types of info, e.g., Email, Username, Usage Data etc.]")
                
                // Add more sections as needed: How We Use Your Information, Will Your Information Be Shared With Anyone?, How Long Do We Keep Your Information?, How Do We Keep Your Information Safe?, What Are Your Privacy Rights?, Updates To This Notice, How Can You Contact Us About This Notice?
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
} 