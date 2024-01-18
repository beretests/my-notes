require "application_system_test_case"
 
class LoginTest < ApplicationSystemTestCase
    test "user can log in" do
                          
        # visit the login page
        visit login_path
        
        # fill in login form with valid user credentials
        fill_in "Email", with: "vivtesterbere+12345@gmail.com"
        fill_in "Password", with: "Lundi12!?A"
        
        # click login button
        click_on "Log in"
        
        # assert that user is directed to dashboard after login
        assert_text "Welcome, vivtesterbere+12345@gmail.com!"
        
    end  
end