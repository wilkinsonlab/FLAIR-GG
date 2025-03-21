# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "wrapped_services"
  spec.version       = 1
  spec.authors       = ["Mark Wilkinson"]
  spec.email         = ["mark.wilkinson@upm.es"]

  spec.summary       = "wrapped services"
  spec.description   = "wrapped_services"
  spec.homepage      = "https://github.com/wilkinsonlab/FLAIR-GG"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  # spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'https://github.com/markwilkinson/FAIR-Signposting-Harvester'
  # spec.metadata['changelog_uri'] = 'https://github.com/markwilkinson/FAIR-Signposting-Harvester'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


end
