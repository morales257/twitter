require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "layout links" do
    get root_path
    assert_template "static_pages/home"
    #makes sure 2 links to the home page are present
    assert_select "a[href=?]", root_path, count: 2
    #assert select looks for a link to URL combo and replaces the ? with the
    #about_path --> /about
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", contact_path
  end
end
