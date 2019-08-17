# frozen_string_literal: true

HTTP_SERVER_PORT = ENV['PORT']
BROWSER = ENV['BROWSER'] || "chrome-headless"
HEADLESS = BROWSER.include?("headless")
URL = "http://localhost:#{HTTP_SERVER_PORT}"



def start_capybara_browser(options)
  @capybara_driver = nil

  Capybara.configure do |config|
    config.run_server = false # we use in_process_server.rb
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
  rescue EOFError, # webdriver crashed
         Selenium::WebDriver::Error::WebDriverError, # unable to connect to webdriver @ http://127.0.0.1:X after 20 seconds
         Net::ReadTimeout # timed out trying to connect to chromedriver
    tries += 1
    tries >= browser_retry_limit ? raise : retry
  end
end
