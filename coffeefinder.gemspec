require_relative 'lib/coffeefinder/concerns/constants'

Gem::Specification.new do |spec|
  spec.name          = 'coffeefinder'
  spec.version       = Coffeefinder::VERSION
  spec.authors       = ['ghemsley']
  spec.email         = ['ghemsley@protonmail.ch']

  spec.summary       = 'Coffeefinder CLI app'
  spec.description   = 'A Ruby app for finding the best local coffee shops around'
  spec.homepage      = 'https://github.com/ghemsley/coffeefinder'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ghemsley/coffeefinder'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'graphlient', '~> 0.4.0'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.22.0'
  spec.add_runtime_dependency 'tty-table', '~> 0.12.0'
  spec.add_development_dependency 'pry'
end
