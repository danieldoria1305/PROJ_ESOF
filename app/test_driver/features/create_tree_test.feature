Feature: Create a new tree and delete it
  Scenario: User signs in
    Given I have "LoginScreen" on screen
    And I have "EmailField" and "PasswordField" and "SignInButton"
    When I fill the "EmailField" field with "test@gmail.com"
    And I fill the "PasswordField" field with "test1234"
    Then I tap the "SignInButton" widget
    Then I expect the widget "HomeScreen" to be present within 5 seconds

  Scenario: User creates a new tree
    Given I have "HomeScreen" on screen
    And I have "CreateTreeButton" on screen
    When I tap the "CreateTreeButton" button
    Then I expect the widget "CreateTreeDialog" to be present within 3 seconds
    Given I have "TreeNameField" on screen
    When I fill the "TreeNameField" field with "My First Tree"
    And I have "CreateTreeDialogButton" on screen
    When I tap the "CreateTreeDialogButton" button
    Then I expect the widget "HomeScreen" to be present within 3 seconds
    And I expect a "TreeWidget" that contains the text "Family Tree" to also contain the text "My First Tree"

  Scenario: User deletes a tree
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "Family Tree" to also contain the text "My First Tree"
    When I swipe left by 400 pixels on the widget that contains the text "My First Tree"
    Then I expect the widget "DeleteTreeDialog" to be present within 3 seconds
    Given I have "DeleteTreeDialogButton" on screen
    When I tap the "DeleteTreeDialogButton" button
    Then I expect the widget "HomeScreen" to be present within 3 seconds
    And I expect the text "My First Tree" to be absent

  Scenario: User signs out
    Given I have "HomeScreen" on screen
    And I have "ProfileIcon" on screen
    When I tap the "ProfileIcon" icon
    Given I have "SignOutButton" on screen
    When I tap the "SignOutButton" text
    Then I expect the widget "LoginScreen" to be present within 3 seconds
