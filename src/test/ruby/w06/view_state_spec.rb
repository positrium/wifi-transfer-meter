# -*- frozen_string_literal: true -*-

RSpec.describe ViewState do
    let(:ok_usage){
        hash = {}
        hash[:start] = 0
        hash[:end] = 7*1024*1024*1024-1
        hash
    }
    let(:warn_usage){
        hash = {}
        hash[:start] = 7*1024*1024*1024
        hash[:end] = 10*1024*1024*1024-1
        hash
    }
    let(:over_usage){
        hash = {}
        hash[:start] = 10*1024*1024*1024
        hash[:end] = 50*1024*1024*1024
        hash
    }
    let(:symbols){
        hash = {}
        hash[:over] = 'x'
        hash[:warn] = '!'
        hash[:ok] = 'o'
        hash[:limited] = '-'
        hash
    }
    let(:unlimited){false}
    let(:limited){true}
    let(:the0p9GB){1024*1024*1024 * 0.9}
    let(:the6000MB){1024*1024*1024 * 6}
    let(:the6p9GB){1024*1024*1024 * 6.9}
    let(:the7GB){1024*1024*1024 * 7}
    let(:grater1GB){1024*1024*1024 * 1}
    let(:the1p5GB){1024*1024*1024 * 1.5}
    let(:the7000MB){1024*1024*1024 * 7}
    let(:the7p1GB){1024*1024*1024 * 7.1}
    let(:the9p9GB){1024*1024*1024 * 9.9}
    let(:the10p0GB){1024*1024*1024 * 10}
    let(:the10p1GB){1024*1024*1024 * 11}

    describe '#sign' do
        context 'usage is less than 7000MiB' do
            it 'returns o' do
                state = ViewState.new(ok_usage[:start], symbols, unlimited)
                expect(state.sign).to eq 'o'
            end

            it 'returns o' do
                state = ViewState.new(ok_usage[:end], symbols, unlimited)
                expect(state.sign).to eq 'o'
            end
        end

        context 'usage is grater than 7000MiB' do
            it 'returns !' do
                state = ViewState.new(warn_usage[:start], symbols, unlimited)
                expect(state.sign).to eq '!'
            end
            it 'returns !' do
                state = ViewState.new(warn_usage[:end], symbols, unlimited)
                expect(state.sign).to eq '!'
            end
        end

        context 'usage is over 10000MiB' do
            it 'returns x' do
                state = ViewState.new(over_usage[:start], symbols, unlimited)
                expect(state.sign).to eq 'x'
            end
            it 'returns x' do
                state = ViewState.new(over_usage[:end], symbols, unlimited)
                expect(state.sign).to eq 'x'
            end
        end

        context 'connection is limited' do
            it 'returns -' do
                state = ViewState.new(over_usage[:end], symbols, limited)
                expect(state.sign).to eq '-'
            end
        end
    end

    describe '#usage' do
        context 'usage is less than 1000MiB' do
            it 'returns MB unit' do
                state = ViewState.new(0, symbols, unlimited)
                expect(state.usage).to eq '0.0MB'
            end
            it 'returns MB unit' do
                state = ViewState.new(the0p9GB, symbols, unlimited)
                expect(state.usage).to eq '921.6MB'
            end
        end

        context 'usage is grater than 1GB' do
            it 'returns GB float unit' do
                state = ViewState.new(grater1GB, symbols, unlimited)
                expect(state.usage).to eq '1.0GB'
            end
            it 'returns GB float unit' do
                state = ViewState.new(the1p5GB, symbols, unlimited)
                expect(state.usage).to eq '1.5GB'
            end
            it 'returns GB float unit' do
                state = ViewState.new(the9p9GB, symbols, unlimited)
                expect(state.usage).to eq '9.9GB'
            end
            it 'returns GB float unit' do
                state = ViewState.new(the10p0GB, symbols, unlimited)
                expect(state.usage).to eq '10.0GB'
            end
        end
    end

    describe '#left' do
        context 'usage is 900MiB' do
            it 'returns 6246MB' do
                state = ViewState.new(the0p9GB, symbols, unlimited)
                expect(state.left).to eq "6246MB"
            end
        end

        context 'usage is 7000MiB' do
            it 'returns 3072MB' do
                state = ViewState.new(the7GB, symbols, unlimited)
                expect(state.left).to eq '3072MB'
            end
        end

        context 'usage is 6000MiB' do
            it 'returns 1024MB' do
                state = ViewState.new(the6000MB, symbols, unlimited)
                expect(state.left).to eq "1024MB"
            end
        end

        context 'usage is 6900MiB' do
            it 'returns 102MB' do
                state = ViewState.new(the6p9GB, symbols, unlimited)
                expect(state.left).to eq '102MB'
            end
        end

        context 'usage is 7100MiB' do
            it 'returns 2969MB' do
                state = ViewState.new(the7p1GB, symbols, unlimited)
                expect(state.left).to eq '2969MB'
            end
        end

        context 'usage is 9900MiB' do
            it 'returns 102MB' do
                state = ViewState.new(the9p9GB, symbols, unlimited)
                expect(state.left).to eq '102MB'
            end
        end

        context 'usage is over 10GiB' do
            it 'returns 0MB' do
                state = ViewState.new(the10p1GB, symbols, unlimited)
                expect(state.left).to eq '0MB'
            end
        end
    end

end
