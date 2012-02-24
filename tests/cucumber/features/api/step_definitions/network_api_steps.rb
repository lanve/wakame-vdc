# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end 
require 'cucumber/formatter/unicode'

Before do
  @networks_created = []
end

After do
  @networks_created.each { |network|
    steps %Q{
      When we make an api delete call to networks/#{network} with no options
        Then the previous api call should be successful
    }
  }
end

Given /^a new network with its uuid in <(.+)>$/ do |reg|
  steps %Q{
    When we make an api create call to networks with the following options
      |  network |       gw | prefix | description   |
      | 10.1.2.0 | 10.1.2.1 |     20 | "test create" |
      Then the previous api call should be successful
      And from the previous api call take {"uuid":} and save it to <#{reg}>
  }

  @networks_created << @registry[reg]
end

Given /^a new port in (.+) with its uuid in <(.+)>$/ do |arg_1,reg|
  network = variable_get_value(arg_1)

  # steps %Q{
  #   When we make an api post call to networks/#{network}/ports with no options
  #     Then the previous api call should be successful
  #     And from the previous api call take {"uuid":} and save it to <#{reg}>
  # }

  steps %Q{
    When we make an api post call to networks/#{network}/ports with no options
      Then the previous api call should be successful
      And from the previous api call take {"uuid":} and save it to <#{reg}>
  }
end

Given /^the instance (.+) is connected to the network (.+) with the nic stored in <(.+)>$/ do |arg_1,network,reg|
  instance = variable_get_value(arg_1)

  steps %Q{
    When we make an api get call to instances/#{instance} with no options
      Then the previous api call should be successful
      And from the previous api call take {"vif":[...,,...]} and save it to <#{reg}> for {"network_id":} equal to #{network}
      And from <#{reg}> take {"vif_id":} and save it to <#{reg}uuid>
      And from <#{reg}> take {"port_id":} and save it to <#{reg}port:uuid>
  }
end

When /^we attach to network (.+) port (.+) the attachment (.+)$/ do |arg_1,arg_2,attachment|
  network = variable_get_value(arg_1)
  port = variable_get_value(arg_2)

  steps %Q{
    When we make an api put call to networks/#{network}/ports/#{port}/attach with the following options
      | attachment_id |
      | #{attachment} |
      Then the previous api call should be successful
  }
end

When /^we detach from network (.+) port (.+) its current attachment$/ do |arg_1,arg_2|
  network = variable_get_value(arg_1)
  port = variable_get_value(arg_2)

  steps %Q{
    When we make an api put call to networks/#{network}/ports/#{port}/detach with no options
      Then the previous api call should be successful
  }
end
