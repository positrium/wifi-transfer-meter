#!/usr/bin/env ruby

# <bitbar.title>Speedwifi-next W06 transfer amount during 1day</bitbar.title>
# <bitbar.version>1.0.1</bitbar.version>
# <bitbar.author>positrium</bitbar.author>
# <bitbar.author.github>positrium</bitbar.author.github>
# <bitbar.desc>show Speedwifi-next w06 transfer amount during 1day for bitbar.</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/positrium/wifi-transfer-meter/master/image20200122.png</bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/positrium/wifi-transfer-meter</bitbar.abouturl>

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

		false if limited == 0
		true if limited != 0
	end

	def has_error?
		@has_error
	end
end

class ViewState

	def initialize(amount, symbols={over: "x", warn: "!", ok: "o", limited: "-"}, limited=false)
		@amount = amount.freeze
		@percentage = ((amount.to_f / (10*1024*1024*1024).to_f) * 100).freeze
		@symbols = symbols.freeze
		@limited = limited.freeze

		@max_usage = (1024*1024*1024*10).freeze
		@scale = {
			mb: 1024 * 1024,
			gb: 1024 * 1024 * 1024,
			tb: 1024 * 1024 * 1024 * 1024
		}.freeze
	end

	def sign
		if @limited
			@symbols[:limited]
		elsif @percentage < 70.0
			@symbols[:ok]
		elsif @percentage < 100.0
			@symbols[:warn]
		else
			@symbols[:over]
		end
	end

	def usage
		value = detect_scale(@amount)
		"#{value[:size]}#{value[:label]}"
	end

	def left
		left_value = @max_usage - @amount
		value = (left_value/@scale[:mb].to_f).floor
		if value >= 0
			"#{value}MB"
		else
			"0MB"
		end
	end

	private

	def detect_scale(byte)
		info = {size: 0, label: ''}
 
		if @scale[:gb] > byte
			info = {size: (byte/@scale[:mb].to_f).floor(2), label: 'MB'}
		elsif @scale[:tb] > byte
			info = {size: (byte/@scale[:gb].to_f).floor(2), label: 'GB'}
		end

		info
	end
end

transfer = TransferState.new

if transfer.has_error?
	puts "<!> connect to w06"

else
	symbols = {over: ":broken_heart:", warn: ":yellow_heart:", ok: ":green_heart:", limited: ":no_entry_sign:"}.freeze

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
	puts "--#{symbols[:limited]} restricted now"
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
