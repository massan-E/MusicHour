# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Example:

#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# users

if Rails.env.development?
  5001.times do |i|
    User.create!(
      name: "#{Faker::Games::Overwatch.hero}_id_#{i}",
      password: "password",
      password_confirmation: "password",
      confirmed_at: Time.current,
      email: "#{Faker::Internet.unique.email}_id_#{i}"
    )
  end

  user_ids = User.ids
  user = User.find(1)
  user.update(name: "massanE", admin: true, email: "ex@ex.com")

  # programs
  50.times do |index|
    user = User.find(user_ids.sample)
    user.programs.create!(title: "番組タイトル#{index}",
                          body: "番組本文#{Faker::Games::Overwatch.quote}",
                          publish: true
                          )
  end

  program_ids = Program.ids

  # letterboxes
  100.times do |index|
    program = Program.find(program_ids.sample)
    program.letterboxes.create!(title: "お便り箱タイトル#{index}",
                                body: "お便り箱本文#{Faker::Games::Overwatch.quote}")
  end

  letterbox_ids = Letterbox.ids

  # letters
  100000.times do |index|
    letterbox = Letterbox.find(letterbox_ids.sample)
    letterbox.letters.create!(
      title: "letterタイトル#{index}",
      body: "letter本文#{Faker::Games::Overwatch.quote}",
      user_id: user_ids.sample,
      radio_name: "ラジオネーム#{index}", # Fakerの代わりに連番を使用
      program_id: letterbox.program.id,
      star: rand(0..5) # ランダムな星の数を設定
    )
  end
end
