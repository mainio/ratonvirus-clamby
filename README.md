# Ratonvirus - Clamby

Developed by [Mainio Tech](https://www.mainiotech.fi/).

[![Build Status](https://api.travis-ci.org/mainio/ratonvirus-clamby.svg?branch=master)](https://travis-ci.org/mainio/ratonvirus-clamby)
[![codecov](https://codecov.io/gh/mainio/ratonvirus-clamby/branch/master/graph/badge.svg)](https://codecov.io/gh/mainio/ratonvirus-clamby)

This gem provides a [Clamby](https://github.com/kobaltz/clamby) scanner for
[Ratonvirus](https://github.com/mainio/ratonvirus).

It allows Ratovirus to scan the files using [ClamAV](https://www.clamav.net/).

## Prerequisites

You need to have ClamAV installed on the target machine for the antivirus checks
to actually work. With the default configuration, you will also need the ClamAV
daemon installed in order to make the antivirus checks more efficient.

For full ClamAV installation instructions, please refer to
[ClamAV documentation](https://www.clamav.net/documents/installing-clamav).

For configuring ClamAV, please refer to
[Clamby documentation](https://github.com/kobaltz/clamby).

### ClamAV installation on Ubuntu/Debian

For proper ClamAV configuration in Ubuntu/Debian environments, follow these
steps:

#### 1. ClamAV and daemon installation

```bash
$ sudo apt install clamav clamav-daemon
```

#### 2. ClamAV configuration

```
# Change the following from /etc/clamav/freshclam.conf
# Change `local` to your country code
DatabaseMirror db.local.clamav.net
```

```
# Change the following from /etc/clamav/clamd.conf
# Most Rails apps use symlinks in the production environment
FollowDirectorySymlinks true
FollowFileSymlinks true
```

#### 3. AppArmor configuration for clamd

Make sure that the folder where your application is running is included in the
readable directories list:

```bash
$ sudo less /etc/apparmor.d/usr.sbin.clamd
```

If not, edit the local AppArmor configuration:

```bash
$ sudo nano /etc/apparmor.d/local/usr.sbin.clamd
```

Add the following line there with your application directory:

```
# Allow scanning for the application subdirs
/path/to/your/app/** r,
```

And finally reload apparmor configuration:

```bash
$ sudo systemctl reload apparmor
```

#### 4. Restart ClamAV daemons

```bash
$ sudo systemctl restart clamav-freshclam
$ sudo systemctl restart clamav-daemon
```

### Ensure that ClamAV installation is working properly

Go to your application folder and create simple test files there to test the
virus scanning:

```bash
$ cd /path/to/your/app
$ echo 'This is clean' > clean.pdf
$ wget -O dirty.pdf https://secure.eicar.org/eicar.com
```

The file `dirty.pdf` fetched from the URL is an
[EICAR test file](https://en.wikipedia.org/wiki/EICAR_test_file) used to test
the response of the antivirus scan.

Run the antivirus tests for both of these files using `clamdscan`:

```bash
$ clamdscan clean.pdf dirty.pdf
```

You should see the following type of output from that command when ClamAV and
its daemon are correctly working:

```
/path/to/your/app/clean.pdf: OK
/path/to/your/app/dirty.pdf: Eicar-Test-Signature FOUND

----------- SCAN SUMMARY -----------
Infected files: 1
Time: 0.001 sec (0 m 0 s)
```

NOTE:

It is important that you test this in the actual production environment inside
the application folder or the folder where the users are uploading the files in
order to ensure that ClamAV daemon is able to access that folder and read files
from it.

Also note that Decidim uses
[CarrierWave](https://github.com/carrierwaveuploader/carrierwave) to handle its
file uploads and processing on the server, so make sure you are also testing the
possible temporary paths of CarrierWave.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ratonvirus'
gem 'ratonvirus-clamby'
```

Then execute:

```bash
$ bundle
```

And finally configure the scanner for Ratonvirus:

```ruby
Ratonvirus.configure do |config|
  config.scanner = :clamby
end
```

## Possible scanning errors

There are multiple scanning errors that this script may produce for the file
attribute. Here are the explanations for each of the errors.

Please note that if you have done any changes to the default configurations,
not all of these errors may be

### antivirus_virus_detected ("contains a virus")

This means that the given file contains a virus detected by ClamAV.

This virus can be shown in few different occasions:

- The `clamdscan` executable did its work successfully, detected a virus and
  returned with an exit code 1.
- The `clamdscan` executable is not executable by the user under which the Rails
  app is run. This caused the system call to return with an exit code 126.
- The `clamdscan` executable is not available in the machine. This caused the
  system call to return with an exit code 127.

Shown when the `clamdscan` executable returns with the exit code other than 0 or
2.

### antivirus_client_error ("could not be processed for virus scan")

This means that the given file contains a virus detected by ClamAV.

In this case the `clamdscan` executable did not finish its work successfully and
an error was produced. This can be generally caused by the `clamav-daemon`
service because of few different reasons:

- The daemon cannot access the file to be checked. Please refer to the
  configuration section for further information.
- The daemon service is not running on the target machine. Please refer to the
  configuration section for further information.
- The daemon service is currently handling too many concurrent virus checks.
  This should be fixed by itself once the daemon finishes the previous checks.

Shown when the `clamdscan` executable returns with the exit code 2.

### antivirus_file_not_found ("could not be found for virus scan")

This means that the file passed to the ClamAV virus scan is no longer available
when the scan was about to be performed.

In this case, the `clamdscan` executable is not run.

Shown when the file has disappeared from the file system between the upload
procedure and Ratonvirus scans. This could also happen in case there is a
problem in with the storage engine when moving the file to the local filesystem.

## Testing without installing ClamAV

If you want to test that the scanner is working correctly without installing
ClamAV, you can create a dummy ClamAV executable in your app's `bin` path as
follows:

```bash
$ cd /path/to/your/app
$ wget -O bin/clamdscan https://git.io/fpKZr && chmod 755 bin/clamdscan
```

This downloads a bash script created to test the ClamAV executables without
installing ClamAV. You can inspect the script from
[here](https://gist.github.com/ahukkanen/ad28be993333b751013ddbc4cde2acef) prior
to downloading and running it.

The executable is being executed by Clamby to check for the viruses.

After creating these files, you should be able to test the Clamby scanner from
your Rails application by adding the folder where this executable resides to the
PATH environment variable for your Rails application. You can do this when you
start your Rails development server as follows.

```
$ PATH=./bin:$PATH bundle exec rails s
```

You should now be able to upload the
[EICAR test file](https://en.wikipedia.org/wiki/EICAR_test_file) to the proposal
form and see a `contains a virus` error when submitting the form. When
submitting any other file, the scanning should pass and you should not see any
errors produced by Ratonvirus.

Feel free to try the scanner with different exit codes as well, they are
described below:

- 0: No virus found.
- 1: Virus(es) found.
- 2: An error occured.
- 126: The file is not executable.
- 127: The executable could not be found.

For testing these, modify the `bin/clamdscan` executable to contain the
following lines:

```bash
#!/bin/bash
exit 1
```

Modify the exit code to the one you want to test.
