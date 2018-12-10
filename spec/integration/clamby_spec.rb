# frozen_string_literal: true

require "spec_helper"

describe Ratonvirus::Scanner::Clamby do
  let(:runner){ Clamby::Command.new }

  before(:each) do
    # Be able to mock the system calls
    allow(Clamby::Command).to receive(:new).and_return(runner)
  end

  describe '.executable?' do
    context 'with ClamAV scanner exiting with code 0' do
      it 'return true' do
        # https://linux.die.net/man/1/clamdscan
        # 0: No virus found.
        system_exit_with(0, '--version')
        expect(described_class.executable?).to be(true)
      end
    end

    context 'with ClamAV scanner exiting with other exit codes' do
      it 'return false' do
        # https://linux.die.net/man/1/clamdscan
        # 1: Virus(es) found.
        # 2: An error occured.
        #
        # http://tldp.org/LDP/abs/html/exitcodes.html
        # 126: The file is not executable.
        # 127: The executable could not be found.
        [1, 2, 126, 127].each do |code|
          system_exit_with(1, '--version')
          expect(described_class.executable?).to be(false)
        end
      end
    end
  end

  describe '#virus?' do
    # Force availability of the scanner to avoid unnecessary .executable? checks
    let(:subject) { described_class.new(force_availability: true) }
    let(:scan_args) { ['--no-summary'] }

    context 'when file does not exist' do
      let(:path) { 'unexisting.pdf' }

      before(:each) do
        expect(runner).not_to receive(:system)
      end

      it 'return true' do
        expect(subject.virus?(path)).to be(true)
        expect(subject.errors).to eq([:antivirus_file_not_found])
      end
    end

    context 'when file exists' do
      let(:path) { __FILE__ }

      context 'with ClamAV scanner exiting with code 0' do
        it 'return false' do
          system_exit_with(0, *(scan_args + [path]))
          expect(subject.virus?(path)).to be(false)
        end
      end

      context 'with ClamAV scanner exiting with code 1' do
        it 'return true' do
          system_exit_with(1, *(scan_args + [path]))
          expect(subject.virus?(path)).to be(true)
          expect(subject.errors).to eq([:antivirus_virus_detected])
        end
      end

      context 'with ClamAV scanner exiting with code 2' do
        it 'return true' do
          system_exit_with(2, *(scan_args + [path]))
          expect(subject.virus?(path)).to be(true)
          expect(subject.errors).to eq([:antivirus_client_error])
        end
      end

      context 'with ClamAV scanner exiting with other code' do
        it 'return true' do
          # http://tldp.org/LDP/abs/html/exitcodes.html
          # 126: The file is not executable.
          # 127: The executable could not be found.
          [126, 127].each do |code|
            system_exit_with(code, *(scan_args + [path]))
            expect(subject.virus?(path)).to be(true)
            expect(subject.errors).to eq([:antivirus_virus_detected])
          end
        end
      end
    end
  end

  def system_exit_with(exit_code, *args)
    # Override the run call to return the correct result
    args << {out: File::NULL}
    allow(runner).to receive(:system).with('clamdscan', *args) do
      set_exit_code(exit_code)
    end
  end

  def set_exit_code(exit_code)
    system("exit #{exit_code}", out: File::NULL)
  end
end
