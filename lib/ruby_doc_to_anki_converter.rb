# -*- coding: utf-8 -*-
# frozen_string_literal: true
require 'mechanize'
require 'csv'
require 'uri'
require 'digest/md5'
require_relative 'ruby_doc'

class RubyDocToAnkiConverter
  def initialize(path)
    @path = path
  end

  def run
    docs = retrive_doc_data
    write_out docs
  end

  private

  def write_out(docs)
    CSV.open(@path, 'w') do |csv|
      docs.each do |d|
        csv << d.to_a
      end
    end
  end

  def retrive_doc_data
    all_docs = []
    index_page = mech.get('https://docs.ruby-lang.org/ja/latest/library/_builtin.html')
    index_page.css('td.signature>a').each do |a|
      puts "  #{a.text}"
      page = mech.get(a[:href])
      all_docs += extract_docs(page)
    end
    all_docs
  end

  def extract_docs(page)
    docs = []
    class_type, class_name, member_type = ''
    page.at_css('body').children.each do |e|
      case e.name
      when 'h1'
        class_type, class_name = e.text.split(' ')
      when 'h2'
        member_type = e.inner_html.strip
      when 'dl'
        docs += extract_member_docs(class_type, class_name, member_type, e) if whitelist.include? member_type
      end
    end
    docs
  end

  def extract_member_docs(class_type, class_name, member_type, dl)
    docs = []
    doc = RubyDoc.new(class_type: class_type, class_name: class_name, member_type: member_type, expressions: [])
    dl.children.each do |d|
      d.css('a').each { |a| a[:href] = absolute_uri(a[:href]) }
      case d.name
      when 'dt'
        doc.expressions << d.css('code').inner_html.strip
        permalink = d.at('a[text()="permalink"]')
        doc.uri = permalink[:href] if permalink
      when 'dd'
        if d.text.strip != ''
          doc.description = d.inner_html.strip
          docs << doc
        end
      end
    end
    docs
  end

  def absolute_uri(uri)
    URI.join(mech.page.uri, uri)
  end

  def whitelist
    %w(特異メソッド
       インスタンスメソッド
       privateメソッド
       モジュール関数
       特殊変数)
  end

  def mech
    @_mech ||= Mechanize.new
  end
end
