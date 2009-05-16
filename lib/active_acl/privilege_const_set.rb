class ::Module
  public
  # Looks up or creates a privilege object using the caller's name and the constant's name.
  # Finally sets the privilege object as a constant to the caller.
  # Accepts a hash of names with descriptions like :name => description or a single string name value.
  # If force_reload is set to true, the constant will be recreated from the DB.
  # Returns an array of changed privileges.
  def privilege_const_set(constant, force_reload = false)
    begin
      result = []
      constant.is_a?(Hash) ? constant_hash = constant : constant_hash = {constant.to_s => nil}
      constant_hash.each_pair do |constant_name, description|
        if !const_defined?(constant_name.to_s) || force_reload
          remove_const(constant_name.to_s) if const_defined?(constant_name.to_s)
          privilege = ActiveAcl::Privilege.find_by_section_and_value(self.name, constant_name.to_s)
          privilege = ActiveAcl::Privilege.create!(:section => self.name, :value => constant_name.to_s, :description => description) unless privilege
          const_set(constant_name.to_s, privilege)
          result << privilege
        end
      end
      result

      #this is for bootstrapping
    rescue NameError => e
      puts "[ERROR] #{__FILE__},#{__LINE__}: Probably missing migration!\n#{e.inspect}"
    rescue ActiveRecord::StatementInvalid => e
      puts "[ERROR] #{__FILE__},#{__LINE__}: Probably missing migration!\n#{e.inspect}"
    end
  end
end