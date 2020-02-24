require 'open-uri'
require 'nokogiri'

class TransferState
    def initialize(url='http://speedwifi-next.home/api/monitoring/statistics_3days')

        @has_error = false

        @payload = {
            yesterday_download: -9,
            yesterday_upload: -9,
            yesterday_duration: -9,
            today_download: -9,
            today_upload: -9,
            today_duration: -9,
            is_yesterday_flux_over_limit: -9,
            last_clear_time_3days: -9
        }

        @doc = Nokogiri.HTML(URI.open(url))
        @doc.xpath('//response/*').each do |e|
            case e.name
            when 'toyestodaydownload'
                @payload[:yesterday_download] = e.children[0].text
            when 'toyestodayupload'
                @payload[:yesterday_upload] = e.children[0].text
            when 'toyestodayduration'
                @payload[:yesterday_duration] = e.children[0].text
            when 'totodaydownload'
                @payload[:today_download] = e.children[0].text
            when 'totodayupload'
                @payload[:today_upload] = e.children[0].text
            when 'totodayduration'
                @payload[:today_duration] = e.children[0].text
            when 'isyestodayfluxoverlimit'
                @payload[:is_yesterday_flux_over_limit] = e.children[0].text
            when 'lastcleartime3days'
                @payload[:last_clear_time_3days] = e.children[0].text
            end
        end
        @payload.freeze
    rescue
        @has_error = true
    end


    def today_usage
        @payload[:today_download].to_i + @payload[:today_upload].to_i
    end

    def yesterday_usage
        @payload[:yesterday_download].to_i + @payload[:yesterday_upload].to_i
    end

    def limited?
        limited = @payload[:is_yesterday_flux_over_limit].to_i

        limited == 0 ? false : true
    end

    def has_error?
        @has_error
    end
end

class ViewState
    MAX_USAGE = 1024*1024*1024*10
    WARN_USAGE = 1024*1024*1024*7
    SCALE = {
        mb: 1024 * 1024,
        gb: 1024 * 1024 * 1024,
        tb: 1024 * 1024 * 1024 * 1024
    }

    def initialize(usage, symbols={ok: 'o', warn: '!', over: 'x', soon: '~', limited: '-'}, limited=false, hour=Time.now.hour)
        @usage = usage
        @percentage = ((usage.to_f / (MAX_USAGE).to_f) * 100).floor
        @symbols = symbols
        @limited = limited
        @hour = hour
    end

    def sign
        _sign = @symbols[:over] if 100 <= @percentage
        _sign = @symbols[:warn] if @percentage.between?(70, 99)
        _sign = @symbols[:ok] if @percentage.between?(0, 69)

        if @limited
            _sign = @symbols[:soon]
            _sign = @symbols[:limited] if @hour.between?(18, 24) or @hour.between?(0, 2)
        end

        _sign
    end

    def usage
        value = detect_scale(@usage)
        "#{value[:size]}#{value[:label]}"
    end

    def left
        border_usage = MAX_USAGE
        border_usage = WARN_USAGE if @percentage < 70

        left_value = border_usage - @usage
        value = (left_value/SCALE[:mb].to_f).floor

        0 <= value ? "#{value}MB" : "0MB"
    end

    private

    def detect_scale(byte)
        {size: (byte/SCALE[:mb].to_f).floor(2), label: 'MB'}.freeze if byte < SCALE[:gb]
        {size: (byte/SCALE[:gb].to_f).floor(2), label: 'GB'}.freeze if byte < SCALE[:tb]
    end
end

transfer = TransferState.new

if transfer.has_error?
    puts "<!> connect to w06"

else
    symbols = {
        over: ":broken_heart:",
        warn: ":yellow_heart:",
        ok: ":green_heart:",
        limited: ":children_crossing:",
        soon: ":purple_heart:"
    }.freeze

    usage = transfer.today_usage
    vt = ViewState.new(usage, symbols, transfer.limited?)

    y_usage = transfer.yesterday_usage
    vy = ViewState.new(y_usage, symbols, false)

    puts "#{vt.sign}#{vt.left}(#{vt.usage})"
    puts "---"
    puts "admin page|href=http://speedwifi-next.home"
    puts "hardware page|href=https://www.uqwimax.jp/wimax/products/w06/"
    puts "---"
    puts "until today usage"
    puts "#{vt.sign}#{vt.usage}"
    puts "--#{symbols[:limited]} restricted between 18:00 and 03:00"
    puts "--#{symbols[:soon]} restrictions relax until 18:00"
    puts "--#{symbols[:over]} over 10GB (100%)"
    puts "--#{symbols[:warn]} over  7GB ( 70%)"
    puts "--#{symbols[:ok]} less 7GB"
    puts "--today + 1 day ago + 2 days ago"
    puts "until yesterday usage"
    puts "#{vy.sign}#{vy.usage}"
    puts "--#{symbols[:over]} over 10GB (100%)"
    puts "--#{symbols[:warn]} over  7GB ( 70%)"
    puts "--#{symbols[:ok]} less  7GB"
    puts "--1 day ago + 2 days ago + 3 days ago"
end
