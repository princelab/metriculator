spec = Gem::Specification.new do |s|
  s.name = 'archiver'
  s.version = '0.0.1'
  s.summary = "Archiving, metric, and website viewer package for automating MS workflows and quality control"
  s.description = %{Archiver provides a tool for managing and automating the storage of data produced by Thermo LTQ series MS instruments to collect all files from each run and archive them to a storage/archive location.  Also incorporated is the automatic (user specified settings) generation of performance metrics from the NIST metric package.  Additionally, there are user specified alerts and a graphing system for the generation of comparisons between metrics. Finally, the whole package is brought together into a database for long-term information storage, and a website front-end for user experience and simplified viewing.  }
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.require_path = 'lib'
  s.autorequire = 'archiver'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  #s.rdoc_options << '--title' <<  'Builder -- Easy XML Building'
  s.author = ["Ryan Taylor", "Jamison Dance"]
  s.email = "ryanmt@byu.net"
  s.homepage = "https://github.com/princelab/rails-metric_site"
end
