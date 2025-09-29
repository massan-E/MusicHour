class ProgramsController < ApplicationController
  before_action :set_program, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :email_registered_user, only: %i[ new create edit update destroy ]

  def index
    @q = Program.includes(:user).where(publish: true).order(created_at: :desc).ransack(params[:q])
    @programs = @q.result(distinct: true).page(params[:page]).per(6)
    authorize @programs
  end

  def show
    authorize @program
    @letter = Letter.new
    @letter.radio_name = current_user.name if current_user
    @letter.letterbox_id = params[:letter]&.dig(:letterbox_id)
    @letterboxes = @program.letterboxes.published
    @star_rankings = @program.cached_star_rankings
    logger.swim @star_rankings
    if @program.image.attached?
      set_meta_tags(og: { title: @program.title, image: url_for(@program.image.variant(format: :jpg)) }, twitter: { image: url_for(@program.image.variant(format: :jpg)) })
    end
  end

  def new
    @program = Program.new
    authorize @program
  end

  def edit
    authorize @program
    @members = @program.participants
                       .where.not(id: @program.user_id)
                       .page(params[:page])
                       .per(6)
  end

  def create
    @program = current_user.programs.build(program_params)
    authorize @program

    if @program.valid?
      begin
        @program.image = ImageProcessable.process_and_transform_image(params[:program][:image], 854) if params[:program][:image].present?
        if @program.save
          current_user.user_participations.create(program: @program)
          flash[:notice] = "番組を作成しました"
          redirect_to @program
        end
      rescue ImageProcessable::ImageProcessingError => e
        flash.now[:danger] = e.message
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:danger] = "番組を作成できませんでした、番組作成フォームを確認してください"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @program.assign_attributes(program_params)
    authorize @program

    if @program.valid?
      begin
        @program.image = ImageProcessable.process_and_transform_image(params[:program][:image], 854) if params[:program][:image].present?
        if @program.save
          flash[:notice] = "番組を編集しました"
          redirect_to @program
        end
      rescue ImageProcessable::ImageProcessingError => e
        flash.now[:danger] = e.message
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:danger] = "番組を編集できませんでした、番組編集フォームを確認してください"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @program
    @program.destroy!
    flash[:notice]= "番組を削除しました"
    redirect_to programs_path, status: :see_other
  end

  private

    def set_program
      @program = Program.find(params[:id])
    end

    def program_params
      params.require(:program).permit(:title, :body, :image, :publish, :url, :ranking_period)
    end
end
