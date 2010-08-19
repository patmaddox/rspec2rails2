module Spec
  module Rails
    module ModuleInclusion
      def include_self_when_dir_matches(*path_parts)
        lambda do |c|
          c.include self, :example_group => {
            :file_path => Regexp.compile(path_parts.join('[\\\/]'))
          }
        end
      end
      
      # taken from rails3 ActiveSupport::Concern
      def included(base = nil, &block)
        if base.nil?
          @_included_block = block
        else
          super
        end
      end
    end
  end
end