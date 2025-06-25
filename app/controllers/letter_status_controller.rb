class LetterStatusController < ApplicationController
  before_action :set_letter, only: %i[ read unread update_star ]
  before_action :authenticate_user!, only: %i[ read unread update_star ]
  before_action :email_registered_user, only: %i[ read unread update_star ]

  def read
    authorize @letter.program, policy_class: LetterStatusPolicy
    @letter.update(is_read: true)
  end

  def unread
    authorize @letter.program, policy_class: LetterStatusPolicy
    @letter.update(is_read: false)
  end

  def update_star
    authorize @letter.program, policy_class: LetterStatusPolicy
    @letter.update(star: params[:star], stared_at: Time.current)
  end

  private

    def set_letter
      @letter = Letter.find(params[:letter_id])
    end
end
