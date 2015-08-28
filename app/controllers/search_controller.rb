class SearchController < ApplicationController
  def index
    @query = params[:q].to_s
    begin
      @images = Image.parsed_search(@query, size: 25).records
    rescue => ex
      @error = ex
    end
  end
end
