import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
 
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        Form {
            Section("Current Password") {
                SecureField("Enter your current password", text: $currentPassword)
            }
            
            Section("New Password") {
                SecureField("Enter your new password", text: $newPassword)
                SecureField("Confirm your new password", text: $confirmPassword)
            }
            
            Button(action: {
                
          
                
                print("Password change logic goes here.")
                
                dismiss()
            }) {
                Text("Save Password")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(newPassword.isEmpty || newPassword != confirmPassword)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
