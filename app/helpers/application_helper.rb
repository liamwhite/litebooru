module ApplicationHelper
  def render_time
    diff = ((Time.now - @start_time) * 1000.0).round(2)
    diff < 1000 ? "(#{diff}ms)" : "(#{(diff/1000.0).round(2)}s)"
  rescue
    "(nil ms)"
  end
end
