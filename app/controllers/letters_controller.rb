class LettersController < ApplicationController
  before_action :set_letter, only: %i[ show destroy ]
  before_action :set_program, only: %i[ index new create check ]
  before_action :authenticate_user!, only: %i[ index destroy ]
  before_action :email_registered_user, only: %i[ index ]

  def index
    authorize @program, policy_class: LetterPolicy
    @q = @program.letters.includes(:letterbox).ransack(params[:q])
    @result = @q.result(distinct: true)
    @letters = @result.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @program = @letter.program
    authorize @letter, policy_class: LetterPolicy
    if @letter.letterbox.letters_visible?
      ogp_image_url = @letter.generate_ogp_image_url
      set_meta_tags(og: { title: "To：#{@letter.letterbox.title}", image: ogp_image_url }, twitter: { image: ogp_image_url })
    else
      set_meta_tags(og: { url: program_url(@program) })
    end
  end

  # def new
  #   @program = Program.find(@letter.program_id)
  #   authorize @program, policy_class: LetterPolicy
  #   @letter = Letter.new
  #   @letter.radio_name = current_user&.name
  #   @letter.letterbox_id = params[:letter]&.dig(:letterbox_id)
  # end

  def create
    authorize @program, policy_class: LetterPolicy
    @letter = Letter.new(letter_params)
    @letter.user_id = current_user&.id
    @letter.program_id = params[:program_id]
    if @letter.save
      flash[:notice]=  "お便りを送信しました"
      redirect_to @program
    else
      flash.now[:danger] = "お便りの送信に失敗しました、お便り入力フォームを確認してください"
      render "programs/show", status: :unprocessable_entity
    end
  end

  def destroy
    authorize @letter, policy_class: LetterPolicy
    @letter.destroy!
    flash[:notice]= "お便りを削除しました"
    redirect_to letters_path, status: :see_other
  end

  def check
    @letter = Letter.new(letter_params)
    @letter.user_id = current_user&.id
    @letter.program_id = params[:program_id]
    if @letter.valid?
      @letter_params = letter_params
    else
      flash.now[:danger] = "入力された情報が正しくありませんでした、お便り入力フォームを確認してください"
      render "programs/show", status: :unprocessable_entity
    end
  end


  private

    def set_letter
      @letter = Letter.find(params[:id])
    end

    def letter_params
      params.require(:letter).permit(:body, :radio_name, :letterbox_id)
    end
end
