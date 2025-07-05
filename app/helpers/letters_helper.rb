module LettersHelper
  def letter_action_path(letter, program)
    letter.persisted? ? edit_letter_path(program) : program_letter_check_path(program)
  end

  def permitted_q_params
    return nil unless params[:q]
    params.require(:q)&.permit(:body_or_user_name_or_radio_name_cont,
                               :letterbox_id_eq,
                               :created_at_gteq,
                               :created_at_lteq_end_of_day,
                               :publish_eq,
                               :is_read_eq)
  end

  def letter_body_size(letter)
    if letter.body.size > 999
      text = "※ #{letter.body.size} / 999 文字"
      css_class = "text-danger fw-bold"
    else
      text = "※ #{letter.body.size} / 999 文字"
      css_class = "text-white-50"
    end
    content_tag(:span, text, class: "form-text #{css_class}")
  end
end
