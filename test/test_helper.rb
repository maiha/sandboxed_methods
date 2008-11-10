require 'test/unit'
def __DIR__(*args) File.join(File.dirname(__FILE__), *args) end

ENV['RAILS_ENV'] = 'test'
require __DIR__('../../../../config/environment')

$:.unshift __DIR__('../lib') if File.directory? __DIR__('../lib')

# logger = Logger.new __DIR__("debug.log")
# ActiveRecord::Base.logger     = logger
