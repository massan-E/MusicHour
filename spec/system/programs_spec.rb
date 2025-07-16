require 'rails_helper'

RSpec.describe 'Programs', type: :system do
  let!(:user) { create(:user) }

  before do
    sign_in user
  end

  describe '番組作成' do
    it '番組を作成できること', js: true do
      visit new_program_path
      fill_in 'タイトル', with: 'テスト番組'
      fill_in '説明', with: '番組の説明文です'
      click_button '作成'
      expect(page).to have_content '番組を作成しました'
    end

    context '不正な入力の場合' do
      it 'エラーメッセージが表示されること', js: true do
        visit new_program_path
        click_button '作成'
        expect(page).to have_content '番組を作成できませんでした'
      end
    end
  end

  describe '番組一覧' do
    let!(:program) { create(:program, user: user) }

    it '番組一覧が表示されること', js: true do
      visit programs_path
      expect(page).to have_content program.title
    end
  end

  describe '招待機能' do
    let!(:program) { create(:program, user: user) }
    let(:other_user) { create(:user) }

    context '番組制作者の場合' do
      it '招待リンクを生成できること', js: true do
        visit edit_program_path(program)
        click_link 'ユーザーを招待する'

        expect(page).to have_content 'この番組への招待リンクを生成しますか？'

        click_button '招待リンクを生成する'
        expect(page).to have_content '招待リンク'
        expect(page).to have_content '招待リンクは'
        expect(page).to have_content 'に期限切れになります'
      end

      context '招待リンクの有効期限' do
        before do
          program.create_invitation_digest
          sign_out user
          sign_in other_user
        end

        it '3日以内の場合、リンクが有効であること', js: true do
          program.update(send_invitation_at: 2.days.ago)
          visit edit_program_invitation_path(program, program.invitation_token)
          expect(page).to have_button '参加する'
          click_button '参加する'
          expect(page).to have_content "#{program.title}の制作に参加しました"
        end

        it '3日以上経過した場合、リンクが無効になること', js: true do
          program.update(send_invitation_at: 4.days.ago)
          visit edit_program_invitation_path(program, program.invitation_token)
          expect(page).to have_button '参加する'
          click_button '参加する'
          expect(page).to have_content '招待リンクが期限切れです'
        end
      end
    end

    context '招待された側の場合' do
      before do
        program.create_invitation_digest
        sign_out user
        sign_in other_user
      end

      it '招待リンクから番組制作に参加できること', js: true do
        visit edit_program_invitation_path(program, program.invitation_token)
        click_button '参加する'
        expect(page).to have_content "#{program.title}の制作に参加しました"
      end
    end
  end
end
