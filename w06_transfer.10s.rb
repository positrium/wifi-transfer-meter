#!/usr/bin/env ruby

# <bitbar.title>Speedwifi-next W06 transfer amount during 3days</bitbar.title>
# <bitbar.author>positrium</bitbar.author>
# <bitbar.author.github>positrium</bitbar.author.github>
# <bitbar.version>1.0</bitbar.version>

require 'open-uri'
require 'nokogiri'


class TransferAmount
	def initialize
		@doc = Nokogiri.HTML(open("http://speedwifi-next.home/api/monitoring/statistics_3days"))

		@scale = {
			kb: 1024,
			mb: 1024 * 1024,
			gb: 1024 * 1024 * 1024,
			tb: 1024 * 1024 * 1024 * 1024
		}
		@scale.freeze

		@payload = {
			yesterday_download: -99,
			yesterday_upload: -99,
			yesterday_duration: -99,
			today_download: -99,
			today_upload: -99,
			today_duration: -99,
			is_yesterday_flux_over_limit: -99,
			last_clear_time_3days: -99
		}

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
	end

	def yesterday_data_usage
		yesterday_data = @payload[:yesterday_download].to_i(10) + @payload[:yesterday_upload].to_i(10)

		scale = transfer_scale(yesterday_data)
		yesterday_usage = ( yesterday_data.to_f / scale[:size] ).round(2)

		{amount: yesterday_usage, label: scale[:label], percentage: yesterday_usage / 10.00 * 100}
	end

	def today_data_usage
		today_data = @payload[:today_download].to_i(10) + @payload[:today_upload].to_i(10)

		scale = transfer_scale(today_data)
		today_usage = ( today_data.to_f / scale[:size] ).round(2)

		{amount: today_usage, label: scale[:label], percentage: today_usage / 10.00 * 100}
	end

	def limited?
		limited = @payload[:is_yesterday_flux_over_limit].to_i

		false if limited == 0
		true if limited != 0
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
y_usage = a.yesterday_data_usage
sign = ""

if y_usage[:percentage] >= 90.00 || a.limited?
	sign = ":broken_heart:"
elsif y_usage[:percentage] >= 70.00
	sign = ":yellow_heart:"
else
	sign = ":green_heart:"
end

puts "#{sign}#{y_usage[:amount]}#{y_usage[:label]}"

puts "---"

usage = a.today_data_usage

puts "today: #{usage[:amount]}#{usage[:label]}"
