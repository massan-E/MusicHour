require 'rails_helper'

RSpec.describe 'Letters', type: :system do
  let(:user) { create(:user) }
  let(:program) { create(:program, user: user) }
  let!(:letterbox) { create(:letterbox, program: program, publish: true) }

  describe 'お便り投稿' do
    before do
      sign_in user
    end

    it 'お便りを投稿できること', js: true do
      visit program_path(program)
      select letterbox.title, from: 'letter[letterbox_id]'
      fill_in 'ラジオネーム', with: 'テストユーザー'
      fill_in '本文', with: 'お便りの本文です'
      click_button '内容を確認する'
      click_button 'この内容で送信する'

      expect(page).to have_content 'お便りを送信しました'
    end

    context '入力が不正な場合' do
      it 'エラーメッセージが表示されること', js: true do
        visit program_path(program)
        click_button '内容を確認する'
        expect(page).to have_content '入力内容にエラーがあります'
      end
    end
  end
end
