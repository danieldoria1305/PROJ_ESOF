Feature: Create a new member in a tree and delete it
  Scenario: User signs in
    Given I have "LoginScreen" on screen
    And I have "EmailField" and "PasswordField" and "SignInButton"
    When I fill the "EmailField" field with "test@gmail.com"
    And I fill the "PasswordField" field with "test1234"
    Then I tap the "SignInButton" widget
    Then I expect the widget "HomeScreen" to be present within 5 seconds


  Scenario: User enters the 'test' tree screen and creates a member
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "Family Tree" to also contain the text "My Test Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I have "AddMemberButton" on screen
    When I tap the "AddMemberButton" widget
    Then I expect the widget "AddMemberDialog" to be present within 3 seconds
    And I have "FirstNameField" on screen
    And I have "LastNameField" on screen
    And I have "GenderDropdown" and "NationalityField" and "AddMemberDialogButton"
    When I fill the "FirstNameField" field with "Test"
    And I fill the "LastNameField" field with "Member"
    And I select the option "Other" from the "GenderDropdown" dropdown
    And I fill the "NationalityField" field with "Test"
    And I tap the "AddMemberDialogButton" widget
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I have a "MemberWidget" that contains the text "Test Member"

  Scenario: User enters the 'test' tree screen and deletes a member
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "Family Tree" to also contain the text "My Test Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
     And I have a "MemberWidget" that contains the text "Test Member"
    Then I swipe left by 400 pixels on the widget that contains the text "Test Member"
    Then I expect the widget "DeleteMemberDialog" to be present within 3 seconds
    Given I have "DeleteMemberDialogButton" on screen
    When I tap the "DeleteMemberDialogButton" button
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I expect the text "Test Member" to be absent

  Scenario: User signs out
    Given I have "HomeScreen" on screen
    And I have "ProfileIcon" on screen
    When I tap the "ProfileIcon" icon
    Given I have "SignOutButton" on screen
    When I tap the "SignOutButton" text
    Then I expect the widget "LoginScreen" to be present within 3 seconds

