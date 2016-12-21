require_relative('lib/ruby_doc_to_anki_converter')
# for avoid ssl error on Windows.
ENV["SSL_CERT_FILE"] = "./cacert.pem"
RubyDocToAnkiConverter.new(ARGV[0]).run
puts 'fin.'
