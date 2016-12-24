# frozen_string_literal: true
require_relative('lib/ruby_doc_generator')
# for avoid ssl error on Windows.
ENV['SSL_CERT_FILE'] = './cacert.pem'
path = ARGV[0] || File.join(File.dirname(__FILE__), 'ruby.csv').to_s
RubyDocGenerator.run(path: path)
puts 'fin.'
