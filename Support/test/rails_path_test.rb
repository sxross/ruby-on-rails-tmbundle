require File.dirname(__FILE__) + '/test_helper'

require 'text_mate_mock'
require 'rails/rails_path'

TextMate.line_number = '1'
TextMate.column_number = '1'
TextMate.project_directory = File.expand_path(File.dirname(__FILE__) + '/app_fixtures')

class RailsPathTest < Test::Unit::TestCase
  def setup
    @rp_controller = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    @rp_controller_with_module = RailsPath.new(FIXTURE_PATH + '/app/controllers/admin/base_controller.rb')
    @rp_view = RailsPath.new(FIXTURE_PATH + '/app/views/user/new.rhtml')
    @rp_view_with_module = RailsPath.new(FIXTURE_PATH + '/app/views/admin/base/action.rhtml')
    @rp_fixture = RailsPath.new(FIXTURE_PATH + '/test/fixtures/users.yml')
  end

  def test_rails_root
    assert_equal File.expand_path(File.dirname(__FILE__) + '/app_fixtures'), RailsPath.new.rails_root
  end

  def test_extension
    assert_equal "rb", @rp_controller.extension
    assert_equal "rhtml", @rp_view.extension
  end

  def test_file_type
    assert_equal :controller, @rp_controller.file_type
    assert_equal :view, @rp_view.file_type
    assert_equal :fixture, @rp_fixture.file_type
  end

  def test_modules
    assert_equal [], @rp_controller.modules
    assert_equal ['admin'], @rp_controller_with_module.modules
    assert_equal [], @rp_view.modules
    assert_equal ['admin'], @rp_view_with_module.modules
  end

  def test_controller_name_and_action_name_for_controller
    rp = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    assert_equal "user", rp.controller_name
    assert_equal nil, rp.action_name

    TextMate.line_number = '3'
    rp = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    assert_equal "user", rp.controller_name
    assert_equal "new", rp.action_name

    TextMate.line_number = '6'
    rp = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    assert_equal "user", rp.controller_name
    assert_equal "create", rp.action_name
  end

  def test_controller_name_and_action_name_for_view
    rp = RailsPath.new(FIXTURE_PATH + '/app/views/user/new.rhtml')
    assert_equal "user", rp.controller_name # this was pre-2.0 behavior. s/b "users"
    assert_equal "new", rp.action_name
  end

  # Rails 2.x convention is for pluralized controllers
  def test_controller_name_and_action_name_for_2_dot_ooh_views
    rp = RailsPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal "users", rp.controller_name
    assert_equal "new", rp.action_name
  end
  
  def test_controller_name_pluralization
    rp = RailsPath.new(FIXTURE_PATH + '/app/views/people/new.html.erb')
    assert_equal "people", rp.controller_name
  end
  
  def test_controller_name_suggestion_when_controller_absent
    rp = RailsPath.new(FIXTURE_PATH + '/app/views/people/new.html.erb')
    assert_equal "people", rp.controller_name
  end

  def test_rails_path_for
    partners = [
      # Basic tests
      [FIXTURE_PATH + '/app/controllers/user_controller.rb', :helper, FIXTURE_PATH + '/app/helpers/user_helper.rb'],
      [FIXTURE_PATH + '/app/controllers/user_controller.rb', :javascript, FIXTURE_PATH + '/public/javascripts/user.js'],
      [FIXTURE_PATH + '/app/controllers/user_controller.rb', :functional_test, FIXTURE_PATH + '/test/functional/user_controller_test.rb'],
      [FIXTURE_PATH + '/app/helpers/user_helper.rb', :controller, FIXTURE_PATH + '/app/controllers/users_controller.rb'],
      [FIXTURE_PATH + '/app/models/user.rb', :controller, FIXTURE_PATH + '/app/controllers/users_controller.rb'],
      [FIXTURE_PATH + '/app/models/post.rb', :controller, FIXTURE_PATH + '/app/controllers/posts_controller.rb'],
      [FIXTURE_PATH + '/test/fixtures/users.yml', :model, FIXTURE_PATH + '/app/models/user.rb'],
      [FIXTURE_PATH + '/app/controllers/user_controller.rb', :model, FIXTURE_PATH + '/app/models/user.rb'],
      [FIXTURE_PATH + '/test/fixtures/users.yml', :unit_test, FIXTURE_PATH + '/test/unit/user_test.rb'],
      [FIXTURE_PATH + '/app/models/user.rb', :fixture, FIXTURE_PATH + '/test/fixtures/users.yml'],
      # With modules
      [FIXTURE_PATH + '/app/controllers/admin/base_controller.rb', :helper, FIXTURE_PATH + '/app/helpers/admin/base_helper.rb'],
      [FIXTURE_PATH + '/app/controllers/admin/inside/outside_controller.rb', :javascript, FIXTURE_PATH + '/public/javascripts/admin/inside/outside.js'],
      [FIXTURE_PATH + '/app/controllers/admin/base_controller.rb', :functional_test, FIXTURE_PATH + '/test/functional/admin/base_controller_test.rb'],
      [FIXTURE_PATH + '/app/helpers/admin/base_helper.rb', :controller, FIXTURE_PATH + '/app/controllers/admin/base_controller.rb']
    ]
    # TODO Add [posts.yml, :model, post.rb]
    for pair in partners
      assert_equal RailsPath.new(pair[2]), RailsPath.new(pair[0]).rails_path_for(pair[1])
    end

    # Test controller to view
    ENV['RAILS_VIEW_EXT'] = nil
    TextMate.line_number = '6'
    current_file = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/views/user/create.html.erb'), current_file.rails_path_for(:view)
    
    # 2.0 plural controllers
    current_file = RailsPath.new(FIXTURE_PATH + '/app/controllers/users_controller.rb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/views/users/create.html.erb'), current_file.rails_path_for(:view)

    TextMate.line_number = '3'
    current_file = RailsPath.new(FIXTURE_PATH + '/app/controllers/user_controller.rb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/views/user/new.rhtml'), current_file.rails_path_for(:view)
    
    # 2.0 plural controllers
    current_file = RailsPath.new(FIXTURE_PATH + '/app/controllers/users_controller.rb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb'), current_file.rails_path_for(:view)

    # Test view to controller
    current_file = RailsPath.new(FIXTURE_PATH + '/app/views/user/new.html.erb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/controllers/users_controller.rb'), current_file.rails_path_for(:controller)
    
    # 2.0 plural controllers
    current_file = RailsPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal RailsPath.new(FIXTURE_PATH + '/app/controllers/users_controller.rb'), current_file.rails_path_for(:controller)
  end
  
  def test_file_parts
    current_file = RailsPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal(FIXTURE_PATH + '/app/views/users/new.html.erb', current_file.filepath)
    pathname, basename, content_type, extension = current_file.parse_file_parts
    assert_equal(FIXTURE_PATH + '/app/views/users', pathname)
    assert_equal('new', basename)
    assert_equal('html', content_type)
    assert_equal('erb', extension)
    
    current_file = RailsPath.new(FIXTURE_PATH + '/app/views/user/new.rhtml')
    pathname, basename, content_type, extension = current_file.parse_file_parts
    assert_equal(FIXTURE_PATH + '/app/views/user', pathname)
    assert_equal('new', basename)
    assert_equal(nil, content_type)
    assert_equal('rhtml', extension)
  end
  
  def test_new_rails_path_has_parts
    current_file = RailsPath.new(FIXTURE_PATH + '/app/views/users/new.html.erb')
    assert_equal(FIXTURE_PATH + '/app/views/users/new.html.erb', current_file.filepath)
    assert_equal(FIXTURE_PATH + '/app/views/users', current_file.path_name)
    assert_equal('new', current_file.file_name)
    assert_equal('html', current_file.content_type)
    assert_equal('erb', current_file.extension)
  end
end