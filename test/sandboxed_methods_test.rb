require File.join(File.dirname(__FILE__), 'test_helper')

class SandboxedMethodsInstanceMethodTest < Test::Unit::TestCase
  module Foo
    def self.append_features(base)
      Methods.give(base, :foo)
    end

    class Methods < SandboxedMethods
      def foo
        my_name
      end

      def baz
        :baz
      end

      # internal_methods
      def my_name
        :foo
      end
    end
  end

  module Bar
    def self.append_features(base)
      Methods.give(base, :bar)
    end

    class Methods < SandboxedMethods
      def bar
        my_name
      end

      def baz
        :baz
      end

      # internal_methods
      def my_name
        :bar
      end
    end
  end

  class FooBar
    include Foo
    include Bar
  end

  def test_guard_against_conflictions_of_internal_methods
    object = FooBar.new
    assert_equal :foo, object.foo
    assert_equal :bar, object.bar
  end

  def test_guard_against_non_published_method
    object = FooBar.new
    assert_raises(NoMethodError) {object.baz}
    assert_raises(NoMethodError) {object.my_name}
  end
end


class SandboxedMethodsClassMethodTest < Test::Unit::TestCase
  module Foo
    def self.append_features(base)
      Methods.give(base, :foo, :class=>true)
    end

    class Methods < SandboxedMethods
      def foo
        my_name
      end

      # internal_methods
      def my_name
        :foo
      end
    end
  end

  module Bar
    def self.append_features(base)
      Methods.give(base, :bar, :class=>true)
    end

    class Methods < SandboxedMethods
      def bar
        my_name
      end

      # internal_methods
      def my_name
        :bar
      end
    end
  end

  class FooBar
    include Foo
    include Bar
  end

  def test_guard_against_conflictions_of_internal_methods
    assert_equal :foo, FooBar.foo
    assert_equal :bar, FooBar.bar
  end

  def test_guard_against_non_published_method
    assert_raises(NoMethodError) {FooBar.baz}
    assert_raises(NoMethodError) {FooBar.my_name}
  end
end


class SandboxedMethodsPublishAllMethodsTest < Test::Unit::TestCase
  module Foo
    def self.append_features(base)
      Methods.give(base)
    end

    class Methods < SandboxedMethods
      def foo
        :foo
      end

      def bar
        :bar
      end

      def base_access
        base
      end
    end
  end

  class FooBar
    include Foo
  end

  def test_publish_all_methods
    object = FooBar.new
    assert_equal :foo, object.foo
    assert_equal :bar, object.bar
  end

  def test_access_base_object
    object = FooBar.new
    assert_equal FooBar, object.base_access.class
  end
end


class SandboxedMethodsPublishAllMethodsTest < Test::Unit::TestCase
  module Foo
    def self.append_features(base)
      Methods.give(base)
    end

    class Methods < SandboxedMethods
      def foo
        :foo
      end

      def bar
        :bar
      end
    end
  end

  class FooBar
    include Foo
  end

  def test_publish_all_methods
    object = FooBar.new
    assert_equal :foo, object.foo
    assert_equal :bar, object.bar
  end
end


class SandboxedMethodsAccessInstanceVariablesTest < Test::Unit::TestCase
  module Foo
    def self.append_features(base)
      Methods.give(base)
    end

    class Methods < SandboxedMethods
      def initialize(*)
        super
        @name = :foo
        @foo  = :foo
      end

      def base_name_by_method
        name
      end

      def base_name_by_accessor
        self[:name]
      end

      def write_back_by_method
        self.name  = :foo
        self.names = [:foo, :bar]
      end

      def write_back_by_accessor
        self[:name]  = :foo
        self[:names] = [:foo, :bar]
      end
    end
  end

  class FooBar
    include Foo

    attr_accessor :name, :names

    def initialize
      @name  = :base
      @names = []
    end
  end

  def test_guard_against_accessing_instance_variable_defined_in_module
    object = FooBar.new
    assert_equal nil, object.instance_variable_get("@foo")
  end

  def test_guard_against_overwrite_instance_variable_defined_in_base_object
    object = FooBar.new
    assert_equal :base, object.instance_variable_get("@name")
  end

  def test_access_instance_variable_defined_in_base_object_by_method
    object = FooBar.new
    assert_equal :base, object.base_name_by_method
  end

  def test_access_instance_variable_defined_in_base_object_by_accessor
    object = FooBar.new
    assert_equal :base, object.base_name_by_accessor
  end

  def test_write_instance_variable_back_to_base_by_method
    object = FooBar.new
    assert_equal :base, object.name
    assert_equal [],    object.names

    object.write_back_by_method
    assert_equal :foo, object.name
    assert_equal [:foo, :bar], object.names
  end

  def test_write_instance_variable_back_to_base_by_accessor
    object = FooBar.new
    assert_equal :base, object.name
    assert_equal [],    object.names

    object.write_back_by_accessor
    assert_equal :foo, object.name
    assert_equal [:foo, :bar], object.names
  end
end
