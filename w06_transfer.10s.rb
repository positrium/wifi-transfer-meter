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
	end

	def yesterday_data_usage
		# <?xml version="1.0" encoding="UTF-8"?>
		# <response>
		#   <ToYestodayDownload>2741729576</ToYestodayDownload>
		#   <ToYestodayUpload>352561768</ToYestodayUpload>
		#   <ToYestodayDuration>258809</ToYestodayDuration>
		#   <ToTodayDownload>4785240748</ToTodayDownload>
		#   <ToTodayUpload>862668626</ToTodayUpload>
		#   <ToTodayDuration>223665</ToTodayDuration>
		#   <IsYestodayFluxOverLimit>0</IsYestodayFluxOverLimit>
		#   <LastClearTime3days>2012-1-1</LastClearTime3days>
		# </response>
	end

	def today_data_usage
		today_download = 0
		today_upload = 0

		@doc.xpath('//response/totodaydownload').each do |e|
			today_download = e.content.to_i(10)
		end

		@doc.xpath('//response/totodayupload').each do |e|
			today_upload = e.content.to_i(10)
		end

		today_data = today_download + today_upload

		scale = transfer_scale(today_data)
		today_usage = today_data.to_f / scale[:size]

		{usage: today_usage.round(2), label: scale[:label]}
	end

	private

	def transfer_scale(byte)
		scale_kb = 1024
		scale_mb = 1024 * 1024
		scale_gb = 1024 * 1024 * 1024
		scale_tb = 1024 * 1024 * 1024 * 1024

		scale = {size: 0, label: ''}

		if scale_mb > byte
			scale[:size] = scale_kb
			scale[:label] = 'KB'
		elsif scale_gb > byte
			scale[:size] = scale_mb
			scale[:label] = 'MB'
		elsif scale_tb > byte
			scale[:size] = scale_gb
			scale[:label] = 'GB'
		else
			scale[:size] = scale_tb
			scale[:label] = 'TB'
		end

		scale
	end

end


a = TransferAmount.new
usage = a.today_data_usage[:usage]
percentage = usage / 10.00 * 100
sign = ""

if percentage >= 90.00
	sign = "🔴"
elsif percentage >= 70.00
	sign = "💛"
else
	sign = "💚"
end

puts "#{sign}#{a.today_data_usage[:usage]}#{a.today_data_usage[:label]}"
