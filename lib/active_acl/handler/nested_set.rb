module ActiveAcl
  module Acts #:nodoc:
    module AccessGroup #:nodoc:
      class NestedSet #:nodoc:
        attr_reader :left_column,:right_column
        def initialize(options)
          
          @left_column = options[:left_column] || :lft 
          @right_column = options[:right_column] || :rgt
          #          :controller => ActiveAcl::OPTIONS[:default_group_selector_controller],
          #          :action => ActiveAcl::OPTIONS[:default_group_selector_action]}
          
        end
        def group_sql(object_handler,target = false)
          target_requester = (target ? 'target' : 'requester')
          if object_handler.habtm?
            "(SELECT DISTINCT g2.id FROM #{object_handler.join_table} ml 
               LEFT JOIN #{object_handler.group_table_name} g1 ON ml.#{object_handler.association_foreign_key} = g1.id CROSS JOIN #{object_handler.group_table_name} g2
               WHERE ml.#{object_handler.foreign_key} = %{#{target_requester}_id} AND (g2.#{left_column} <= g1.#{left_column} AND g2.#{right_column} >= g1.#{right_column}))"
          else
            "(SELECT DISTINCT g2.id FROM #{object_handler.group_table_name} g1 CROSS JOIN #{object_handler.group_table_name} g2
               WHERE g1.id = %{#{target_requester}_group_id} AND (g2.#{left_column} <= g1.#{left_column} AND g2.#{right_column} >= g1.#{right_column}))"
          end
          #"r_groups.#{left_column} - r_groups.#{right_column} ASC" 
        end
        def order_by(object_handler,target=false)
          target_requester = (target ? 't' : 'r')
          "#{target_requester}_groups.#{left_column} - #{target_requester}_groups.#{right_column} ASC"
        end
      end #class
    end
  end
end