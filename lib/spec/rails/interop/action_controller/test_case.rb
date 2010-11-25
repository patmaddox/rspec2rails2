# copied and pasted from rails2 ActionController::TestCase
require 'action_controller/test_process'

module Spec
  module Rails
    module Interop
      module ActionController
        module TestCase
          include ::Spec::Rails::Example::RoutingHelpers

          def setup_controller_request_and_response
            @request = ::ActionController::TestRequest.new
            @response = ::ActionController::TestResponse.new

            if klass = self.described_class
              @controller ||= klass.new rescue nil
            end

            if @controller
              @controller.request = @request
              @controller.params = {}
              @controller.send(:initialize_current_url)
            end
          end


          if ::Rails::VERSION::STRING =~ /2\.0/
            # Introduced in Rails 2.1, but we need it for 2.0
            def rescue_action_in_public!
              # See rescue.rb in this same directory
              def request.rescue_action_in_public?
                true
              end
            end

          end
        end
      end
    end
  end
end
