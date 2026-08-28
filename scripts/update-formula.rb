#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "pathname"
require "rubygems"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
CLIENT_REPOSITORY = "mutte-me/mutte-client"
CHANNEL_URI = URI("https://raw.githubusercontent.com/#{CLIENT_REPOSITORY}/main/INSTALL_VERSION")
TAG_PATTERN = /\Av\d+\.\d+\.\d+(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?\z/
PLATFORMS = %w[macos-aarch64 macos-x86_64 linux-aarch64 linux-x86_64].freeze

def fetch(uri, accept: nil)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = accept if accept
  request["User-Agent"] = "mutte-homebrew-formula-updater"

  token = ENV["GITHUB_TOKEN"]
  if uri.host == "api.github.com" && token && !token.empty?
    request["Authorization"] = "Bearer #{token}"
    request["X-GitHub-Api-Version"] = "2022-11-28"
  end

  response = Net::HTTP.start(
    uri.host,
    uri.port,
    use_ssl: true,
    open_timeout: 10,
    read_timeout: 30,
  ) { |http| http.request(request) }

  return response.body if response.is_a?(Net::HTTPSuccess)

  abort "request failed: #{uri} returned HTTP #{response.code}"
end

tag = fetch(CHANNEL_URI).strip
abort "invalid promoted client version: #{tag.inspect}" unless TAG_PATTERN.match?(tag)

release_uri = URI(
  "https://api.github.com/repos/#{CLIENT_REPOSITORY}/releases/tags/" \
  "#{URI.encode_www_form_component(tag)}",
)
release = JSON.parse(fetch(release_uri, accept: "application/vnd.github+json"))
abort "release #{tag} is a draft" if release.fetch("draft")
abort "release #{tag} is not published" unless release["published_at"]
abort "release tag mismatch: #{release.fetch("tag_name").inspect}" unless release.fetch("tag_name") == tag

version = tag.delete_prefix("v")
assets = release.fetch("assets").to_h { |asset| [asset.fetch("name"), asset] }
archives = PLATFORMS.to_h do |platform|
  name = "mutte-#{version}-#{platform}.tar.gz"
  asset = assets[name] or abort "release #{tag} is missing #{name}"
  checksum = assets["#{name}.sha256"] or abort "release #{tag} is missing #{name}.sha256"

  abort "release asset #{name} is not uploaded" unless asset.fetch("state") == "uploaded"
  abort "release asset #{name} is empty" unless asset.fetch("size").positive?
  abort "release checksum #{name}.sha256 is not uploaded" unless checksum.fetch("state") == "uploaded"
  abort "release checksum #{name}.sha256 is empty" unless checksum.fetch("size").positive?

  expected_url = "https://github.com/#{CLIENT_REPOSITORY}/releases/download/#{tag}/#{name}"
  actual_url = asset.fetch("browser_download_url")
  abort "unexpected release URL for #{name}: #{actual_url}" unless actual_url == expected_url

  digest = asset.fetch("digest", "")
  abort "release asset #{name} has no valid SHA-256 digest" unless digest.match?(/\Asha256:[0-9a-f]{64}\z/)

  [platform, { url: actual_url, sha256: digest.delete_prefix("sha256:") }]
end

template_path = ROOT.join("templates/mutte.rb.template")
formula_path = Pathname(ENV.fetch("MUTTE_FORMULA_PATH", ROOT.join("Formula/mutte.rb").to_s)).expand_path
rendered = format(
  template_path.read,
  linux_aarch64_sha256: archives.fetch("linux-aarch64").fetch(:sha256),
  linux_aarch64_url: archives.fetch("linux-aarch64").fetch(:url),
  linux_x86_64_sha256: archives.fetch("linux-x86_64").fetch(:sha256),
  linux_x86_64_url: archives.fetch("linux-x86_64").fetch(:url),
  macos_aarch64_sha256: archives.fetch("macos-aarch64").fetch(:sha256),
  macos_aarch64_url: archives.fetch("macos-aarch64").fetch(:url),
  macos_x86_64_sha256: archives.fetch("macos-x86_64").fetch(:sha256),
  macos_x86_64_url: archives.fetch("macos-x86_64").fetch(:url),
  version: version,
)

existing = formula_path.exist? ? formula_path.read : ""
current_version = existing[/^  version "([^"]+)"$/, 1]
if current_version == version && existing != rendered
  abort "release #{tag} metadata changed without a version change; refusing automatic update"
end
if current_version && Gem::Version.new(version) < Gem::Version.new(current_version)
  abort "refusing automatic downgrade from #{current_version} to #{version}"
end

formula_path.dirname.mkpath
formula_path.write(rendered) unless existing == rendered
puts tag
