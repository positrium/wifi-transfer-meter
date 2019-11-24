#!/usr/bin/env ruby

# <bitbar.title>Speedwifi-next W06 transfer amount during 3days</bitbar.title>
# <bitbar.author>positrium</bitbar.author>
# <bitbar.author.github>positrium</bitbar.author.github>
# <bitbar.version>1.0</bitbar.version>

require 'open-uri'
require 'nokogiri'


class TransferAmount
	def initialize
		@has_error = false

		@scale = {
			kb: 1024,
			mb: 1024 * 1024,
			gb: 1024 * 1024 * 1024,
			tb: 1024 * 1024 * 1024 * 1024
		}
		@scale.freeze

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

		@doc = Nokogiri.HTML(open("http://speedwifi-next.home/api/monitoring/statistics_3days"))
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
	rescue => error
		@has_error = true
	end

	def yesterday_data_usage
		yesterday_data = @payload[:yesterday_download].to_i + @payload[:yesterday_upload].to_i

		scale = transfer_scale(yesterday_data)
		yesterday_usage = ( yesterday_data.to_f / scale[:size] ).round(2)

		{amount: yesterday_usage, label: scale[:label], percentage: yesterday_usage / 10.00 * 100}
	end

	def today_data_usage
		today_data = @payload[:today_download].to_i + @payload[:today_upload].to_i

		scale = transfer_scale(today_data)
		today_usage = ( today_data.to_f / scale[:size] ).round(2)

		{amount: today_usage, label: scale[:label], percentage: today_usage / 10.00 * 100}
	end

	def limited?
		limited = @payload[:is_yesterday_flux_over_limit].to_i

		false if limited == 0
		true if limited != 0
	end

	def has_error?
		@has_error
	end

	private

	def transfer_scale(byte)
		scale_info = {size: 0, label: ''}

		if @scale[:mb] > byte
			scale_info[:size] = @scale[:kb]
			scale_info[:label] = 'KB'
		elsif @scale[:gb] > byte
			scale_info[:size] = @scale[:mb]
			scale_info[:label] = 'MB'
		elsif @scale[:tb] > byte
			scale_info[:size] = @scale[:gb]
			scale_info[:label] = 'GB'
		else
			scale_info[:size] = @scale[:tb]
			scale_info[:label] = 'TB'
		end

		scale_info
	end

end


a = TransferAmount.new

if a.has_error?
	puts "<!> connect to w06"
else
	usage = a.today_data_usage
	y_usage = a.yesterday_data_usage
	sign = ""
	left_value = ""

	if usage[:percentage] >= 33.00
		sign = ":broken_heart:"
	elsif usage[:percentage] >= 23.10
		sign = ":yellow_heart:"
		left_value = "(#{(3.33-usage[:amount]).round(2)}GB left)"
	else
		sign = ":green_heart:"
		left_value = "(#{(2.31-usage[:amount]).round(2)}GB left)"
	end

	if a.limited?
		sign = ":children_crossing:"
	end

	puts "#{sign}#{usage[:amount]}#{usage[:label]} #{left_value}" # 3 days until today
	puts "---"
	puts "usage"
	puts "--limited now is :children_crossing:"
	puts "--over 3.33GB is :broken_heart:"
	puts "--over 2.31GB is :yellow_heart:"
	puts "--under 2.31GB is :green_heart:"
	puts "admin|href=http://speedwifi-next.home"
	puts "---"

	if a.limited?
		puts "limited now|color=red"
	elsif y_usage[:percentage] >= 66.00
		puts "WARNING !|color=#333"
	end
	if y_usage[:percentage] >= 66.00
		puts "--until yesterday: #{y_usage[:amount]}#{y_usage[:label]}|color=#333" # 3 days until yesterday
	end
end
