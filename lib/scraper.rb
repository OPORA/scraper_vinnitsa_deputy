require 'open-uri'
require 'nokogiri'
require_relative './people'

class ScrapeMp
  def initialize
    DataMapper.auto_upgrade!
    url = "https://www.lvivrada.gov.ua/deputaty/deputaty-miskoi-rady"
    start_mp = People.all(update_mp: 1)
    start_mp.update(update_mp: 2)
    page = get_page(url)
    page.css('#componentin .catItemTitle a').each do |mp|
      scrape_mp(mp[:href])
    end
    remove_mp = People.all(update_mp: 2)
    remove_mp.update(update_mp: 3)

  end
  def get_page(url)
    Nokogiri::HTML(open(url, "User-Agent" => "HTTP_USER_AGENT:Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.47"), nil, 'utf-8')
  end
  def scrape_mp(mp)
    uri = "https://lvivrada.gov.ua" + mp
    rada_id =mp.split('/').last[/\d{4}/]
    page_mp= get_page(uri)
    name = page_mp.css('h2.itemTitle').text.gsub(/\n/,'').strip
    image_html = page_mp.css('.itemIntroText p a')[0]
    if image_html.nil?
      image = "https://lvivrada.gov.ua" + page_mp.css('.itemIntroText p img')[0][:src]
    else
      image = "https://lvivrada.gov.ua" + page_mp.css('.itemIntroText p a')[0][:href]
    end
    p uri
    p name
    hash = {}
    page_mp.css('.itemFullText p').each do |p|

      next  unless  p.text[/(округ №|округ№)/] or p.text[/(Висунутий|Висунута)/]

      if p.text[/(округ №|округ№)(\s|\d)/]
        hash[:okrug]= p.text[/№(\s|\d)\d+/]
      end
      if p.text[/исунут/]
        ser=p.text.split('.').find{|str| str.include?('исунут')}
        hash[:party ] = ser[/(“|«).+(”|»)/].gsub(/(“|”|»|«)/,'')
      end
    end
    p hash[:party]
    p hash[:okrug]
    if hash[:party].include?("УКРОП")
      party = "УКРОП"
    elsif hash[:party].include?("Народний контроль")
      party = "Народний контроль"
    elsif hash[:party].include?("Солідарність") or  hash[:party].include?("СОЛІДАРНІСТЬ")
      party = "Блок Петра Порошенка"
    elsif hash[:party].include?("Самопоміч")
      party = "Самопоміч"
    else
      party = hash[:party].strip
    end
    if name == 'Веремчук Валерій Миколайович' or name == 'Адамик Петро Михайлович' or name == 'Береза Олег Ігорович'
      okrug = nil
    else
      okrug = hash[:okrug].strip.gsub(/([[:blank:]]|№)/,'')
    end

    name_array= name.split(' ')
    people = People.first(
        first_name: name_array[1],
        middle_name: name_array[2],
        last_name: name_array[0],
        full_name: name_array.join(' '),
        rada_id: rada_id,
        okrug: okrug,
        photo_url: image,
        fraction: party,
    )
    unless people.nil?
    people.update(updated_at: Time.now, update_mp: 1)
    else
      People.create(
          first_name: name_array[1],
          middle_name: name_array[2],
          last_name: name_array[0],
          full_name: name_array.join(' '),
          rada_id: rada_id,
          okrug: okrug,
          photo_url: image,
          fraction: party,
          update_mp: 1,
          created_at: Time.now,
          updated_at: Time.now
      )
    end
  end
end
unless ENV['RACK_ENV']
  ScrapeMp.new
end


