Feature: Login and Sign out
  Scenario: Email and password are in specified format and sign in is clicked
    Given I have "LoginScreen" on screen
    And I have "EmailField" and "PasswordField" and "SignInButton"
    When I fill the "EmailField" field with "test@gmail.com"
    And I fill the "PasswordField" field with "test1234"
    Then I tap the "SignInButton" widget
    Then I expect the widget "HomeScreen" to be present within 3 seconds

  Scenario: User is logged in and clicks on sign out
    Given I have "HomeScreen" on screen
    And I have "ProfileIcon" on screen
    When I tap the "ProfileIcon" icon
    Given I have "SignOutButton" on screen
    When I tap the "SignOutButton" text
    Then I expect the widget "LoginScreen" to be present within 3 seconds
