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
    @docs = []
  end

  def run
    retrive_doc_data
    write_out
  end

  private

  def retrive_doc_data
    index_page = mech.get('https://docs.ruby-lang.org/ja/latest/library/_builtin.html')
    index_page.css('td.signature>a').each do |a|
      puts "  #{a.text}"
      page = mech.get(a[:href])
      parse_page(page)
    end
  end

  def parse_page(page)
    body = page.at_css('body')
    parse_body body
  end

  def parse_body(body)
    body.children.each do |e|
      case e.name
      when 'h1'
        @type, @class = e.text.split(' ')
      when 'h2'
        @cat = e.inner_html.strip
      when 'dl'
        parse_dl e if whitelist.include? @cat
      end
    end
  end

  def whitelist
    %w(特異メソッド
       インスタンスメソッド
       privateメソッド
       モジュール関数
       特殊変数)
  end

  def parse_dl(dl)
    doc = RubyDoc.new(type: @type, class_name: @class, category: @cat, expressions: [])
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
          @docs << doc
        end
      end
    end
  end

  def absolute_uri(uri)
    URI.join(mech.page.uri, uri)
  end

  def write_out
    CSV.open(@path, 'w') do |csv|
      @docs.each do |d|
        csv << d.to_a
      end
    end
  end

  def mech
    @_mech ||= Mechanize.new
  end

end
