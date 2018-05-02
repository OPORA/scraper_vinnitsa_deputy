require 'open-uri'
require 'nokogiri'
require_relative './people'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class ScrapeMp
  def parser
    DataMapper.auto_upgrade!
    url = "https://drv.vmr.gov.ua/deputaty.aspx"
    page = get_page(url)
    page.css('#form1 table tr td div  table tr td:nth-child(1)').each do |mp|

      mp.css('table .ELEMENTY_LABEL').each_with_index do |fio, index|
        faction = mp.css("table #ContentPlaceHolder1_ExampleRepeater_LAB_PARTIYA_#{index}").text
        next if faction == "уповноважений"
        okrug = mp.css("table #ContentPlaceHolder1_ExampleRepeater_LAB_OKRUG_#{index}").text
        full_name = fio.text
        photo_url = mp.css("table #ContentPlaceHolder1_ExampleRepeater_IMG_FOTO_#{index}")[0]["src"]
        scrape_mp(full_name, okrug, faction, photo_url)
      end

    end
    #resigned_mp()
    create_mer()
  end
  def create_mer
    #TODO create mer Sadovoy
    names = %w{Моргунов Сергій Анатолійович}
    People.first_or_create(
        first_name: names[1],
        middle_name: names[2],
        last_name: names[0],
        full_name: names.join(' '),
        deputy_id: 1111,
        okrug: nil,
        photo_url: "https://www.vmr.gov.ua/SiteAssets/Lists/CityMajor/Default/Міський голова Сергій Моргунов.jpg",
        faction: nil,
        end_date: nil,
        created_at: "9999-12-31"
    )
  end
  def get_page(url)
    Nokogiri::HTML(open(url, "User-Agent" => "HTTP_USER_AGENT:Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.47"), nil, 'utf-8')
  end
  def resigned_mp
    uri = ""
    page_resigned = get_page(uri)
    scrape_mp( )
  end
  def scrape_mp(fio, okrug, party, image, date_end=nil)
    party = case
              when party[/Солідарність/]
                "Блок Петра Порошенка"
              when party[/Самопоміч/]
                "Самопоміч"
              when party[/Батьківщина/]
                "Батьківщина"
              when party[/Свобода/]
                "Свобода"
              else
                party
            end
    rada_id = image[/\d+/]
    name = fio.gsub(/\s{2,}/,' ')
    image = "http://drv.vmr.gov.ua/" + image.strip
    name_array = name.split(' ')
    people = People.first(
        first_name: name_array[1],
        middle_name: name_array[2],
        last_name: name_array[0],
        full_name: name_array.join(' '),
        deputy_id: rada_id,
        okrug: okrug,
        photo_url: image,
        faction: party,
    )
    unless people.nil?
    people.update(end_date:  date_end,  updated_at: Time.now)
    else
      People.create(
          first_name: name_array[1],
          middle_name: name_array[2],
          last_name: name_array[0],
          full_name: name_array.join(' '),
          deputy_id: rada_id,
          okrug: okrug,
          photo_url: image,
          faction: party,
          end_date:  date_end,
          created_at: Time.now,
          updated_at: Time.now
      )
    end
  end
end
unless ENV['RACK_ENV']
  ScrapeMp.new
end


