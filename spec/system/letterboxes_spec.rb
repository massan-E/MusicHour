require 'rails_helper'

RSpec.describe 'Letterboxes', type: :system do
  let(:user) { create(:user) }
  # programのユーザーを明示的にuserに設定
  let(:program) { create(:program, user: user) }

  before do
    sign_in user
  end

  describe 'お便り箱作成' do
    it 'お便り箱を作成できること', js: true do
      visit new_program_letterbox_path(program)
      fill_in 'タイトル', with: 'テストお便り箱'
      fill_in '説明', with: 'お便り箱の説明文です'
      click_button '作成'
      expect(page).to have_content 'お便り箱を作成しました'
    end
  end

  describe 'お便り箱の編集' do
    let!(:letterbox) { create(:letterbox, program: program) }

    it 'お便り箱を編集できること', js: true do
      visit edit_program_letterbox_path(program, letterbox)
      fill_in 'タイトル', with: '更新後のタイトル'
      click_button '更新'
      expect(page).to have_content 'お便り箱を編集しました'
    end
  end
end
