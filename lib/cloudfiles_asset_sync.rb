require 'rubygems'
require 'cloudfiles'
require 'digest'
require 'mime/types'

module CloudfilesAssetSync
  class << self
    def run
      container = setup_container
      existing_objects = container.objects
      asset_files.each{|filename| upload_file(container, existing_objects, filename)}
    end

    def setup_container(container_name = nil)
      config = YAML.load_file(File.join(Rails.root, 'config', 'cloudfiles.yml'))[Rails.env]

      options = {:username => config["username"], :api_key => config["api_key"]}
      options[:auth_url] = CloudFiles::AUTH_UK if config["region"] == "uk"

      cloud_files = CloudFiles::Connection.new(options)

      container_name ||= config["container"] || "#{Rails.env}_#{Rails.application.class.parent_name.underscore}"
      container = cloud_files.create_container(container_name) unless cloud_files.containers.include? container_name
      container ||= cloud_files.container(container_name)

      container_options = {:ttl => 604800}
      container_options[:ttl] = Integer(config["ttl"]) if config["ttl"]

      container.make_public(container_options)

      return container
    end

    def asset_files
      Dir[File.join(Rails.root, 'public', 'assets', '**', '*')].reject{|file| File.directory?(file)}
    end

    def upload_file(container, existing_objects, filename)
      object_name = filename.sub(File.join(Rails.root, 'public', ''), '')
      object = container.create_object(object_name)

      unless existing_objects.include?(object_name) and object.etag == Digest::MD5.file(filename).to_s
        object.load_from_filename(filename)
        object.content_type = MIME::Types.of(filename).first.content_type
      end
    end
  end
end
