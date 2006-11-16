module Spec
  module Rails
    class ControllerContext < Rails::Context

      module ControllerInstanceMethods
        # === render(options = nil, deprecated_status = nil, &block)
        #
        # This gets added to the controller's singleton meta class,
        # allowing Controller Specs to run in two modes, freely switching
        # from spec to spec.
        #
        # The two modes represent the tension between the more granular
        # testing common in TDD and the more high level testing built into
        # rails. BDD sits somewhere in between: we want to a balance between
        # specs that are close enough to the code to enable quick fault
        # isolation and far enough away from the code to enable refactoring
        # with minimal changes to the existing specs.
        #
        # Isolation mode (default)
        #
        #   No dependencies on views because none are ever rendered. The
        #   benefit of this mode is that can spec the controller completely
        #   independent of the view, allowing that responsibility to be
        #   handled later, or by somebody else. Combined w/ separate view
        #   specs, this also provides better fault isolation.
        #
        # Integration mode
        #
        #   To run in this mode, include the following line in your spec:
        #
        #     integrate_views
        #
        #   In this mode, controller specs are run in the same way that
        #   rails functional tests run - one set of tests for both the
        #   controllers and the views. The benefit of this approach is that
        #   you get wider coverage from each spec. Experienced rails
        #   developers may find this an easier approach to begin with, however
        #   we encourage you to explore using the isolation mode and revel
        #   in its benefits.
        def render(options=nil, deprecated_status=nil, &block)
          unless block_given?
            unless integrate_views?
              @template = Spec::Mocks::Mock.new("mock template") 
              @template.stub!(:evaluate_assigns)
              @template.stub!(:render)
              @template.stub!(:file_exists?).and_return(true)
              @template.stub!(:full_template_path)
              @template.stub!(:render_file)
            end
          end
          render_matcher.set_actual(ensure_default_options(options), response, &block)
          super
        end
        
        def should_render(expected)
          render_matcher.set_expected(expected)
        end
        
        #backwards compatibility to 0.7.0-0.7.2
        alias_method :should_have_rendered, :should_render

        def should_render_rjs(element, *opts)
          render_matcher.should_render_rjs(element, *opts)
        end

        def should_not_render_rjs(element, *opts)
          render_matcher.should_not_render_rjs(element, *opts)
        end
        
        def should_redirect_to(opts)
          redirect_matcher.set_expected(opts)
        end
        
        def redirect_to(opts)
          super
          redirect_matcher.match(request, opts) if redirect_matcher.interested_in?(opts)
        end

        def integrate_views!
          @integrate_views = true
        end

      private

        def integrate_views?
          @integrate_views
        end
        
        def render_called
          @render_called = true
        end

        def render_called?
          @render_called
        end

        def render_matcher
          @render_matcher ||= Spec::Rails::RenderMatcher.new(integrate_views?)
        end

        def redirect_matcher
          @redirect_matcher ||= Spec::Rails::RedirectMatcher.new
        end
        
        def ensure_default_options(options)
          return {:template => default_template_name} if options.nil?
          return options
        end
      end
      
      module ContextEvalInstanceMethods
        attr_reader :response, :request, :controller

        #This is a hook provided by Spec::Rails::TestCase
        def setup_extra
          (class << @controller; self; end).class_eval do
            include ControllerInstanceMethods
          end
          @controller.integrate_views! if @integrate_views
          @controller.session = session
        end
      end

      module ContextEvalClassMethods
        attr_accessor :controller_class_name
        def controller_name(name=nil)
          @controller_class_name = "#{name}_controller".camelize
        end
        def integrate_views
          @integrate_views = true
        end
        def integrate_views?
          @integrate_views
        end
      end

      def execution_context specification=nil
        instance = execution_context_class.new(specification)
        controller_class_name = @context_eval_module.controller_class_name
        integrate_views = @context_eval_module.integrate_views? ? true : false
        instance.instance_eval {
          @controller_class_name = controller_class_name.to_s
          @integrate_views = integrate_views
        }
        instance
      end

      def before_context_eval
        inherit Spec::Rails::ControllerTestCase
        @context_eval_module.extend ControllerContext::ContextEvalClassMethods
        @context_eval_module.include ControllerContext::ContextEvalInstanceMethods
      end
    end
  end
end

