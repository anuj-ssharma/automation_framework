# frozen_string_literal: true

HTTP_SERVER_PORT = ENV['PORT']
URL = "http://#{ENV["URL"]}"

def start_capybara_browser(options)
  @capybara_driver = nil

  Capybara.configure do |config|
    config.run_server = true
  end

  Capybara.default_driver = :selenium
  Capybara.app_host = URL
  Capybara.default_max_wait_time = 5
  tries = 0

  begin
    Capybara.register_driver(:selenium) do |app|
      @capybara_driver = Capybara::Selenium::Driver.new(app, options.merge(:browser => selected_browser))
    end

    yield if block_given?

    @site = URL
    launch_app
  rescue EOFError, # webdriver crashed
         Selenium::WebDriver::Error::WebDriverError, # unable to connect to webdriver @ http://127.0.0.1:X after 20 seconds
         Net::ReadTimeout # timed out trying to connect to chromedriver
    tries += 1
    tries >= browser_retry_limit ? raise : retry
  end
end

def launch_app
  Capybara.page.visit @site
end

def restart_browser
  @stop_browser_lambda.call
  @start_browser_lambda.call
end

def browser_retry_limit
  chrome_headless? ? 5 : 0
end
