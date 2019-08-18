# frozen_string_literal: true

BROWSER = ENV['BROWSER'] || "chrome-headless"
HEADLESS = BROWSER.include?("headless")

def firefox_options(mobile_web)
  browser_options = Selenium::WebDriver::Firefox::Options.new

  browser_options.add_argument('--headless') if HEADLESS

  if mobile_web
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = mobile_useragent

    browser_options.profile = profile
  end

  browser_options
end

def chrome_headless?
  selected_browser == :chrome && HEADLESS
end

def chrome_options(mobile_web)
  browser_options = Selenium::WebDriver::Chrome::Options.new
  # browser_options.binary = ENV['CHROME_BINARY'] if ENV['CHROME_BINARY'].present?

  # disable-gpu : "Currently you'll also need to use --disable-gpu to avoid an error from a missing Mesa library."
  %w(--headless --disable-gpu --window-size=1280x1600 --disable-infobars --start-maximized --js-flags="--max_old_space_size=250").each do |arg|
    browser_options.add_argument(arg)
  end if HEADLESS

  # browser_options.add_argument("--user-agent=#{mobile_useragent}") if mobile_web
  browser_options.add_argument("--no-sandbox")
  browser_options.add_argument("--no-zygote")
  # browser_options.add_argument("--log-path=#{webdriver_logfile_path}")
  browser_options.add_argument('--verbose') if ENV['CHROME_DEBUG']

  browser_options
end

def webdriver_options(mobile_web: false)
  browser_options =
    if selected_browser == :chrome
      chrome_options(mobile_web)
    elsif selected_browser == :firefox
      firefox_options(mobile_web)
    else
      raise "Unsupported browser #{selected_browser}"
    end

  service_args = {}

  service_args[:port] = ENV['WEBDRIVER_PORT']

  browser_service = Selenium::WebDriver::Service.public_send(selected_browser, service_args)

  # No memoisation possible, Selenium::WebDriver calls delete on options
  { :options => browser_options, :service => browser_service }.compact
end

def selected_browser
  @selected_browser ||= case BROWSER
                        when "chrome-headless"
                          :chrome
                        when "firefox-headless"
                          :firefox
                        else
                          BROWSER.to_sym
                        end
end
