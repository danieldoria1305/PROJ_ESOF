Feature: General App Testing
#Feature: User registering and information stored in the database
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
    Then I expect the widget "HomeScreen" to be present within 5 seconds

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

#Feature: Login
  Scenario: Email and password are in specified format and sign in is clicked
    Given I have "LoginScreen" on screen
    And I have "EmailField" and "PasswordField" and "SignInButton"
    When I fill the "EmailField" field with "test@gmail.com"
    And I fill the "PasswordField" field with "test1234"
    Then I tap the "SignInButton" widget
    Then I expect the widget "HomeScreen" to be present within 3 seconds

#Feature: Create a new tree and delete it
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
    And I expect a "TreeWidget" that contains the text "My First Tree" to also contain the text "Family Tree"

  Scenario: User deletes a tree
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My First Tree" to also contain the text "Family Tree"
    When I swipe left by 400 pixels on the widget that contains the text "My First Tree"
    Then I expect the widget "DeleteTreeDialog" to be present within 3 seconds
    Given I have "DeleteTreeDialogButton" on screen
    When I tap the "DeleteTreeDialogButton" button
    Then I expect the widget "HomeScreen" to be present within 3 seconds
    And I expect the text "My First Tree" to be absent

#Feature: Create a new member in a tree and delete it
  Scenario: User enters the 'test' tree screen and creates a member
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
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

  Scenario: User enters the 'test' tree screen and filters the members by gender
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    Given I have "GenderFilterDropdown" on screen
    When I select the option "Other" from the "GenderFilterDropdown" dropdown
    Then I expect the text "Test Member" to be present
    And I expect the text "Female Test" to be absent

  Scenario: User enters the 'test' tree screen and filters the members by last name
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    Given I have "LastNameFilterDropdown" on screen
    When I select the option "Test" from the "LastNameFilterDropdown" dropdown
    Then I expect the text "Test Member" to be absent
    And I expect the text "Male Test" to be present

  Scenario: User enters the 'test' tree screen and filters the members by nationality
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    Given I have "NationalityFilterDropdown" on screen
    When I select the option "Test" from the "NationalityFilterDropdown" dropdown
    Then I expect the text "Test Member" to be present
    And I expect the text "Male Testing" to be absent

  Scenario: User enters the 'test' tree screen and enters the statistics screen (1)
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I have "TreeStatisticsButton" on screen
    When I tap the "TreeStatisticsButton" widget
    Then I expect the widget "TreeStatisticsScreen" to be present within 3 seconds
    And I have "MaleCountWidget" on screen
    And I have "FemaleCountWidget" on screen
    And I have "NonBinaryCountWidget" on screen
    And I have "OtherCountWidget" on screen
    And I have "MostCommonNationalityWidget" on screen
    Then I expect a "StatisticsWidget" that contains the text "Male members" to also contain the text "2"
    Then I expect a "StatisticsWidget" that contains the text "Female members" to also contain the text "1"
    Then I expect a "StatisticsWidget" that contains the text "Non-binary members" to also contain the text "1"
    Then I expect a "StatisticsWidget" that contains the text "Other members" to also contain the text "2"
    Then I expect a "StatisticsWidget" that contains the text "Most common nationality" to also contain the text "PT"


  Scenario: User enters the 'test' tree screen and deletes a member
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I have a "MemberWidget" that contains the text "Test Member"
    Then I swipe left by 400 pixels on the widget that contains the text "Test Member"
    Then I expect the widget "DeleteMemberDialog" to be present within 3 seconds
    Given I have "DeleteMemberDialogButton" on screen
    When I tap the "DeleteMemberDialogButton" button
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I expect the text "Test Member" to be absent

  Scenario: User enters the 'test' tree screen and enters the statistics screen (2)
    Given I have "HomeScreen" on screen
    And I expect a "TreeWidget" that contains the text "My Test Tree" to also contain the text "Family Tree"
    When I tap the widget that contains the text "My Test Tree"
    Then I expect the widget "TreeScreen" to be present within 3 seconds
    And I have "TreeStatisticsButton" on screen
    When I tap the "TreeStatisticsButton" widget
    Then I expect the widget "TreeStatisticsScreen" to be present within 3 seconds
    And I have "MaleCountWidget" on screen
    And I have "FemaleCountWidget" on screen
    And I have "NonBinaryCountWidget" on screen
    And I have "OtherCountWidget" on screen
    And I have "MostCommonNationalityWidget" on screen
    Then I expect a "StatisticsWidget" that contains the text "Male members" to also contain the text "2"
    Then I expect a "StatisticsWidget" that contains the text "Female members" to also contain the text "1"
    Then I expect a "StatisticsWidget" that contains the text "Non-binary members" to also contain the text "1"
    Then I expect a "StatisticsWidget" that contains the text "Other members" to also contain the text "1"
    Then I expect a "StatisticsWidget" that contains the text "Most common nationality" to also contain the text "PT"


#Feature: Sign out
  Scenario: User is logged in and clicks on sign out
    Given I have "HomeScreen" on screen
    And I have "ProfileIcon" on screen
    When I tap the "ProfileIcon" icon
    Given I have "SignOutButton" on screen
    When I tap the "SignOutButton" text
    Then I expect the widget "LoginScreen" to be present within 3 seconds