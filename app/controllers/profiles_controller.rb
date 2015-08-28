class ProfilesController < ApplicationController
  def show
    @user = User.find_by(slug: params[:id])
    render_404_if_not(@user) do
      render
    end
  end
end
