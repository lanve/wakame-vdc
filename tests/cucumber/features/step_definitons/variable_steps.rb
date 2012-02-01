# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end 
require 'cucumber/formatter/unicode'

Before do
  @new_registry = {}
end

After do
end

# Then (new) <registry:foo> should have {"network_id":} equal to "nw-demo2"
# Then (new) <registry:foo> should have {"count":} equal to 23
# Then (new) <registry:foo> should have {"attachment":} is a hash
# Then (new) <registry:foo> should have {"attachment":} equal to the following
#   || (?)
# Then (new) <registry:foo> should have {"attachment":} equal to {} (?)
# Then (new) <registry:foo> should have {"attachment":{"id":}} equal to <registry:bar>

# Then (new) <registry:foo> should have [{"network_id":}] equal to "nw-demo2"
# Then (new) <registry:foo> should have [{"network_id":},...] equal to "nw-demo2"

# Then (new) <registry:foo> should have [] equal to the following
#   | id | name |
#   |  1 | foo  |

def variable_get_value arg_value
  case arg_value
  when /^".*"$/
    arg_value[/^"(.*)"$/, 1]
  when /^[0-9]+$/
    arg_value.to_i
  when /^<registry:.+>$/
    # Old registry, replace.
    @registry[arg_value[/^<registry:(.+)>$/, 1]]
  else
    nil
  end
end

def variable_compare operator, left, right
  case operator
  when 'equal to'
    left == right
  when 'with a size of'
    left.size == right
  else
    nil
  end
end

def variable_apply_template registry, template, operator, value
  case template
  when /^\{\}$/
    registry.kind_of?(Hash).should be_true
    variable_compare(operator, registry, value)

  when /^\[\]$/
    registry.kind_of?(Array).should be_true
    variable_compare(operator, registry, value)

  when /^\{".+":\}$/
    key = template[/^\{"(.+)":\}$/, 1]
    registry.has_key?(key).should be_true
    variable_compare(operator, registry[key], value)

  when /^\{".+":.+\}$/
    match = /^\{"(.+)":(.+)\}$/.match(template)
    registry.has_key?(match[1]).should be_true
    variable_apply_template(registry[match[1]], match[2], operator, value)

  when /^\[.+\]$/
    match = /^\[(.+)\]$/.match(template)
    (registry.kind_of?(Array) and registry.size == 1).should be_true
    variable_compare(operator, registry.first, value)

  else
    nil
  end
end

Then /^<([^>]+)> [ ]*(should|should\snot) have (.+) (equal to|with a size of) (.+)$/ do |registry,outcome,template,operator,arg_value|
  value = variable_get_value(arg_value)
  value.nil?.should be_false
  registry.nil?.should be_false

  variable_apply_template(@new_registry[registry], template, operator, value).should == (outcome == 'should not' ? false : true)
end

# Helper functions, move to appropriate file or make a hash relation
# between descriptons and registry keys.
Then /^the previous api call [ ]*(should|should\snot) have (.+) (equal to|with a size of) (.+)$/ do |outcome,template,operator,arg_value|
  steps %Q{
    Then <api:latest> #{outcome} have #{template} #{operator} #{arg_value}
  }  
end
