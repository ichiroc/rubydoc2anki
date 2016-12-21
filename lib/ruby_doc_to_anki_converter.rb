# -*- coding: utf-8 -*-
require 'mechanize'
require 'csv'
require 'uri'
require 'digest/md5'

class RubyDocToAnkiConverter
  def initialize(path)
    @path = path
    @data = []
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

  def parse_page page
    page.css('body').each do |body|
      parse_body body
    end
  end

  def parse_body body
    body.children.each do |e|
      case e.name
      when 'h1'
        @type, @class = e.text.split(' ')
      when 'h2'
        @cat = e.inner_html.strip
      when 'dl'
        parse_dl e if ['特異メソッド',
                       'インスタンスメソッド',
                       'privateメソッド',
                       'モジュール関数',
                       '特殊変数'].include? @cat
      end
    end
  end

  def parse_dl dl
    exp = []
    id = ''
    dl.children.each do |d|
      case d.name
      when 'dt'
        exp << d.css('code').inner_html.strip
        permalink = d.at('a[text()="permalink"]')
        id = absolute_uri(permalink[:href]) if permalink
      when 'dd'
        if d.text.strip != ''
          d.css('a').each{ |a| a[:href] = absolute_uri(a[:href]) }
          @data << {
            id: id,
            class: @class,
            type: @type,
            cat: @cat,
            exp: exp.join("<br>"),
            def: d.inner_html.strip
          }
          exp = []
        end
      end
    end
  end

  def absolute_uri(uri)
    URI.join(mech.page.uri, uri)
  end

  def write_out
    CSV.open(@path, 'w') do |csv|
      @data.each do |d|
        csv << [ d[:id], d[:type], d[:class], d[:cat] , d[:exp], d[:def] ]
      end
    end
  end

  def mech
    @_mech = @_mech || Mechanize.new
  end
end
