namespace :ranking do
  desc "勢いランキングを更新する"
  task update_ranking: :environment do
    ProgramRanking.delete_all

    rankings = Letter.joins(:program)
                     .where(created_at: 2.weeks.ago..)
                     .where(programs: { publish: true })
                     .where.not(program_id: nil)
                     .group(:program_id)
                     .select("program_id, COUNT(letters.id) as letters_count")
                     .order("letters_count DESC")
                     .limit(10)

    ActiveRecord::Base.transaction do
      rankings.each do |result|
        ProgramRanking.create!(
          program_id: result.program_id,
          letters_count: result.letters_count,
          ranked_on: Date.current
        )
      end
    end

    Rails.logger.info "#{Time.current} 時にランキングを更新しました"
    puts "Rankings updated successfully!"
  rescue => e
    Rails.logger.error "ランキングの作成に失敗しました: #{e.message}"
    puts "Error: #{e.message}"
    raise e
  end

  desc "勢いランキングを更新する"
  task update_star_ranking: :environment do
  #   program_ids = Program.where(publish: true).ids
  #   program_ids.each do |program_id|
  #     program = Program.find(program_id)
  #     next unless program.letters.any?

  #     begin
  #       # 月初から月末までの期間を設定
  #       start_time = Time.zone.today.beginning_of_month + 5.hours
  #       end_time = Time.zone.today.end_of_month.end_of_day + 5.hours

  #       date_range = start_time..end_time

  #       # ユーザーごとの星の数を集計
  #       star_rankings = program.letters
  #                              .where.not(user: nil)
  #                              .where(created_at: date_range)
  #                              .group(:user)
  #                              .limit(10)
  #                              .order(count_star: :desc).count(:star)

  #       # キャッシュに保存
  #       Rails.cache.write("star_rankings_program_#{program.id}", star_rankings, expires_in: 60.minutes)

  #       puts "Star rankings for program #{program.id} updated successfully!"
  #     rescue => e
  #       Rails.logger.error "Failed to update star rankings for program #{program.id}: #{e.message}"
  #       puts "Error updating star rankings for program #{program.id}: #{e.message}"
  #     end
  #   end
  #   puts "All star rankings updated successfully!"
  # rescue => e
  #   Rails.logger.error "Star rankings update failed: #{e.message}"
  #   puts "Error: #{e.message}"
  #   raise e
  end
end
