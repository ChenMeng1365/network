


Gem::Specification.new do |spec|
  spec.name          = "network-utility"
  spec.version       = '1.1.8'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com","18995691365@189.cn"]
  spec.license       = "AGPL-3.0"

  spec.summary       = %q{core}
  spec.description   = %q{network-core}
  spec.homepage      = %q{https://github.com/ChenMeng1365/network}
  spec.files         = [
    'utility/ipv4_address',
    'utility/ipv6_address',
    'utility/mac_address',
    'utility/netmerge',
    'utility/route',
    'utility/whitelist',

    'document/document',

    'network'
  ].map{|file|"#{file}.rb"} + Dir["document/**/*"] + ["README.md", "LICENSE", "GEMFILE"]

  # spec.bindir        = ""
  # spec.executables   = [""]
  spec.require_paths = ["."]
  spec.add_runtime_dependency 'cc',  "~> 1.1.1"
  spec.add_runtime_dependency 'casetdown', "~> 0.9.0"
end