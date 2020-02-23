
require 'webmock/rspec'


RSpec.describe TransferState do
    let(:response_xml){
        '<?xml version="1.0" encoding="UTF-8"?>
        <response>
        <ToYestodayDownload>5084839273</ToYestodayDownload>
        <ToYestodayUpload>282627442</ToYestodayUpload>
        <ToYestodayDuration>189589</ToYestodayDuration>
        <ToTodayDownload>7853421415</ToTodayDownload>
        <ToTodayUpload>503139950</ToTodayUpload>
        <ToTodayDuration>245263</ToTodayDuration>
        <IsYestodayFluxOverLimit>1</IsYestodayFluxOverLimit>
        <LastClearTime3days>2019-12-20</LastClearTime3days>
        </response>'
    }
    before do
        stub_request(:get, "www.example.com").to_return(body: response_xml)
    end

    describe '#today_usage' do
        context 'grater than 1GB' do
            it 'output bytes' do
                amount = TransferState.new('http://www.example.com/')
                expect(amount.today_usage).to eq 7853421415+503139950
            end
        end
    end

    describe '#yesterday_usage' do
        context 'grater than 1GB' do
            it 'output bytes' do
                amount = TransferState.new('http://www.example.com/')
                expect(amount.yesterday_usage).to eq 5084839273+282627442
            end
        end
    end

    describe '#limited?' do
        context 'connection limited' do
            it 'output true' do
                amount = TransferState.new('http://www.example.com/')
                expect(amount.limited?).to eq true
            end
        end
    end

    describe '#has_error?' do
        context 'has connect error' do
            it 'output message' do
                amount = TransferState.new('ssss://www.example.com/')
                expect(amount.has_error?).to eq true
            end
        end
    end

end
