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
      @comment = @image.comments.new
      @comment.capture!(current_user, request)
      @comment.assign_attributes(params.require(:comment).permit(Comment::ALLOWED_PARAMETERS))
      if @comment.save
        @comment.update_index

        # Notify watchers and subscribe poster
        @image.subscribe!(@comment.user)
        @image.notify(@comment.author, 'commented on', [@comment.author])
        render partial: 'comments/image_comments', layout: false, locals: {comments: @image.comments.order(created_at: :desc).limit(25)}
      else
        redirect_to image_path(@image)
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to image_path(params[:image_id])
  end
end
