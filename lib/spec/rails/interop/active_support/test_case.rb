# copied and pasted from rails3 ActiveSupport::TestCase

require 'test/unit/testcase'
require 'active_support/testing/setup_and_teardown'
require 'active_support/testing/assertions'
require 'active_support/testing/deprecation'
require 'active_support/testing/declarative'

module Spec
  module Rails
    module Interop
      module ActiveSupport
        module TestCase
          if defined? MiniTest
            Assertion = MiniTest::Assertion
            alias_method :method_name, :name if method_defined? :name
            alias_method :method_name, :__name__ if method_defined? :__name__
          else
            # TODO: Figure out how to get the Rails::BacktraceFilter into minitest/unit
            if defined?(Rails) && ENV['BACKTRACE'].nil?
              require 'rails/backtrace_cleaner'
              Test::Unit::Util::BacktraceFilter.module_eval { include ::Rails::BacktraceFilterForTestUnit }
            end

            Assertion = Test::Unit::AssertionFailedError

            require 'active_support/testing/default'
            include ::ActiveSupport::Testing::Default
          end

          include ::ActiveSupport::Testing::SetupAndTeardown
          include ::ActiveSupport::Testing::Assertions
          include ::ActiveSupport::Testing::Deprecation
          extend ::ActiveSupport::Testing::Declarative
        end
      end
    end
  end
end