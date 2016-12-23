require_relative('lib/ruby_doc_generator')
# for avoid ssl error on Windows.
ENV["SSL_CERT_FILE"] = "./cacert.pem"
path = ARGV[0] || "#{File.join(File.dirname(__FILE__),'ruby.csv')}"
RubyDocGenerator.new(path).run
puts 'fin.'
