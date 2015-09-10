class CommentsController < ApplicationController
  def index
  end

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
        # Save and index comment
        @comment.save!
        @comment.update_index

        # Notify watchers and subscribe poster
        @image.subscribe!(@comment.user)
        @image.notify(@comment.author, 'commented on', [@comment.author])
        render partial: 'comments/image_comments', layout: false, locals: {comments: @image.comments.desc(:created_at).limit(25)}
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
