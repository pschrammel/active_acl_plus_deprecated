module ActiveAcl
  CONTROLLERS={}
  GROUP_CLASSES={}
  ACCESS_CLASSES={}
  
  def self.is_access_group?(klass)
    !!ActiveAcl::GROUP_CLASSES[klass.name]
  end
  def self.is_access_object?(klass)
    !!ActiveAcl::ACCESS_CLASSES[klass.name]
  end
  def self.from_classes 
    ActiveAcl::ACCESS_CLASSES.keys.collect do |x| 
      x.split('::').join('/').underscore.pluralize.to_sym
    end
  end
end