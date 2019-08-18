# frozen_string_literal: true

After do |scenario|
  driver = @capybara_driver.browser

  if scenario.failed? && @capybara_driver # no point capturing details if startup failed
    begin
      filename = "Failure-#{scenario.name.slice(0..150).gsub(%r(/['\/\000£$]/), '_').gsub(/\s/, '_')}-#{Time.now.to_i}"

      if ENV['TAKE_SCREENSHOTS']
        puts "saving screenshot to #{filename}.png"
        screenshot_path = Rails.root.join('log', "#{filename}.png")
        if @driver.respond_to?(:save_screenshot)
          @driver.save_screenshot screenshot_path
        elsif page
          page.save_screenshot(screenshot_path)
        else
          `import -window root #{screenshot_path}`
        end
      end

    rescue Exception => e
      raise e
    end

    if ENV['DEBUG_ON_FAIL']
      require "byebug"
      byebug
    end
  end
end
