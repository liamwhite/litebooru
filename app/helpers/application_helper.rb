module ApplicationHelper

  def friendly_time(time)
    if time
      return "<time datetime=#{time.utc.iso8601}>#{time.strftime("%H:%M, %B %d, %Y")}</time>".html_safe
    end
    return "an unknown time ago"
  end

  def render_time
    diff = ((Time.now - @start_time) * 1000.0).round(2)
    diff < 1000 ? "(#{diff}ms)" : "(#{(diff/1000.0).round(2)}s)"
  rescue
    "(nil ms)"
  end

  def render_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_intra_emphasis: true, tables: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, underline: true)
    markdown.render(text).html_safe
  end
end
