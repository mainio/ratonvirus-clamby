# frozen_string_literal: true

require "spec_helper"

describe Ratonvirus::Scanner::Clamby do
  let(:subject) { described_class.new(config) }
  let(:config) { {} }

  it 'has correct default configurations' do
    expect(described_class::CLAMBY_DEFAULT_CONFIG).to eq(
      Clamby::DEFAULT_CONFIG.merge({
        check: false,
        daemonize: true,
        error_clamscan_missing: false,
        error_clamscan_client_error: true,
        error_file_missing: true,
        output_level: 'off',
      })
    )
  end

  describe '.configure' do
    context 'when configuration is not provided' do
      it 'should call Clamby.configure with empty hash' do
        expect(Clamby).to receive(:configure).with({})
        described_class.configure
      end
    end

    context 'when configuration is provided' do
      it 'should call Clamby.configure with the provided configuration' do
        config = double
        expect(Clamby).to receive(:configure).with(config)
        described_class.configure(config)
      end
    end
  end

  describe '.reset' do
    it 'should configure Clamby with the default configuration' do
      expect(described_class).to receive(:configure).with(
        described_class::CLAMBY_DEFAULT_CONFIG
      )
      described_class.reset
    end
  end

  describe '.executable?' do
    context 'when Clamby::Command.clamscan_version is nil' do
      it 'should return false' do
        expect(Clamby::Command).to receive(:clamscan_version).and_return(nil)
        expect(described_class.executable?).to be(false)
      end
    end

    context 'when Clamby::Command.clamscan_version is false' do
      it 'should return false' do
        expect(Clamby::Command).to receive(:clamscan_version).and_return(false)
        expect(described_class.executable?).to be(false)
      end
    end

    context 'when Clamby::Command.clamscan_version is true' do
      it 'should return false' do
        expect(Clamby::Command).to receive(:clamscan_version).and_return(true)
        expect(described_class.executable?).to be(true)
      end
    end
  end

  describe '#setup' do
    context 'when clamby configuration is not provided' do
      it 'should call .configure with empty hash' do
        expect(described_class).to receive(:configure).with({})
        subject
      end
    end

    context 'when clamby configuration is provided' do
      let(:config) { {clamby: clamby_config} }
      let(:clamby_config) { double }

      it 'should call .configure with empty hash' do
        expect(described_class).to receive(:configure).with(clamby_config)
        subject
      end
    end
  end

  describe '#virus?' do
    context 'when path is nil' do
      let(:path) { nil }

      it 'should not call Clamby.virus?' do
        expect(Clamby).not_to receive(:virus?)
        subject.virus?(path)
      end
    end

    context 'when path is something else' do
      let(:path) { double }

      before(:each) do
        # Ratonvirus needs this
        allow(path).to receive(:empty?).and_return(false)
      end

      context 'with Clamby.virus? returning false' do
        it 'should not add any errors' do
          expect(Clamby).to receive(:virus?).with(path).and_return(false)
          subject.virus?(path)
          expect(subject.errors).to eq([])
        end
      end

      context 'with Clamby.virus? returning true' do
        it 'should add the antivirus_virus_detected error' do
          expect(Clamby).to receive(:virus?).with(path).and_return(true)
          subject.virus?(path)
          expect(subject.errors).to eq([:antivirus_virus_detected])
        end
      end

      context 'with Clamby.virus? raising Clamby::ClamscanClientError' do
        it 'should add the antivirus_client_error error' do
          expect(Clamby).to receive(:virus?).with(path) do
            raise Clamby::ClamscanClientError
          end
          subject.virus?(path)
          expect(subject.errors).to eq([:antivirus_client_error])
        end
      end

      context 'with Clamby.virus? raising Clamby::FileNotFound' do
        it 'should add the antivirus_file_not_found error' do
          expect(Clamby).to receive(:virus?).with(path) do
            raise Clamby::FileNotFound
          end
          subject.virus?(path)
          expect(subject.errors).to eq([:antivirus_file_not_found])
        end
      end

      context 'with Clamby.virus? raising StandardError' do
        it 'should add the antivirus_file_not_found error' do
          expect(Clamby).to receive(:virus?).with(path) do
            raise StandardError
          end
          expect{ subject.virus?(path) }.to raise_error(StandardError)
        end
      end
    end
  end
end
