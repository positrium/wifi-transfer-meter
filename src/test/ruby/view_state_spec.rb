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
    let(:less1GB){1024*1024*1024-1}
    let(:grater1GB){1024*1024*1024}
    let(:the1p5GB){1024*1024*1024*1.5}
    let(:the7GB){1024*1024*1024*7}
    let(:the9p9GB){1024*1024*1024*10-1}
    let(:the10p0GB){1024*1024*1024*10}
    let(:the10p1GB){1024*1024*1024*11}

    describe '#sign' do
        context 'usage is ok' do
            it 'returns o' do
                state = ViewState.new(ok_usage[:start], symbols, unlimited)
                expect(state.sign).to eq 'o'
            end

            it 'returns o' do
                state = ViewState.new(ok_usage[:end], symbols, unlimited)
                expect(state.sign).to eq 'o'
            end
        end

        context 'usage is warn' do
            it 'returns !' do
                state = ViewState.new(warn_usage[:start], symbols, unlimited)
                expect(state.sign).to eq '!'
            end
            it 'returns !' do
                state = ViewState.new(warn_usage[:end], symbols, unlimited)
                expect(state.sign).to eq '!'
            end
        end

        context 'usage is over' do
            it 'returns x' do
                state = ViewState.new(over_usage[:start], symbols, unlimited)
                expect(state.sign).to eq 'x'
            end
            it 'returns x' do
                state = ViewState.new(over_usage[:end], symbols, unlimited)
                expect(state.sign).to eq 'x'
            end
        end

        context 'limited' do
            it 'returns -' do
                state = ViewState.new(over_usage[:end], symbols, limited)
                expect(state.sign).to eq '-'
            end
        end
    end

    describe '#usage' do
        context 'usage is less than 1GB' do
            it 'returns MB unit' do
                state = ViewState.new(0, symbols, unlimited)
                expect(state.usage).to eq '0.0MB'
            end
            it 'returns MB unit' do
                state = ViewState.new(less1GB, symbols, unlimited)
                expect(state.usage).to eq '1023.99MB'
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
                expect(state.usage).to eq '9.99GB'
            end
            it 'returns GB float unit' do
                state = ViewState.new(the10p0GB, symbols, unlimited)
                expect(state.usage).to eq '10.0GB'
            end
        end
    end

    describe '#left' do
        context 'usage is less than 1GB' do
            it 'returns MB unit' do
                state = ViewState.new(less1GB, symbols, unlimited)
                expect(state.left).to eq '9216MB'
            end
        end

        context 'usage is grater than 1GB' do
            it 'returns MB unit' do
                state = ViewState.new(the7GB, symbols, unlimited)
                expect(state.left).to eq '3072MB'
            end
        end

        context 'usage is nearly 10GB' do
            it 'returns MB unit' do
                state = ViewState.new(the9p9GB, symbols, unlimited)
                expect(state.left).to eq '0MB'
            end
        end

        context 'usage is over 10GB' do
            it 'returns MB unit' do
                state = ViewState.new(the10p1GB, symbols, unlimited)
                expect(state.left).to eq '0MB'
            end
        end
    end

end