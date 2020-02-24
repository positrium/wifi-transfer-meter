# -*- frozen_string_literal: true -*-

RSpec.describe ViewState do
    GiB = 1024*1024*1024

    let(:symbols){
        hash = {}
        hash[:ok] = 'o'
        hash[:warn] = '!'
        hash[:over] = 'x'
        hash[:soon] = '~'
        hash[:limited] = '-'
        hash
    }

    let(:limited){ true }

    let(:zero){ 0 }
    let(:the1GiB_sub1){ 1*GiB-1}
    let(:the1GiB){ 1*GiB }
    let(:the1GiB_add1){ 1*GiB+1 }
    let(:the7GiB_sub1){ 7*GiB-1 }
    let(:the7GiB){ 7*GiB }
    let(:the7GiB_add1){ 7*GiB+1}
    let(:the10GiB_sub1){ 10*GiB-1 }
    let(:the10GiB){ 10*GiB }
    let(:the10GiB_add1){ 10*GiB+1 }

    describe '#sign' do
        context 'usage is 0GB' do
            it 'returns o' do
                state = ViewState.new(zero, symbols)
                expect(state.sign).to eq 'o'
            end
        end

        context 'usage is 7GiB - 1' do
            it 'returns o' do
                state = ViewState.new(the7GiB_sub1, symbols)
                expect(state.sign).to eq 'o'
            end
        end

        context 'usage is 7GiB + 1' do
            it 'returns !' do
                state = ViewState.new(the7GiB_add1, symbols)
                expect(state.sign).to eq '!'
            end
        end

        context 'usage is 10GiB - 1' do
            it 'returns !' do
                state = ViewState.new(the10GiB_sub1, symbols)
                expect(state.sign).to eq '!'
            end
        end

        context 'usage is 10GiB + 1' do
            it 'returns x' do
                state = ViewState.new(the10GiB_add1, symbols)
                expect(state.sign).to eq 'x'
            end
        end

        context 'connection in limited' do
            it 'returns ~ at 03 oclock' do
                state = ViewState.new(zero, symbols, limited, hour=3)
                expect(state.sign).to eq '~'
            end

            it 'returns ~ at 17 oclock' do
                state = ViewState.new(zero, symbols, limited, hour=17)
                expect(state.sign).to eq '~'
            end

            it 'returns - at 18 oclock' do
                state = ViewState.new(zero, symbols, limited, hour=18)
                expect(state.sign).to eq '-'
            end

            it 'returns - at 02 oclock' do
                state = ViewState.new(zero, symbols, limited, hour=2)
                expect(state.sign).to eq '-'
            end
        end
    end

    describe '#usage' do
        context 'usage is 1GiB - 1' do
            it 'returns GB unit' do
                state = ViewState.new(the1GiB_sub1)
                expect(state.usage).to eq '0.99GB'
            end
        end

        context 'usage is 1GiB' do
            it 'returns GB float unit' do
                state = ViewState.new(the1GiB)
                expect(state.usage).to eq '1.0GB'
            end
        end

        context 'usage is 1GiB + 1' do
            it 'returns GB float unit' do
                state = ViewState.new(the1GiB_add1)
                expect(state.usage).to eq '1.0GB'
            end
        end
    end

    describe '#left' do
        context 'usage is 0' do
            it 'returns 7168MB' do
                state = ViewState.new(zero)
                expect(state.left).to eq "7168MB"
            end
        end

        context 'usage is 7GiB - 1' do
            it 'returns 0MB' do
                state = ViewState.new(the7GiB_sub1)
                expect(state.left).to eq "0MB"
            end
        end

        context 'usage is 7GiB' do
            it 'returns 3072MB' do
                state = ViewState.new(the7GiB)
                expect(state.left).to eq '3072MB'
            end
        end

        context 'usage is 7GiB + 1' do
            it 'returns 3071MB' do
                state = ViewState.new(the7GiB_add1)
                expect(state.left).to eq "3071MB"
            end
        end

        context 'usage is 10GiB - 1' do
            it 'returns 0MB' do
                state = ViewState.new(the10GiB_sub1)
                expect(state.left).to eq '0MB'
            end
        end

        context 'usage is 10GiB' do
            it 'returns 0MB' do
                state = ViewState.new(the10GiB)
                expect(state.left).to eq '0MB'
            end
        end

        context 'usage is 10GiB + 1' do
            it 'returns 0MB' do
                state = ViewState.new(the10GiB_add1)
                expect(state.left).to eq '0MB'
            end
        end
    end

end
