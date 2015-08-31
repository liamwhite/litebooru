class CommentsController < ApplicationController
  def show
    @comment = Comment.find(params[:id])
    render_404_if_not(@comment) do
      render partial: 'comments/image_comments', locals: {comments: [@comment]}, layout: false
    end
  end

  def new
    @image = Image.find_by(id_number: params[:image_id])
    render_404_if_not(@image) do
      @comment = Comment.new
      render partial: 'comments/form', layout: false
    end
  end

  def create
    @image = Image.find_by(id_number: params[:image_id])
    render_404_if_not(@image) do
      @comment = Comment.new
      @comment.ip = request.remote_ip
      @comment.image = @image
      @comment.user = current_user
      @comment.user_agent = request.env['HTTP_USER_AGENT']
      if @comment.assign_attributes(params.require(:comment).permit(Comment::ALLOWED_PARAMETERS))
        @comment.save!
        render head: :ok
      end
    end
  end
end
