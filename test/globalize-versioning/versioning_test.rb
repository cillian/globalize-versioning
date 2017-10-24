require File.expand_path('../../test_helper', __FILE__)

class VersioningTest < MiniTest::Spec

  it "creates only one version when created" do
    post = Post.create!(:title => 'title v1')
    assert_equal 1, post.translation.versions.length
  end

  it "versions are scoped to the current Globalize locale" do
    post = Post.create!(:title => 'title v1')

    post.update_attributes!(:title => 'title v2')
    # Creates a 'created' version, and the update
    assert_equal %w[en en], post.translation.versions.map(&:locale)

    Globalize.with_locale(:de) {
      post.update_attributes!(:title => 'Titel v1')
      assert_equal %w[de], post.translation.versions.map(&:locale)
    }

    post.translation.versions.reset # hrmmm.
    assert_equal %w[en en], post.translation.versions.map(&:locale)
  end

  it "only fetches versions from the current locale" do
    post = Post.create!(:title => 'title v1')

    with_locale(:en) do
      post.update_attributes!(:title => 'updated title in English')
    end

    with_locale(:de) do
      post.update_attributes!(:title => 'updated title in German')
    end

    with_locale(:en) do
      post.update_attributes!(:title => 'updated title in English, v2')
    end

    with_locale(:de) do
      post.update_attributes!(:title => 'updated title in German, v2')
    end

    with_locale(:en) do
      post_en_v2 = post.translation.versions[2].reify
      post_en_v1 = post.translation.versions[1].reify

      assert_equal 'updated title in English', post_en_v2.title

      assert_equal 'title v1', post_en_v1.title
    end

    with_locale(:de) do
      post_de_v1 = post.translation.versions[1].reify

      assert_equal 'updated title in German', post_de_v1.title
    end
  end
end
