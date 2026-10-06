import Foundation
import FirebaseAuth
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String?
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // This listener checks for login/logout changes in real-time.
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userSession = user
                print("Auth State Changed. User: \(user?.uid ?? "None")")
            }
        }
        print("Auth Listener Initialized.")
    }

    deinit {
        // Clean up the listener to prevent memory leaks
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Auth Listener Removed.")
        }
    }

    // MARK: - Authentication Functions

    @MainActor
    func signIn(withEmail email: String, password: String) async {
        self.errorMessage = nil // Clear previous errors
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // The listener will update userSession automatically
            print("Successfully signed in user: \(result.user.uid)")
        } catch {
            self.errorMessage = "Failed to sign in: \(error.localizedDescription)"
            print(self.errorMessage!)
        }
    }

    // Revised SignUp function: Returns the User object on success
    @MainActor
    func signUp(withEmail email: String, password: String) async -> FirebaseAuth.User? {
        self.errorMessage = nil // Clear previous errors
        do {
            // Use Firebase's built-in user creation method
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Successfully signed up user: \(result.user.uid)")
            return result.user
        } catch {
            self.errorMessage = "Failed to sign up: \(error.localizedDescription)"
            print(self.errorMessage!)
            return nil // Return nil on failure
        }
    }

    @MainActor
    func signOut() {
        do {
            try Auth.auth().signOut()
            // The listener will update userSession automatically to nil
            print("Successfully signed out.")
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print(self.errorMessage!)
        }
    }
    
    // MARK: - Helper Functions
    
    // Checks if an email is already registered in Firebase.
    // Returns `true` if the email exists, `false` otherwise.
    @MainActor
    func checkIfEmailInUse(email: String) async -> Bool {
        do {
            // Fetches the sign-in methods associated with the email.
            // If the list is NOT empty, the email is already in use.
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            return !methods.isEmpty
        } catch {
            print("Error checking email existence: \(error.localizedDescription)")
            
            return false
        }
    }
}
