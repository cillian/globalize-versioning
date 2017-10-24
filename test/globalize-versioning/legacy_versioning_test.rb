require File.expand_path('../../test_helper', __FILE__)

class LegacyVersioningTest < MiniTest::Spec

  it 'defaults to paper_trail versioning when passed :versioning => true' do
    post = LegacyPost.create!(:title => 'title v1')
    assert_equal 1, post.translation.versions.length

    post.update_attributes :title => 'title v2'

    assert_equal 'title v1', post.translation.paper_trail.previous_version.title
  end

end
