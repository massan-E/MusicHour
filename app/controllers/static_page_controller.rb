class StaticPageController < ApplicationController
  def top
    @programs = Program.includes(:user).where(publish: true).order(created_at: :desc).limit(5)
    @letterboxes = Letterbox.includes(:program).where(publish: true).order(created_at: :desc).limit(10)
    @popular_letterbox = Letterbox.includes(:program).left_joins(:letters).group(:id).order('COUNT(letters.id) DESC').limit(15)
    @rankings = ProgramRanking.all.includes(:program)
  end

  def privacy_policy; end

  def terms; end

  def usage; end  # 追加
end
