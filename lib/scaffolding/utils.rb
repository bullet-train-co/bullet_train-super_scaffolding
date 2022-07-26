module Scaffolding
  module Utils
    def scaffolding_things_disabled?
      ENV["HIDE_THINGS"].present? || ENV["HIDE_EXAMPLES"].present?
    end
  end
end
