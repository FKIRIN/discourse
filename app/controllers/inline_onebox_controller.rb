require_dependency 'inline_oneboxer'
require_dependency 'inline_onebox_serializer'

class InlineOneboxController < ApplicationController
  before_filter :ensure_logged_in

  def show
    oneboxes = InlineOneboxer.new(params[:urls]).process
    render_serialized(oneboxes, InlineOneboxSerializer, root: 'inline-oneboxes')
  end
end
