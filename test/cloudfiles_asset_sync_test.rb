require File.join(File.dirname(__FILE__), 'test_helper')

class CloudfilesAssetSyncTest < Test::Unit::TestCase

  def setup
    mock_class = stub
    mock_class.stubs(:parent_name).returns('ExampleApplication')

    mock_application = stub
    mock_application.stubs(:class).returns(mock_class)

    Rails.stubs(:root).returns(File.join(File.dirname(__FILE__), '..'))
    Rails.stubs(:application).returns(mock_application)
  end

  def test_run
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_object = mock
    mock_object.expects(:load_from_filename).with(File.join(Rails.root, 'public', 'assets', 'image.png'))
    mock_object.expects(:content_type=).with('image/png')

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 604800)
    mock_container.expects(:objects).returns([])
    mock_container.expects(:create_object).with('assets/image.png').returns(mock_object)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns([])
    mock_cloud_files.expects(:create_container).with("test_example_application")
    mock_cloud_files.expects(:container).with("test_example_application").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey'}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    Dir.expects(:[]).with(File.join(Rails.root, 'public', 'assets', '**', '*')).returns([File.join(Rails.root, 'public', 'assets', 'image.png')])
    File.expects(:directory?).with(File.join(Rails.root, 'public', 'assets', 'image.png')).returns(false)

    CloudfilesAssetSync.run
  end

  def test_setup_container
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 604800)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns([])
    mock_cloud_files.expects(:create_container).with("test_example_application")
    mock_cloud_files.expects(:container).with("test_example_application").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey'}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    assert_equal mock_container, CloudfilesAssetSync.setup_container
  end

  def test_setup_container_excepts_uk_region_config
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey", "region" => "uk"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 604800)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns([])
    mock_cloud_files.expects(:create_container).with("test_example_application")
    mock_cloud_files.expects(:container).with("test_example_application").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey', :auth_url => CloudFiles::AUTH_UK}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    assert_equal mock_container, CloudfilesAssetSync.setup_container
  end

  def test_setup_container_excepts_optional_container_name
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey", "container" => "examplecontainer"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 604800)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns([])
    mock_cloud_files.expects(:create_container).with("examplecontainer")
    mock_cloud_files.expects(:container).with("examplecontainer").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey'}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    assert_equal mock_container, CloudfilesAssetSync.setup_container
  end

  def test_setup_container_excepts_optional_ttl
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey", "ttl" => "31557600"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 31557600)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns([])
    mock_cloud_files.expects(:create_container).with("test_example_application")
    mock_cloud_files.expects(:container).with("test_example_application").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey'}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    assert_equal mock_container, CloudfilesAssetSync.setup_container
  end

  def test_setup_container_with_existing_container
    config = {"test" => {"username" => "myusername", "api_key" => "myapikey"}}
    YAML.expects(:load_file).with(File.join(Rails.root, 'config', 'cloudfiles.yml')).returns(config)

    mock_container = mock
    mock_container.expects(:make_public).with(:ttl => 604800)

    mock_cloud_files = mock
    mock_cloud_files.expects(:containers).returns(['test_example_application'])
    mock_cloud_files.expects(:container).with("test_example_application").returns(mock_container)

    expect_arguments = {:username => 'myusername', :api_key => 'myapikey'}
    CloudFiles::Connection.expects(:new).with{|arguments| assert_equal expect_arguments, arguments}.returns(mock_cloud_files)

    assert_equal mock_container, CloudfilesAssetSync.setup_container
  end

  def test_walk_files_recurses_down_directories
    Dir.expects(:[]).with(File.join(Rails.root, 'public', 'assets', '**', '*')).returns([
      File.join(Rails.root, 'public', 'assets', 'image.png'),
      File.join(Rails.root, 'public', 'assets', 'folder'),
      File.join(Rails.root, 'public', 'assets', 'folder', 'anotherimage.png'),
    ])

    File.expects(:directory?).with(File.join(Rails.root, 'public', 'assets', 'image.png')).returns(false)
    File.expects(:directory?).with(File.join(Rails.root, 'public', 'assets', 'folder')).returns(true)
    File.expects(:directory?).with(File.join(Rails.root, 'public', 'assets', 'folder', 'anotherimage.png')).returns(false)

    expected = [File.join(Rails.root, 'public', 'assets', 'image.png'), File.join(Rails.root, 'public', 'assets', 'folder', 'anotherimage.png')]

    assert_equal expected, CloudfilesAssetSync.asset_files
  end

  def test_upload_file
    filename = File.join(Rails.root, 'public', 'assets', 'image.png')
    mock_object = mock
    mock_object.expects(:load_from_filename).with(filename)
    mock_object.expects(:content_type=).with('image/png')

    mock_container = mock
    mock_container.expects(:create_object).with('assets/image.png').returns(mock_object)

    CloudfilesAssetSync.upload_file(mock_container, [], filename)
  end

  def test_upload_file_when_filename_exisits_but_etags_do_not_match
    filename = File.join(Rails.root, 'public', 'assets', 'image.png')

    Digest::MD5.expects(:file).with(filename).returns('90580754da3ed1b3e4be38c9b277bc9b')

    mock_object = mock
    mock_object.expects(:etag).returns('3c7fb8ede821645fbca813d05c8fa47d')
    mock_object.expects(:load_from_filename).with(filename)
    mock_object.expects(:content_type=).with('image/png')

    mock_container = mock
    mock_container.expects(:create_object).with('assets/image.png').returns(mock_object)

    CloudfilesAssetSync.upload_file(mock_container, ['assets/image.png'], filename)
  end

  def test_upload_file_when_filename_exisits_and_etags_match
    filename = File.join(Rails.root, 'public', 'assets', 'image.png')

    Digest::MD5.expects(:file).with(filename).returns('3c7fb8ede821645fbca813d05c8fa47d')

    mock_object = mock
    mock_object.expects(:etag).returns('3c7fb8ede821645fbca813d05c8fa47d')

    mock_container = mock
    mock_container.expects(:create_object).with('assets/image.png').returns(mock_object)

    CloudfilesAssetSync.upload_file(mock_container, ['assets/image.png'], filename)
  end

end
