raise "This Rails version is not supported by ActiveAclPlus" if Rails.version < "2.1.0"

if Rails.version < "2.3.0"
  model_path=File.join(File.dirname(__FILE__),'app','models')
  ActiveSupport::Dependencies.load_paths << model_path
end
require 'active_acl'
