# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'

require_relative '../../features/support/selenium'
require_relative '../../features/support/framework'
require_relative '../../features/support/browser_options'

RSpec.configure do |config|
  config.before do
    @start_browser_lambda = lambda do
      start_capybara_browser(webdriver_options)
    end.tap(&:call)

    @stop_browser_lambda = lambda do
      @capybara_driver&.quit
    end
  end

  config.after do
    @stop_browser_lambda&.call
  end
end
