require 'digest/md5'
require 'faraday'

module Smsc
  #Класс реализует отправку смс сообщений
  class Sms
    attr_reader :options, :connection

    # Public: Создет новый объект класса Smsc::Sms
    #
    #   login    - String, логин пользовотеля smsc
    #   password - String, пароль пользователя smsc
    #   charset  - String, кодировка сообщения:
    #     utf-8 (default)
    #     kio8-r
    #     windows-1251
    #
    # Returns Smsc::Sms
    def initialize(login, password, charset = 'utf-8')
      password = Digest::MD5.hexdigest(password.to_s)
      connection = Faraday.new(url: 'https://smsc.ru') do |i|
        i.request  :url_encoded
        i.response :logger
        i.adapter  Faraday.default_adapter
      end

      @options = { login: login, psw: password, charset: charset }
    end

    # Public: Метод отаправляет смс сообщение
    #
    #   message - String, текст сообщения
    #   phones  - Array, массив строк с номерами телефонов
    #   options - Hash, с опциями отправляемого сообщения(optional):
    #     :time - Время отправки SMS-сообщения абоненту:
    #      - 'DDMMYYhhmm' или 'DD.MM.YY hh:mm'
    #      - 'h1-h2' Задает диапазон времени в часах. Если текущее время меньше h1,
    #         то SMS-сообщение будет отправлено абоненту при наступлении времени h1,
    #         если текущее время попадает в промежуток от h1 до h2, то сообщение будет
    #         отправлено немедленно, в другом случае отправка будет выполнена на следующий
    #         день при достижении времени h1.
    #       - 0ts, где ts – точное время отправки сообщения в unix time
    #       - +m. Задает относительное смещение времени от текущего в минутах. Символ + должен кодироваться как %2B в http-запросе.
    #     :tz - Часовой пояс, в котором задается параметр time(default: часовой пояс пользователя).
    #           Указывается относительно московского времени:
    #           +x - плюс x часов к московскому времени
    #           -x - минус x часов относительно московского времени
    #            0 - московское время
    #
    #
    #     полный список опций http://smsc.ru/api/http/
    #
    # Examples
    #
    #   #простая отправка сообщения
    #   message('ping', ['+79122965554']) # => Faraday::Response
    #
    #   #сообщение придет адресаду между 10 и 12 утра по екатеринбургскому времени
    #   message('ping', ['+79122965554'], time: '10-12', tz: '+2') # => Faraday::Response
    #
    # Returns Faraday::Response
    def message(message, phones, opt = {})
      opt.merge! @options.megre({phones: phones.join(','), mes: message})
      connection.post '/sys/send.php', opt
    end
  end
end