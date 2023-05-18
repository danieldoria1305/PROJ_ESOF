Feature: User registering and information stored in the database
  Scenario: User creates an account with valid email and password
    Given I have "LoginScreen" on screen
    And I have "EmailField" and "PasswordField" and "RegisterNowButton"
    When I tap the "RegisterNowButton" button
    Then I have "RegisterScreen" on screen
    And I have "EmailField" and "ConfirmPasswordField" and "SignUpButton"
    When I fill the "FirstNameField" field with "Hello"
    And I fill the "LastNameField" field with "World"
    And I fill the "AgeField" field with "20"
    And I fill the "EmailField" field with "hello@gmail.com"
    And I fill the "PasswordField" field with "hello1234"
    And I fill the "ConfirmPasswordField" field with "hello1234"
    And I tap the "SignUpButton" button
    Then I expect the widget "HomeScreen" to be present within 3 seconds

  Scenario: User deletes the created account
    Given I have "HomeScreen" on screen
    And I have "ProfileIcon" on screen
    When I tap the "ProfileIcon" icon
    Then I have "AccountButton" on screen
    When I tap the "AccountButton" text
    Then I have "AccountScreen" on screen
    Given I have "DeleteAccountButton" on screen
    When I tap the "DeleteAccountButton" button
    Then I expect the widget "DeleteAccountAlert" to be present within 1 second
    Given I have "DeleteAccountAlertButton" on screen
    When I tap the "DeleteAccountAlertButton" button
    Then I expect the widget "LoginScreen" to be present within 3 seconds



