class InlineOneboxSerializer < ApplicationSerializer
  attributes :url, :title

  def url
    object.url
  end

  def title
    object.title
  end
end
