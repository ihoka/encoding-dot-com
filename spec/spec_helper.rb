$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'encoding-dot-com'
require 'spec'
require 'spec/autorun'
require 'nokogiri'
require 'encoding_dot_com/facade'

class EncodingXpathMatcher
  def initialize(xpath)
    @xpath = xpath
  end

  def ==(post_vars)
    ! Nokogiri::XML(post_vars[:xml]).xpath(@xpath).empty?
  end
end

Spec::Runner.configure do |config|
  
end
