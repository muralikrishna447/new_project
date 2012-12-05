module AcceptanceMacros
  def login_user
    Fabricate(:user, email: 'bob@bob.com', name: 'Bob Tester', password: 'password')

    visit '/'
    click_link('Log in')

    wait_until { page.find("#log-in").visible? }

    fill_in 'Email', with: 'bob@bob.com'
    fill_in 'Password', with: 'password'
    click_button 'Log In'
  end
end
