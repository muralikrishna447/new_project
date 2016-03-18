require 'rspec/core/formatters/documentation_formatter'
#Straight from http://stackoverflow.com/questions/3808139/print-running-spec-name
class AnxiousFormatter < RSpec::Core::Formatters::DocumentationFormatter
  def example_started(example)
    message = "- #{example.description}"
    output.puts message
    output.flush
  end
end
