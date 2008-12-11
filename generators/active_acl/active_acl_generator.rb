class ActiveAclGenerator < Rails::Generator::Base
  attr_accessor :privileges_class_name, :privileges_file_name, :privileges_view_dir
  
  def initialize(*runtime_args)
    super(*runtime_args)
    @privileges_class_name = (args[0] || 'PrivilegesController')
    @privileges_file_name = @privileges_class_name.underscore
    @privileges_view_dir = File.join('app', 'views', @privileges_file_name.gsub('_controller', ''))
  end

  def manifest
    record do |m|
      # Stylesheet, controllers and public directories.
      m.directory File.join('public', 'stylesheets')
      m.directory File.join('app', 'controllers')
      m.directory File.join('app', 'views')
      m.directory privileges_view_dir

      m.template 'controllers/privileges_controller.rb', File.join('app', 'controllers', "#{privileges_file_name}.rb")
      m.file 'views/privileges/_privilege_form.rhtml', File.join(privileges_view_dir, '_privilege_form.rhtml')      
      m.file 'views/privileges/edit.rhtml', File.join(privileges_view_dir, 'edit.rhtml')      
      m.file 'views/privileges/list.rhtml', File.join(privileges_view_dir, 'list.rhtml')      
      m.migration_template('../../../db/migrate/001_base_table_setup.rb',
        'db/migrate',
        :assigns => {:migration_name => "BaseTableSetup"},
        :migration_file_name => "base_table_setup")
    end
  end
end