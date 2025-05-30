import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("Last updated: [Date]")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)

                Text("1. Agreement to Terms")
                    .font(.title2)
                Text("By downloading, installing, accessing or using the HistoryDreams application (the \"App\"), you agree to be bound by these Terms of Service (\"Terms\"). If you disagree with any part of the terms, then you do not have permission to access the App. We may modify the Terms at any time, and such modifications shall be effective immediately upon posting of the modified Terms on the App.")

                Text("2. Use License")
                    .font(.title2)
                Text("Permission is granted to temporarily download one copy of the App for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not: modify or copy the materials; use the materials for any commercial purpose, or for any public display (commercial or non-commercial); attempt to decompile or reverse engineer any software contained in the App; remove any copyright or other proprietary notations from the materials; or transfer the materials to another person or \"mirror\" the materials on any other server.")
                
                // Add more sections as needed: User Accounts, Content, Prohibited Activities, Termination, Disclaimers, Limitation of Liability, Governing Law, Changes to Terms, Contact Information
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
} 