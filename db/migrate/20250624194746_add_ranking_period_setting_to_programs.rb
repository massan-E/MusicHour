class AddRankingPeriodSettingToPrograms < ActiveRecord::Migration[7.2]
  def change
    add_column :programs, :ranking_period, :integer, default: 0, null: false, comment: 'ランキング期間設定: 0=設定なし, 1=週間, 2=月間'
    add_index :programs, :ranking_period
  end
end