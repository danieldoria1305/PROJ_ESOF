Feature: Register, Login and Sign out
  # Scenario: when user creates an account with valid email and password
    # Given I have "EmailField" and "PasswordField" and "RegisterNowButton"
    # Then I tap the "RegisterNowButton" button
    # Then I have "RegisterScreen" on screen
    # When I fill the "EmailField" field with "hello@gmail.com"
    # And I fill the "PasswordField" field with "hello1234"
    # Then I tap the "RegisterButton" button

  Scenario: when email and password are in specified format and sign in is clicked
    Given I have "EmailField" and "PasswordField" and "SignInButton"
    When I fill the "EmailField" field with "test@gmail.com"
    And I fill the "PasswordField" field with "test1234"
    Then I tap the "SignInButton" widget
    Then I have "HomeScreen" on screen

    Scenario: when user is logged in and clicks on sign out
      Given I have "ProfileIcon" on screen
      When I tap the "ProfileIcon" icon
      Given I have "SignOutButton" on screen
      When I tap the "SignOutButton" text
      Then I have "LoginScreen" on screen
