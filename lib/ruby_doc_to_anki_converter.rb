# -*- coding: utf-8 -*-
require 'mechanize'
require 'csv'

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
      puts a.text
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
        @class = e.text
      when 'h2'
        @cat = e.inner_html.strip
      when 'dl'
        parse_dl e unless ['目次', '要約'].include? @cat
      end
    end
  end

  def parse_dl dl
    exp = []
    dl.children.each do |d|
      case d.name
      when 'dt'
        exp << d.css('code').inner_html.strip
      when 'dd'
        if d.text.strip != ''
          @data << {
            class: @class,
            cat: @cat,
            exp: exp.join("<br>"),
            def: d.inner_html.strip
          }
          exp = []
        end
      end
    end
  end

  def write_out
    CSV.open(@path, 'w') do |csv|
      @data.each do |d|
        csv << [ d[:class], d[:cat] , d[:exp], d[:def] ]
      end
    end
  end

  def mech
    @_mech = @_mech || Mechanize.new
  end
end
