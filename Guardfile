# Guard requires terminal-notifier-guard
# https://github.com/Codaisseur/terminal-notifier-guard
# TL;DR:
# $ brew install terminal-notifier-guard
notification :terminal_notifier, sticky: false, priority: 0 if `uname` =~ /Darwin/

logger level: :info
clearing :on

guard "bundler" do
  watch("Gemfile")
  watch(/^.+\.gemspec/)
end

# NOTE: This Guardfile only watches unit specs.
options =
      {
            cmd: "bundle exec rspec",
            spec_paths: ["spec/lib"],
            failed_mode: :focus,
            all_after_pass: true,
            all_on_start: true
      }

guard(:rspec, options) do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/textflight-client/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("lib/textflight-client.rb")  { "spec/lib" }
  watch("spec/spec_helper.rb")  { "spec/lib" }
  watch("spec/fixtures.rb")  { "spec/lib" }
end
