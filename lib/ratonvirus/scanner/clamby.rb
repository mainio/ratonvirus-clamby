# frozen_string_literal: true

module Ratonvirus
  module Scanner
    class Clamby < Base
      CLAMBY_DEFAULT_CONFIG = ::Clamby::DEFAULT_CONFIG.merge(
        # We want to handle checking locally on initialization, not on every
        # scan.
        check: false,
        # Should be encouraged as it is much faster.
        daemonize: true,
        # We are checking already executable? and therefore not needed.
        error_clamscan_missing: false,
        # We want Ratonvirus to report issues errors on client errors.
        error_clamscan_client_error: true,
        # We want Ratonvirus to report issues on file missing errors.
        error_file_missing: true,
        # No output is required not to fill the logs. The scanning errors
        output_level: 'off',
      ).freeze

      class << self
        def configure(config={})
          ::Clamby.configure(config)
        end

        def reset
          configure(CLAMBY_DEFAULT_CONFIG.dup)
        end

        # Avoid multiple calls to the clamscan utility to check whether the
        # system is executable.
        def executable?
          # Clamby should return `nil` when clamscan is not available.
          !!::Clamby::Command.clamscan_version
        end
      end

      # Allow users to configure Clamby the way they want to.
      def setup
        self.class.configure(config[:clamby] || {})

        super
      end

      protected
        def run_scan(path)
          # In case the file is not present at all, scanning should always pass
          # because nil is not a virus.
          return if path.nil?

          begin
            errors << :antivirus_virus_detected if ::Clamby.virus?(path)
          rescue ::Clamby::ClamscanClientError
            # This can happen e.g. if the clamdscan utility does not have access
            # to read the file path. For debugging, try to run the clamdscan
            # utility manually for the same file:
            # clamdscan /path/to/file.pdf
            #
            # Also, make sure that the file uploads store directory is readable
            # by the clamdscan utility. E.g. /path/to/app/public/uploads/tmp.
            #
            # Another possible reason is that in case there are too many
            # concurrent virus checks ongoing, it may also trigger this error.
            errors << :antivirus_client_error
          rescue ::Clamby::FileNotFound
            # This should be pretty rare since the scanner should not be even
            # called when the file is not available. As the storage backend may
            # be configured, this may still happen with some storage backends.
            errors << :antivirus_file_not_found
          end
        end

      # Make sure we are starting up with the default configuration.
      reset
    end
  end
end
