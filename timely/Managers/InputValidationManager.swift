import SwiftUI
import Combine

/// Validation rule closure type
typealias ValidationRule = (String) -> Bool

/// Manages validation state for a single input field
class InputFieldState: ObservableObject {
    let id: String
    @Published var currentValue: String = ""
    @Published var lastValid: String = ""
    @Published var isFocused: Bool = false
    @Published var needsValidation: Bool = false

    init(id: String, defaultValue: String = "") {
        self.id = id
        self.lastValid = defaultValue
        self.needsValidation = false
        self.currentValue = defaultValue
    }

    /// Reset validation flag (used by manager when validation is complete)
    func markValidated() {
        needsValidation = false
    }

    /// Mark that validation is needed (called by manager when value changes)
    func setNeedsValidation() {
        needsValidation = true
    }
}

/// Manages validation for all input fields in the app
@MainActor
class InputValidationManager: ObservableObject {
    private var inputStates: [String: InputFieldState] = [:]
    private var validationRules: [String: ValidationRule] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    /// Track which field is currently focused to handle asymmetric focus changes
    @Published private var focusedFieldId: String? = nil
    
    /// Register a new input field with the manager
    func registerInput(id: String, defaultValue: String = "", validationRule: ValidationRule? = nil) -> InputFieldState {
        if let existing = inputStates[id] {
            return existing
        }

        let inputState = InputFieldState(id: id, defaultValue: defaultValue)
        inputStates[id] = inputState

        // Store custom validation rule if provided
        if let rule = validationRule {
            validationRules[id] = rule
        }

        // Listen to focus changes
        inputState.$isFocused
            .sink { [weak self] isFocused in
                self?.handleFocusChange(for: id, isFocused: isFocused)
            }
            .store(in: &cancellables)

        // Listen to value changes and mark validation as needed
        inputState.$currentValue
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak inputState] _ in
                guard let inputState = inputState else { return }
                // Only mark as needing validation if the value has changed from lastValid
                if inputState.currentValue != inputState.lastValid {
                    inputState.setNeedsValidation()
                }
            }
            .store(in: &cancellables)

        return inputState
    }
    
    /// Handle focus changes with proper asymmetric timing
    private func handleFocusChange(for id: String, isFocused: Bool) {
        if isFocused {
            // Defer focus change handling to avoid asymmetric timing issues
            DispatchQueue.main.async { [weak self] in
                self?.handleFieldGainedFocus(id)
            }
        } else {
            // Defer focus loss handling to ensure SwiftUI text binding is complete
            DispatchQueue.main.async { [weak self] in
                self?.handleFieldLostFocus(id)
            }
        }
    }
    
    /// Handle when a field gains focus
    private func handleFieldGainedFocus(_ id: String) {
        let previousFocusedId = focusedFieldId
        focusedFieldId = id
        
        // Validate and revert the previously focused field if it was invalid
        if let prevId = previousFocusedId, prevId != id {
            validateAndCommitField(prevId)
        }
    }
    
    /// Handle when a field loses focus
    private func handleFieldLostFocus(_ id: String) {
        
        // Clear focus tracking for this field
        if focusedFieldId == id {
            focusedFieldId = nil
        }
        
        // Always validate and commit when a field loses focus
        validateAndCommitField(id)
    }
    
    /// Validate and commit a field (only updates lastValid on successful validation)
    private func validateAndCommitField(_ id: String) {
        guard let inputState = inputStates[id] else { return }
        
        
        guard inputState.needsValidation else { 
            return
        }
        
        let currentValue = inputState.currentValue
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isValid(currentValue, for: id) {
                // Valid: commit to lastValid
                inputState.lastValid = currentValue
            } else {
                // Invalid: revert to lastValid
                inputState.currentValue = inputState.lastValid
            }
            
            inputState.needsValidation = false
        }
    }
    
    /// Validate a value for a specific input type
    private func isValid(_ value: String, for inputId: String) -> Bool {
        // Check if there's a custom validation rule first
        if let customRule = validationRules[inputId] {
            return customRule(value)
        }
        
        // Default validation for location inputs
        if inputId.contains("location") {
            if value.isEmpty { return true }
            
            let components = value.components(separatedBy: ",")
            guard components.count >= 2 else { return false }
            
            let cityPart = components[0].trimmingCharacters(in: .whitespaces)
            let countryPart = components[1].trimmingCharacters(in: .whitespaces)
            
            return !cityPart.isEmpty && !countryPart.isEmpty
        }
        
        // Default: accept any non-empty string
        return !value.isEmpty
    }
    
    /// Get the input state for a specific ID
    func inputState(for id: String) -> InputFieldState? {
        return inputStates[id]
    }
    
    /// Add a new input field at runtime (useful for dynamic UIs)
    func addInput(id: String, defaultValue: String = "", validationRule: ValidationRule? = nil) -> InputFieldState {
        return registerInput(id: id, defaultValue: defaultValue, validationRule: validationRule)
    }
    
    /// Remove an input field (useful for dynamic UIs)
    func removeInput(id: String) {
        inputStates.removeValue(forKey: id)
        validationRules.removeValue(forKey: id)
    }
    
    /// Check if any field is currently invalid and focused
    var hasInvalidFocusedField: Bool {
        guard let focusedId = focusedFieldId,
              let inputState = inputStates[focusedId] else { return false }
        
        return !isValid(inputState.currentValue, for: focusedId)
    }
    
    /// Get all currently invalid fields
    var invalidFieldIds: [String] {
        return inputStates.compactMap { (id, inputState) in
            return isValid(inputState.currentValue, for: id) ? nil : id
        }
    }
    
    /// Explicitly commit a field's current value (for programmatic validation)
    /// This validates and saves the current value as lastValid if valid,
    /// or reverts to lastValid if invalid
    func commitField(_ id: String) {
        guard let inputState = inputStates[id] else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isValid(inputState.currentValue, for: id) {
                inputState.lastValid = inputState.currentValue
            } else {
                inputState.currentValue = inputState.lastValid
            }
            inputState.needsValidation = false
        }
    }
    
    /// Programmatically set a field's value and commit it safely
    /// This bypasses user input validation since it's a programmatic update
    func setFieldValue(_ id: String, to value: String) {
        guard let inputState = inputStates[id] else { return }
        
        DispatchQueue.main.async {
            // Set both current and lastValid for programmatic updates
            inputState.currentValue = value
            inputState.lastValid = value
            inputState.needsValidation = false
        }
    }
    
    /// Force validate all fields (useful for form submission)
    func validateAllFields() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for (id, inputState) in self.inputStates {
                if !self.isValid(inputState.currentValue, for: id) {
                    inputState.currentValue = inputState.lastValid
                } else {
                    inputState.lastValid = inputState.currentValue
                }
                inputState.needsValidation = false
            }
        }
    }
}
