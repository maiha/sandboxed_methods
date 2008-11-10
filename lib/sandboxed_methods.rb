class SandboxedMethods
  attr_accessor :base

  def initialize(base)
    @base = base
  end

  def method_missing(name, *args)
    if md = /\=$/.match(name.to_s)
      __send__ :[]=, md.pre_match, *args
    else
      self[name]
    end
  end

  def [](name)
    @base.instance_variable_get("@#{name}")
  end

  def []=(name, val)
    @base.instance_variable_set("@#{name}", val)
  end

  class << self
    def give(base, *methods)
      target  = (methods.last.is_a?(Hash) && methods.pop[:class]) ? (class<<base; self end) : base
      methods = instance_methods - SandboxedMethods.instance_methods if methods.empty?
      methods << {:to=>"(@_#{name.underscore.gsub('/', '__')} ||= #{self}.new(self))"}
      target.delegate *methods
    end
  end
end
