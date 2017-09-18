# YogaLayout provides a thin FFI-based wrapper around the core Yoga library.
#
# Yoga is a cross-platform layout engine enabling maximum collaboration within
# your team by implementing an API familiar to many designers and opening it up
# to developers across different platforms.
#
# @see https://facebook.github.io/yoga
module YogaLayout
  # Root error class for the YogaLayout module
  class Error < ::StandardError; end

  # Turn a CamelCase string into a snake_case string.
  #
  # @api private
  def self.underscore(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      downcase
  end

  require 'yoga_layout/version'
  require 'yoga_layout/bindings'
  require 'yoga_layout/node'
  require 'yoga_layout/config'
end
