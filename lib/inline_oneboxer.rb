class InlineOneboxer

  class InlineOnebox
    attr_reader :url, :title
    def initialize(url:, title:)
      @url = url
      @title = title
    end
  end

  def initialize(urls)
    @urls = urls
  end

  def process
    results = []

    @urls.each do |url|
      if route = Discourse.route_for(url)
        if route[:controller] == "topics" &&
          route[:action] == "show" &&

          topic = Topic.where(id: route[:topic_id].to_i).first

          # Only public topics
          if Guardian.new.can_see?(topic)
            results << InlineOnebox.new(url: url, title: topic.title)
          end
        end
      end
    end

    results
  end
end

