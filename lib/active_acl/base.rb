module ActiveAcl
  CONTROLLERS={}
  GROUP_CLASSES={}
  ACCESS_CLASSES={}
  
  def self.register_group(klass,handler)
    GROUP_CLASSES[klass.base_class.name]=handler
  end
  def self.register_object(klass,handler)
    ACCESS_CLASSES[klass.base_class.name]=handler
  end
  def self.group_handler(klass)
    GROUP_CLASSES[klass.base_class.name]
  end
  def self.object_handler(klass)
    ACCESS_CLASSES[klass.base_class.name]
  end
  def self.is_access_group?(klass)
    !!GROUP_CLASSES[klass.base_class.name]
  end
  def self.is_access_object?(klass)
    !!ACCESS_CLASSES[klass.base_class.name]
  end
  def self.from_access_classes
    ACCESS_CLASSES.keys.collect do |class_name|
      class_name.underscore.pluralize.to_sym
    end
  end
  def self.from_group_classes
    GROUP_CLASSES.keys.collect do |class_name|
      class_name.underscore.pluralize.to_sym
    end
  end
end
