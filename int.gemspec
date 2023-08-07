require_relative "lib/int/version"

Gem::Specification.new do |spec|
  spec.name = "int"
  spec.version = Int::VERSION
  spec.authors = ["Tadashi Saito"]
  spec.email = ["tad.a.digger@gmail.com"]

  spec.summary = "Interval-arithmetic-ish library with a terrible name."
  #spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/tadd/int"
  #spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ features/ .git Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "steep"
end
