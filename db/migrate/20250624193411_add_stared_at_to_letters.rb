class AddStaredAtToLetters < ActiveRecord::Migration[7.2]
  def up
    # カラム追加
    add_column :letters, :stared_at, :datetime, null: true, default: nil
    # 既存のstarがついているレコードに対してstared_atを現在時刻に設定
    Letter.where.not(star: [ nil, 0 ]).in_batches do |batch|
      batch.update_all(stared_at: Time.current)
      # バッチ処理でDBへの負荷を分散（大量データの場合）
      sleep(0.01) # 必要に応じて調整
    end
  end

  def down
    remove_column :letters, :stared_at
  end
end
