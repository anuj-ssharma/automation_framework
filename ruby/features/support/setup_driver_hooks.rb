# frozen_string_literal: true

Before do
  @start_browser_lambda = lambda do
    start_capybara_browser(webdriver_options)
  end.tap(&:call)

  @stop_browser_lambda = lambda do
    @capybara_driver&.quit
  end
end

After do
  @stop_browser_lambda&.call
end
