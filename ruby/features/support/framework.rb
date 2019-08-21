# frozen_string_literal: true

module Framework
  class FrameworkError < StandardError; end
  class InvalidUrl < FrameworkError; end
end
