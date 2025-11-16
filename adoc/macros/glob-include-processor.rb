# RUBY_ENGINE == 'opal' ? () : (require_relative 'glob-include-processor/extension')
require '/workspace/adoc/macros/glob-include-processor/extension'

Asciidoctor::Extensions.register do
  include_processor GlobIncludeProcessor
end