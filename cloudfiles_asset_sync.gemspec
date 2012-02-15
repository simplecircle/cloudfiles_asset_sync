Gem::Specification.new do |s|
  s.name = 'cloudfiles_asset_sync'
  s.version = '1.1.1'
  s.author = 'Owen Davies'
  s.homepage = 'https://github.com/obduk/cloudfiles_asset_sync'
  s.summary = 'Rake task for uploading rails assets to rackspace cloud files'
  s.description = 'Adds a raks task to rails for uploading all files in public/assets to rackspace cloud files to be distributed via their CDN'
  #s.files = `git ls-files`.split("\n")
  s.files = Dir.glob '{lib,tasks,test}/**/*'
  s.require_path = 'lib'
  s.add_dependency('cloudfiles')
end

